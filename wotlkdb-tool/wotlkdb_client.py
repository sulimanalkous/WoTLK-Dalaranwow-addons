#!/usr/bin/env python3
"""
Small reusable client/cache for wotlkdb.com (a 3.3.5a-specific quest/item/NPC database),
built to verify that IDs referenced in addon guide data (Dugi-style quest tags, loot IDs,
NPC IDs, etc.) actually match what the live server currently uses - static TDB SQL dumps
go stale as the server patches its database over time, but a "Not available to players"
quest can still exist validly in an old dump's quest_template table, so ID existence alone
isn't proof it's current. See DugisGuideViewerZ/dugi.md for the incident that motivated this
(quest 1048 "Into The Scarlet Monastery" turned out to be a deprecated duplicate of 14355).

Usage:
    python3 wotlkdb_client.py quest 14355
    python3 wotlkdb_client.py item 6802
    python3 wotlkdb_client.py npc 36273

As a library:
    from wotlkdb_client import fetch_quest, fetch_item, fetch_npc
    info = fetch_quest(14355)  # dict, cached locally after first fetch

Data is cached in cache.sqlite (same folder) so repeated runs/tools don't re-hit the site.
Requests are rate-limited (RATE_LIMIT_SECONDS between requests) to be a respectful client -
this is a low-volume verification tool, not a bulk scraper of the whole site.
"""

import json
import re
import sqlite3
import sys
import time
import urllib.request
import os

BASE_URL = "https://wotlkdb.com/?{etype}={eid}"
USER_AGENT = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
              "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
RATE_LIMIT_SECONDS = 1.5
CACHE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cache.sqlite")

_last_request_time = 0.0


