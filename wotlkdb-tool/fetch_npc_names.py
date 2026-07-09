#!/usr/bin/env python3
"""Batch-fetches NPC names for a list of IDs (one per line, from a file argument or stdin)
via wotlkdb_client, writing the result as a JSON {id: name} map to stdout."""
import sys
import json
from wotlkdb_client import fetch_npc

def main():
    if len(sys.argv) == 2:
        ids = [int(l.strip()) for l in open(sys.argv[1]) if l.strip()]
    else:
        ids = [int(l.strip()) for l in sys.stdin if l.strip()]

    names = {}
    total = len(ids)
    for n, npcid in enumerate(ids, 1):
        try:
            info = fetch_npc(npcid)
            names[npcid] = info["name"]
        except Exception as e:
            print(f"[{n}/{total}] {npcid}: ERROR {e}", file=sys.stderr)
            continue
        if n % 25 == 0:
            print(f"[{n}/{total}] done", file=sys.stderr)

    print(json.dumps(names, indent=2))

if __name__ == "__main__":
    main()
