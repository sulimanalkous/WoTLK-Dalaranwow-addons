#!/usr/bin/env python3
"""
DugisGuide Dungeon Converter
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

def decode_caesar(text, shift=3):
    """Decode text using Caesar cipher with specified shift"""
    result = ''
    for char in text:
        if char.isalpha():
            base = ord('A') if char.isupper() else ord('a')
            result += chr((ord(char) - base - shift) % 26 + base)
        else:
            result += char
    return result

def convert_quest_line(line):
    """Convert a modern quest line to encoded format"""
    line = line.strip()
    if not line:
        return ""
    
    # Parse quest line components
    # Example: "A Taragaman the Hungerer |N|(npc:44217) (68.4, 11.5)| |QID|26858| |NPC|44217|"
    
    # Extract quest type (first character)
    quest_type = line[0] if line else ""
    
    # Extract quest name (everything before first |)
    quest_name = line[2:].split('|')[0].strip() if '|' in line else line[2:].strip()
    
    # Extract coordinates if present
    coord_match = re.search(r'\(([0-9.]+),?\s*([0-9.]+)\)', line)
    coords = f"({coord_match.group(1)}){coord_match.group(2)}&" if coord_match else ""
    
    # Extract QID
    qid_match = re.search(r'\|QID\|([0-9.]+)\|', line)
    qid = qid_match.group(1) if qid_match else ""
    
    # Extract NPC name from |N| section
    npc_match = re.search(r'\|N\|([^|]+)\|', line)
    npc_info = npc_match.group(1) if npc_match else ""
    
    # Encode the quest name
    encoded_name = encode_caesar(quest_name.replace(' ', '').replace("'", ""))
    
    # Build the encoded format
    # Pattern: >EncodedQuestNameyKyNPCInfo%coords&yyNFAyQIDy
    if coords and qid:
        encoded_line = f"{quest_type}{encoded_name}yKy{coords}yyNFAy{qid}y"
    elif qid:
        encoded_line = f"{quest_type}{encoded_name}yKyyyNFAy{qid}y"
    else:
        encoded_line = f"{quest_type}{encoded_name}yKy"
    
    return encoded_line

def convert_registration_format(content):
    """Convert module registration to direct registration format"""
    # Extract guide info from module registration
    module_match = re.search(r'DugisGuideViewer:RegisterModule\("([^"]+)"\)', content)
    if not module_match:
        return content
    
    # Extract guide registration parameters
    register_match = re.search(r'DugisGuideViewer:RegisterGuide\("([^"]*)",\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)"[^,]*,\s*"([^"]*)"[^,]*,\s*([^,]*),\s*function\(\)', content)
    if not register_match:
        return content
    
    # Build the old format registration
    # Pattern: DugisGuideViewer:RegisterGuide("Title", "NextGuide", "Faction", "Type", function()
    title = register_match.group(2)  # Use the level range as title
    next_guide = ""  # We'll leave this empty for dungeons
    faction = register_match.group(4)
    guide_type = register_match.group(5) or "I"  # Instance/Dungeon type
    
    # Extract the quest content between return [[ and ]]
    content_match = re.search(r'return \[\[(.*?)\]\]', content, re.DOTALL)
    if not content_match:
        return content
    
    quest_content = content_match.group(1).strip()
    
    # Convert quest lines
    converted_lines = []
    for line in quest_content.split('\n'):
        if line.strip():
            converted_line = convert_quest_line(line)
            if converted_line:
                converted_lines.append(converted_line)
    
    # Build the final format
    new_content = f"""DugisGuideViewer:RegisterGuide("{title}", "{next_guide}", "{faction}", "{guide_type}", function()
return [[
AAA

{chr(10).join(converted_lines)}

NGuideComplete*UltimateWoWGuide.comyKyTicktocontinuetothenextguide
]]
end)
"""
    
    return new_content

def convert_file(input_path, output_path=None):
    """Convert a single dungeon file"""
    if output_path is None:
        output_path = input_path
    
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Convert the content
        converted_content = convert_registration_format(content)
        
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
    
    lua_files = [f for f in os.listdir(dir_path) if f.endswith('.lua')]
    
    print(f"Found {len(lua_files)} .lua files in {dir_path}")
    
    for filename in lua_files:
        file_path = os.path.join(dir_path, filename)
        convert_file(file_path)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 convert_dungeons.py <directory_path>")
        print("Example: python3 convert_dungeons.py DugisGuide_Dungeons_Horde_En/")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if os.path.isfile(target_path):
        convert_file(target_path)
    elif os.path.isdir(target_path):
        convert_directory(target_path)
    else:
        print(f"Path not found: {target_path}")