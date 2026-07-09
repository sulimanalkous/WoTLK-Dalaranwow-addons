#!/usr/bin/env python3
"""
Batch-verifies a list of quest IDs (one per line, from stdin or a file) against
wotlkdb.com using wotlkdb_client, and reports any marked unavailable/historical
along with their replacement ID, so guide data referencing deprecated quest IDs
can be found and fixed in one pass instead of one bug report at a time.
"""
import sys
from wotlkdb_client import fetch_quest

def main():
    if len(sys.argv) == 2:
        ids = [int(l.strip()) for l in open(sys.argv[1]) if l.strip()]
    else:
        ids = [int(l.strip()) for l in sys.stdin if l.strip()]

    total = len(ids)
    bad = []
    for n, qid in enumerate(ids, 1):
        try:
            info = fetch_quest(qid)
        except Exception as e:
            print(f"[{n}/{total}] QID {qid}: ERROR {e}", file=sys.stderr)
            continue
        status = "OK" if info["available"] else "UNAVAILABLE"
        print(f"[{n}/{total}] QID {qid} ({info['name']}): {status}"
              + (f" -> replacement {info['replacement_id']}" if not info["available"] else ""),
              file=sys.stderr)
        if not info["available"]:
            bad.append(info)

    print("\n=== SUMMARY ===")
    print(f"Checked {total} quest IDs, {len(bad)} unavailable/historical:\n")
    for info in bad:
        print(f"  QID {info['id']} ({info['name']}) -> replacement: {info['replacement_id']} "
              f"(start_npc={info['start_npc']}, end_npc={info['end_npc']})")

if __name__ == "__main__":
    main()
