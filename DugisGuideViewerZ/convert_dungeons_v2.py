#!/usr/bin/env python3
"""
DugisGuide Dungeon Converter v2
Converts newer dungeon guide format to WoTLK 3.3.5a compatible format
"""

import os
import re
import sys

def encode_caesar(text, shift=3):
    """Encode text using Caesar cipher with specified shift"""
    result = ''
    for char in text:
        if char.isalpha():
            base = ord('A') if char.isupper() else ord('a')
            result += chr((ord(char) - base + shift) % 26 + base)
        else:
            result += char
    return result

def convert_quest_line(line):
    """Convert a modern quest line to encoded format"""
    line = line.strip()
    if not line:
        return ""
    
    # Skip non-quest lines
    if not line or line.startswith('N ') or line.startswith(']]') or line.startswith('end'):
        return ""
    
    # Extract quest type (first character: A, T, C, K, R, etc.)
    quest_type = line[0] if line else ""
    if quest_type not in ['A', 'T', 'C', 'K', 'R', '>', 'N', 'H', 'F']:
        return ""
    
    # Extract quest name (everything before first |)
    if '|' in line:
        quest_name = line[2:].split('|')[0].strip()
    else:
        quest_name = line[2:].strip()
    
    # Extract coordinates if present - look for (X, Y) or (X.X, Y.Y)
    coord_match = re.search(r'\(([0-9.]+),?\s*([0-9.]+)\)', line)
    coords = ""
    if coord_match:
        x = coord_match.group(1).replace('.', '+')
        y = coord_match.group(2).replace('.', '+') 
        coords = f"%{x},{y}&"
    
    # Extract QID
    qid_match = re.search(r'\|QID\|([0-9.]+)\|', line)
    qid = qid_match.group(1) if qid_match else ""
    
    # Clean and encode the quest name
    clean_name = quest_name.replace(' ', '').replace("'", '').replace('-', '').replace('(', '').replace(')', '')
    encoded_name = encode_caesar(clean_name)
    
    # Build the encoded format based on examples from working files
    # Pattern: >EncodedQuestNameyKyNPCInfo%coords&yyNFAyQIDy
    if coords and qid:
        encoded_line = f"{quest_type}{encoded_name}yKy{coords}yyNFAy{qid}y"
    elif qid:
        encoded_line = f"{quest_type}{encoded_name}yKyyyNFAy{qid}y"
    else:
        encoded_line = f"{quest_type}{encoded_name}yKy"
    
    return encoded_line

def convert_file_content(content):
    """Convert the entire file content"""
    
    # Extract the quest content between return [[ and ]]
    content_match = re.search(r'return \[\[(.*?)\]\]', content, re.DOTALL)
    if not content_match:
        print("Could not find quest content section")
        return content
    
    quest_content = content_match.group(1).strip()
    
    # Convert quest lines
    converted_lines = []
    converted_lines.append("AAA")
    converted_lines.append("")
    
    for line in quest_content.split('\n'):
        line = line.strip()
        if line and not line.startswith('N Guide Complete'):
            converted_line = convert_quest_line(line)
            if converted_line:
                converted_lines.append(converted_line)
    
    converted_lines.append("")
    converted_lines.append("NGuideComplete*UltimateWoWGuide.comyKyTicktocontinuetothenextguide")
    
    # Extract title from the original registration - use the level range
    title_match = re.search(r'"([0-9-()]+)"', content)
    title = title_match.group(1) if title_match else "Dungeon Guide"
    
    # Determine faction
    faction = "Horde" if "Horde" in content else "Alliance"
    
    # Build the new file content
    new_content = f'''DugisGuideViewer:RegisterGuide("{title}", "", "{faction}", "I", function()
return [[
{chr(10).join(converted_lines)}
]]
end)
'''
    
    return new_content

def convert_file(input_path, output_path=None):
    """Convert a single dungeon file"""
    if output_path is None:
        output_path = input_path
    
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Convert the content
        converted_content = convert_file_content(content)
        
        # Write the converted content
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(converted_content)
        
        print(f"Converted: {input_path}")
        return True
        
    except Exception as e:
        print(f"Error converting {input_path}: {e}")
        return False

def convert_directory(dir_path):
    """Convert all .lua files in a directory"""
    if not os.path.isdir(dir_path):
        print(f"Directory not found: {dir_path}")
        return
    
    lua_files = [f for f in os.listdir(dir_path) if f.endswith('.lua') and f != 'Guides.xml']
    
    print(f"Found {len(lua_files)} .lua files in {dir_path}")
    
    converted = 0
    for filename in lua_files:
        file_path = os.path.join(dir_path, filename)
        if convert_file(file_path):
            converted += 1
    
    print(f"Successfully converted {converted}/{len(lua_files)} files")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 convert_dungeons_v2.py <directory_path>")
        print("Example: python3 convert_dungeons_v2.py DugisGuide_Dungeons_Horde_En/")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if os.path.isfile(target_path):
        convert_file(target_path)
    elif os.path.isdir(target_path):
        convert_directory(target_path)
    else:
        print(f"Path not found: {target_path}")