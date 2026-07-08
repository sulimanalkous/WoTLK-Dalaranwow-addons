#!/usr/bin/env python3
"""
Converts Blizzard Classic Anniversary ("DugiGuides_ClassicEra_1.89") dungeon guide
source files into the flat RegisterGuide format this DugisGuideViewerZ engine build
(v4.19, no RegisterModule support) requires.

Mirrors the approach used for the Outland (TBC) dungeon guide rebuild:
- parses the source's RegisterModule/Guide:Load() wrapper (8-arg RegisterGuide call,
  tolerant of literal nil args)
- resolves "next guide" references to another dungeon's title only when that title is
  itself one of the dungeons converted in this same batch/faction (cross-references
  outside the batch resolve to empty, same rule as the Outland converter)
- strips any line containing an |QID|N| not present in the verified TDB quest_template
  ID set (defensive; the classic source checked out 100% valid, so this should be a
  no-op, but kept for parity/safety)
- Caesar-shifts (-3) the plaintext content into the form Retxyz's decoder (+3) expects
- emits old-style flat RegisterGuide(title, nextguide, faction, guidetype, function()
  ... end) calls
"""

import os
import re
import sys
import glob

REGISTER_RE = re.compile(
    r'RegisterGuide\(\s*"[^"]*"\s*,\s*"([^"]*)"\s*,\s*(?:"([^"]*)"|nil)\s*,\s*"([^"]*)"\s*,'
    r'\s*nil\s*,\s*"([^"]*)"\s*,\s*nil\s*,\s*function\(\)\s*return\s*\[\[(.*?)\]\]\s*end\)',
    re.DOTALL,
)

QID_RE = re.compile(r'\|QID\|(\d+)')


def encode_line(line):
    out = []
    for ch in line:
        b = ord(ch)
        if 32 <= b <= 126:
            out.append(chr(b - 3))
        else:
            out.append(ch)
    return "".join(out)


def parse_file(path):
    text = open(path, encoding='utf-8', errors='replace').read().replace('\r\n', '\n')
    m = REGISTER_RE.search(text)
    if not m:
        print(f"  SKIP (no RegisterGuide match): {os.path.basename(path)}")
        return None
    own_title, next_title, faction, guidetype, content = m.groups()
    next_title = next_title or ""
    return {
        "path": path,
        "own_title": own_title,
        "next_title": next_title,
        "faction": faction,
        "guidetype": guidetype,
        "content": content,
    }


def strip_invalid_qids(content, valid_qids):
    kept_lines = []
    stripped = 0
    for line in content.split('\n'):
        qids = [int(q) for q in QID_RE.findall(line)]
        if qids and any(q not in valid_qids for q in qids):
            stripped += 1
            continue
        kept_lines.append(line)
    return "\n".join(kept_lines), stripped


def convert_batch(src_dir, out_dir, valid_qids):
    files = sorted(glob.glob(os.path.join(src_dir, "*.lua")))
    parsed = [p for p in (parse_file(f) for f in files) if p]

    titles = {p["own_title"] for p in parsed}

    os.makedirs(out_dir, exist_ok=True)
    # Remove stale .lua/.lua.backup files from the previous (broken) conversion.
    for stale in glob.glob(os.path.join(out_dir, "*.lua")) + glob.glob(os.path.join(out_dir, "*.lua.backup")):
        os.remove(stale)

    written = []
    total_stripped = 0
    for p in parsed:
        next_title = p["next_title"] if p["next_title"] in titles else ""
        content, stripped = strip_invalid_qids(p["content"], valid_qids)
        total_stripped += stripped
        encoded = "\n".join(encode_line(l) for l in content.strip('\n').split('\n'))

        out_text = (
            f'DugisGuideViewer:RegisterGuide("{p["own_title"]}", "{next_title}", '
            f'"{p["faction"]}", "{p["guidetype"]}", function()\n'
            "return [[\n"
            "AAA\n\n\n"
            f"{encoded}\n\n\n"
            "]]\n"
            "end)\n"
        )

        base = os.path.basename(p["path"])
        out_path = os.path.join(out_dir, base)
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(out_text)
        written.append(base)
        print(f"  wrote {base}  (own='{p['own_title']}' next='{next_title}')")

    # Guides.xml
    xml_lines = ['<Ui xmlns="http://www.blizzard.com/wow/ui/">', ""]
    for base in written:
        xml_lines.append(f'\t<Script file="{base}"/>')
    xml_lines.append("")
    xml_lines.append("</Ui>")
    with open(os.path.join(out_dir, "Guides.xml"), 'w', encoding='utf-8') as f:
        f.write("\n".join(xml_lines) + "\n")

    print(f"  {len(written)} files written, {total_stripped} lines stripped for invalid QIDs")
    return written


def main():
    if len(sys.argv) != 5:
        print("Usage: convert_classic.py <alliance_src> <horde_src> <alliance_out> <horde_out>")
        sys.exit(1)
    alliance_src, horde_src, alliance_out, horde_out = sys.argv[1:5]

    valid_qids_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "valid_quest_ids.txt")
    valid_qids = set(int(l) for l in open(valid_qids_path))
    print(f"Loaded {len(valid_qids)} valid quest IDs")

    print(f"\n--- Alliance: {alliance_src} -> {alliance_out} ---")
    convert_batch(alliance_src, alliance_out, valid_qids)

    print(f"\n--- Horde: {horde_src} -> {horde_out} ---")
    convert_batch(horde_src, horde_out, valid_qids)


if __name__ == "__main__":
    main()