def _init_db():
    conn = sqlite3.connect(CACHE_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS pages (
            entity_type TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            html TEXT NOT NULL,
            fetched_at INTEGER NOT NULL,
            PRIMARY KEY (entity_type, entity_id)
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS parsed (
            entity_type TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            data_json TEXT NOT NULL,
            PRIMARY KEY (entity_type, entity_id)
        )
    """)
    conn.commit()
    return conn


def _rate_limit():
    global _last_request_time
    elapsed = time.time() - _last_request_time
    if elapsed < RATE_LIMIT_SECONDS:
        time.sleep(RATE_LIMIT_SECONDS - elapsed)
    _last_request_time = time.time()


def _fetch_html(entity_type, entity_id, force=False):
    conn = _init_db()
    if not force:
        row = conn.execute(
            "SELECT html FROM pages WHERE entity_type=? AND entity_id=?",
            (entity_type, entity_id)
        ).fetchone()
        if row:
            conn.close()
            return row[0]

    _rate_limit()
    url = BASE_URL.format(etype=entity_type, eid=entity_id)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=15) as resp:
        html = resp.read().decode("utf-8", errors="replace")

    conn.execute(
        "INSERT OR REPLACE INTO pages (entity_type, entity_id, html, fetched_at) VALUES (?,?,?,?)",
        (entity_type, entity_id, html, int(time.time()))
    )
    conn.commit()
    conn.close()
    return html


def _cache_parsed(entity_type, entity_id, data):
    conn = _init_db()
    conn.execute(
        "INSERT OR REPLACE INTO parsed (entity_type, entity_id, data_json) VALUES (?,?,?)",
        (entity_type, entity_id, json.dumps(data))
    )
    conn.commit()
    conn.close()


def _get_cached_parsed(entity_type, entity_id):
    conn = _init_db()
    row = conn.execute(
        "SELECT data_json FROM parsed WHERE entity_type=? AND entity_id=?",
        (entity_type, entity_id)
    ).fetchone()
    conn.close()
    return json.loads(row[0]) if row else None


def _extract_listviews(html):
    """Return list of parsed dicts from every `new Listview({...});` call whose
    "data" is a JSON array of objects (skips ones referencing bare JS vars like lv_comments)."""
    results = []
    for m in re.finditer(r'new Listview\((\{.*?\})\);', html):
        blob = m.group(1)
        dm = re.search(r'"data":(\[.*?\])(?=,"name")', blob)
        if not dm:
            continue
        try:
            results.append(json.loads(dm.group(1)))
        except json.JSONDecodeError:
            continue
    return results


def fetch_quest(qid, force=False):
    cached = None if force else _get_cached_parsed("quest", qid)
    if cached:
        return cached

    html = _fetch_html("quest", qid, force=force)

    name_m = re.search(r"<title>(.*?) - Quest -", html)
    name = name_m.group(1).strip() if name_m else None

    infobox_m = re.search(r'Markup\.printHtml\("(.*?)",\s*"infobox-contents0"', html)
    infobox = infobox_m.group(1) if infobox_m else ""
    infobox = infobox.replace('\\"', '"')

    available = "Not available to players" not in infobox

    level_m = re.search(r"Level:\s*(\d+)", infobox)
    reqlevel_m = re.search(r"Requires Level\s*(\d+)", infobox)
    start_npcs = re.findall(r"Start:\s*\[/icon\]\s*\[npc=(\d+)\]", infobox)
    end_npcs = re.findall(r"End:\s*\[/icon\]\s*\[npc=(\d+)\]", infobox)
    start_obj = re.findall(r"Start:\s*\[/icon\]\s*\[object=(\d+)\]", infobox)
    end_obj = re.findall(r"End:\s*\[/icon\]\s*\[object=(\d+)\]", infobox)

    side = None
    if "icon-horde" in infobox:
        side = "Horde"
    elif "icon-alliance" in infobox:
        side = "Alliance"

    replacement_id = None
    siblings = []
    for lv in _extract_listviews(html):
        for entry in lv:
            if isinstance(entry, dict) and entry.get("name") == name and "id" in entry:
                siblings.append({
                    "id": entry["id"],
                    "level": entry.get("level"),
                    "reqlevel": entry.get("reqlevel"),
                    "historical": entry.get("historical", False),
                })
    if not available:
        for sib in siblings:
            if sib["id"] != qid and not sib["historical"]:
                replacement_id = sib["id"]
                break

    data = {
        "id": qid,
        "name": name,
        "available": available,
        "level": int(level_m.group(1)) if level_m else None,
        "reqlevel": int(reqlevel_m.group(1)) if reqlevel_m else None,
        "side": side,
        "start_npc": int(start_npcs[0]) if start_npcs else None,
        "end_npc": int(end_npcs[0]) if end_npcs else None,
        "start_object": int(start_obj[0]) if start_obj else None,
        "end_object": int(end_obj[0]) if end_obj else None,
        "replacement_id": replacement_id,
        "siblings": siblings,
    }
    _cache_parsed("quest", qid, data)
    return data


def fetch_item(itemid, force=False):
    cached = None if force else _get_cached_parsed("item", itemid)
    if cached:
        return cached

    html = _fetch_html("item", itemid, force=force)
    m = re.search(r"_\[" + str(itemid) + r"\]=(\{[^}]*\});", html)
    data = {"id": itemid, "name": None, "quality": None, "icon": None}
    if m:
        try:
            obj = json.loads(m.group(1))
            data["name"] = obj.get("name_enus")
            data["quality"] = obj.get("quality")
            data["icon"] = obj.get("icon")
        except json.JSONDecodeError:
            pass
    _cache_parsed("item", itemid, data)
    return data


def fetch_npc(npcid, force=False):
    cached = None if force else _get_cached_parsed("npc", npcid)
    if cached:
        return cached

    html = _fetch_html("npc", npcid, force=force)
    name_m = re.search(r"<title>(.*?) - NPC -", html)
    zone_m = re.search(r"can be found in.*?>([^<]+)</a>", html)
    data = {
        "id": npcid,
        "name": name_m.group(1).strip() if name_m else None,
        "zone": zone_m.group(1).strip() if zone_m else None,
    }
    _cache_parsed("npc", npcid, data)
    return data


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("quest", "item", "npc"):
        print("Usage: wotlkdb_client.py <quest|item|npc> <id>")
        sys.exit(1)
    etype, eid = sys.argv[1], int(sys.argv[2])
    fn = {"quest": fetch_quest, "item": fetch_item, "npc": fetch_npc}[etype]
    print(json.dumps(fn(eid), indent=2))


if __name__ == "__main__":
    main()
