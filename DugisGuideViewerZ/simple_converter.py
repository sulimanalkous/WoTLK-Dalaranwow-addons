#!/usr/bin/env python3
"""
Simple DugisGuide Converter
Uses the exact same Caesar cipher logic as the addon's Retxyz() function
"""

import os
import re
import sys

def encode_caesar_shift3(text):
    """
    Encode text by subtracting 3 from each character byte value
    This matches exactly what the addon's Retxyz() function expects (it adds 3 when decoding)
    """
    result = ''
    for char in text:
        cb = ord(char)
        if cb >= 3:  # Make sure we don't go below 0
            result += chr(cb - 3)
        else:
            result += char  # Keep character as-is if it would go below 0
    return result

def convert_coordinates(coord_text):
    """Convert (X.X, Y.Y) format to %X+X)Y+Y& format"""
    coord_match = re.search(r'\(([0-9.]+),?\s*([0-9.]+)\)', coord_text)
    if coord_match:
        x = coord_match.group(1).replace('.', '+')
        y = coord_match.group(2).replace('.', '+') 
        return f"%{x}){y}&"
    return ""

def convert_quest_line(line):
    """Convert modern quest line to encoded format that matches working guides"""
    line = line.strip()
    if not line:
        return ""
    
    # Skip non-quest lines
    if (not line or line.startswith('N ') or line.startswith(']]') or 
        line.startswith('end') or line.startswith('local') or line.startswith('function')):
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
    
    # Extract coordinates
    coords = convert_coordinates(line)
    
    # Extract QID
    qid_match = re.search(r'\|QID\|([0-9.]+)\|', line)
    qid = qid_match.group(1) if qid_match else ""
    
    # Clean quest name - remove spaces and special characters
    clean_name = (quest_name.replace(' ', '').replace("'", '').replace('-', '')
                 .replace('(', '').replace(')', '').replace(':', ''))
    
    # Encode the quest name using Caesar cipher +3
    encoded_name = encode_caesar_shift3(clean_name)
    
    # Build the encoded format that matches working guides
    # Pattern from working files: >EncodedQuestNameyKyNPCInfo%coords&yyNFAyQIDy
    if coords and qid:
        encoded_line = f"{quest_type}{encoded_name}yKy{coords}yyNFAy{qid}y"
    elif qid:
        encoded_line = f"{quest_type}{encoded_name}yKyyyNFAy{qid}y"
    else:
        encoded_line = f"{quest_type}{encoded_name}yKy"
    
    return encoded_line

def extract_title_from_content(content):
    """Extract a suitable title from the guide content"""
    # Look for level range in registration
    title_match = re.search(r'"([0-9-()]+)"', content)
    if title_match:
        return title_match.group(1)
    
    # Look for dungeon name in module name
    module_match = re.search(r'_([A-Za-z_]+)\.lua', content)
    if module_match:
        dungeon_name = module_match.group(1).replace('_', ' ')
        return dungeon_name
    
    return "Dungeon Guide"

def convert_file_content(content):
    """Convert entire file from module format to direct registration format"""
    
    # Extract the quest content between return [[ and ]]
    content_match = re.search(r'return \[\[(.*?)\]\]', content, re.DOTALL)
    if not content_match:
        print("Could not find quest content section")
        return content
    
    quest_content = content_match.group(1).strip()
    
    # Convert quest lines
    converted_lines = []
    converted_lines.append("AAA")  # This triggers the decoder in the addon
    converted_lines.append("")
    
    for line in quest_content.split('\n'):
        line = line.strip()
        if line and not line.startswith('N Guide Complete'):
            converted_line = convert_quest_line(line)
            if converted_line:
                converted_lines.append(converted_line)
    
    converted_lines.append("")
    converted_lines.append("NGuideComplete*UltimateWoWGuide.comyKyTicktocontinuetothenextguide")
    
    # Extract guide information
    title = extract_title_from_content(content)
    faction = "Horde" if "Horde" in content else "Alliance"
    
    # Build the new file content in the format that matches working guides
    new_content = f'''DugisGuideViewer:RegisterGuide("{title}", "", "{faction}", "I", function()
return [[
{chr(10).join(converted_lines)}
]]
end)
'''
    
    return new_content

def convert_file(input_path, backup=True):
    """Convert a single dungeon file"""
    try:
        # Create backup if requested
        if backup:
            backup_path = input_path + ".backup"
            with open(input_path, 'r', encoding='utf-8') as f:
                backup_content = f.read()
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(backup_content)
            print(f"Backup created: {backup_path}")
        
        # Read original content
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Convert the content
        converted_content = convert_file_content(content)
        
        # Write the converted content
        with open(input_path, 'w', encoding='utf-8') as f:
            f.write(converted_content)
        
        print(f"Converted: {input_path}")
        return True
        
    except Exception as e:
        print(f"Error converting {input_path}: {e}")
        return False

def convert_directory(dir_path, backup=True):
    """Convert all .lua files in a directory"""
    if not os.path.isdir(dir_path):
        print(f"Directory not found: {dir_path}")
        return
    
    lua_files = [f for f in os.listdir(dir_path) 
                 if f.endswith('.lua') and f != 'Guides.xml']
    
    print(f"Found {len(lua_files)} .lua files in {dir_path}")
    
    converted = 0
    for filename in lua_files:
        file_path = os.path.join(dir_path, filename)
        if convert_file(file_path, backup):
            converted += 1
    
    print(f"Successfully converted {converted}/{len(lua_files)} files")

def test_encoding():
    """Test the encoding function with known examples"""
    test_cases = [
        ("YourPlaceInTheWorld", "VlroMi^`bFkQebTloia"),
        ("CuttingTeeth", "@rqqfkdQbbqe"),
        ("Kaltunk", "H^iqrkh"),
        ("Ragefire", "O^dbcfob"),
    ]
    
    print("Testing Caesar cipher encoding:")
    for original, expected in test_cases:
        encoded = encode_caesar_shift3(original)
        print(f"{original} -> {encoded} (expected: {expected}) {'✓' if encoded == expected else '✗'}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("DugisGuide Simple Converter")
        print("Usage:")
        print("  python3 simple_converter.py <file_or_directory>")
        print("  python3 simple_converter.py test  # Test encoding")
        print("")
        print("Examples:")
        print("  python3 simple_converter.py DugisGuide_Dungeons_Horde_En/")
        print("  python3 simple_converter.py test_file.lua")
        print("  python3 simple_converter.py test")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if target_path == "test":
        test_encoding()
    elif os.path.isfile(target_path):
        convert_file(target_path)
    elif os.path.isdir(target_path):
        convert_directory(target_path)
    else:
        print(f"Path not found: {target_path}")