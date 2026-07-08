#!/usr/bin/env python3
"""
Proper DugisGuide Dungeon Converter
Converts the backup dungeon files to proper format while preserving quest structure
"""

import os
import re
import sys

def encode_text(text):
    """Encode text using Caesar cipher (-3 shift)"""
    result = ""
    for char in text:
        cb = ord(char)
        if cb < 128 - 3:
            result += chr(cb - 3)
        else:
            result += char
    return result

def extract_dungeon_name_from_title(title):
    """Extract clean dungeon name from title like '213(15-16)'"""
    # Mapping of IDs to dungeon names
    dungeon_names = {
        "213": "Ragefire Chasm",
        "291": "The Deadmines", 
        "209": "Wailing Caverns",
        "764": "Shadowfang Keep",
        "717": "The Stockade",
        "721": "Gnomeregan",
        "718": "Blackfathom Deeps",
        "491": "Razorfen Kraul",
        "722": "Scarlet Monastery Graveyard",
        "723": "Scarlet Monastery Library", 
        "724": "Scarlet Monastery Armory",
        "725": "Scarlet Monastery Cathedral",
        "747": "Maraudon Purple",
        "750": "Maraudon Orange", 
        "751": "Maraudon Pristine",
        "695": "Uldaman",
        "226": "ZulFarrak",
        "737": "Dire Maul East",
        "738": "Dire Maul West",
        "739": "Dire Maul North",
        "766": "Scholomance",
        "767": "Stratholme Main Gate",
        "768": "Stratholme Service Gate",
        "741": "Razorfen Downs",
        "765": "Sunken Temple",
        "740": "Blackrock Depths Detention",
        "742": "Blackrock Depths Upper"
    }
    
    # Extract ID from title like "213(15-16)"
    match = re.match(r'(\d+)\((\d+-\d+)\)', title)
    if match:
        dungeon_id = match.group(1)
        level_range = match.group(2)
        if dungeon_id in dungeon_names:
            return f"{dungeon_names[dungeon_id]} ({level_range})"
    
    return title

def convert_dungeon_file(file_path):
    """Convert a single dungeon file from module format to direct registration"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract the guide registration info from the module format
        register_match = re.search(r'DugisGuideViewer:RegisterGuide\("([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)", [^,]*, "([^"]*)", [^,]*, function\(\)', content)
        if not register_match:
            print(f"Could not find RegisterGuide pattern in {os.path.basename(file_path)}")
            return False
        
        zone_name = register_match.group(1)
        original_title = register_match.group(2)  # This is like "213(15-16)"
        next_guide = register_match.group(3)
        faction = register_match.group(4)
        guide_type = register_match.group(5)  # This should be "I"
        
        # Extract the guide content between return [[ and ]]
        content_match = re.search(r'return \[\[(.*?)\]\]', content, re.DOTALL)
        if not content_match:
            print(f"Could not find guide content in {os.path.basename(file_path)}")
            return False
        
        guide_content = content_match.group(1).strip()
        
        # Generate proper title from the original title
        proper_title = extract_dungeon_name_from_title(original_title)
        
        # Encode the guide content 
        encoded_content = encode_text(guide_content)
        
        # Build the new file content in direct registration format
        new_content = f'''DugisGuideViewer:RegisterGuide("{proper_title}", "", "{faction}", "I", function()
return [[
AAA

{encoded_content}
]]
end)
'''
        
        # Write the new content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        filename = os.path.basename(file_path)
        print(f"Converted: {filename}")
        print(f"  Title: {original_title} -> {proper_title}")
        print(f"  Faction: {faction}")
        print(f"  Type: {guide_type}")
        return True
        
    except Exception as e:
        print(f"Error converting {file_path}: {e}")
        return False

def convert_directory(dir_path):
    """Convert all .lua.backup files in a directory"""
    if not os.path.isdir(dir_path):
        print(f"Directory not found: {dir_path}")
        return
    
    backup_files = [f for f in os.listdir(dir_path) if f.endswith('.lua.backup')]
    
    if not backup_files:
        print(f"No .lua.backup files found in {dir_path}")
        return
    
    print(f"Converting {len(backup_files)} backup files in {dir_path}")
    print("=" * 60)
    
    converted = 0
    for filename in backup_files:
        backup_path = os.path.join(dir_path, filename)
        lua_path = os.path.join(dir_path, filename.replace('.lua.backup', '.lua'))
        
        # Copy backup to main file first
        try:
            with open(backup_path, 'r', encoding='utf-8') as f:
                backup_content = f.read()
            with open(lua_path, 'w', encoding='utf-8') as f:
                f.write(backup_content)
        except Exception as e:
            print(f"Error copying {filename}: {e}")
            continue
            
        # Convert the main file
        if convert_dungeon_file(lua_path):
            converted += 1
        print()
    
    print("=" * 60)
    print(f"Successfully converted {converted}/{len(backup_files)} files")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Proper DugisGuide Dungeon Converter")
        print("Usage:")
        print("  python3 proper_dungeon_converter.py <directory_path>")
        print("  python3 proper_dungeon_converter.py <file_path>")
        print("")
        print("Examples:")
        print("  python3 proper_dungeon_converter.py DugisGuide_Dungeons_Horde_En/")
        print("  python3 proper_dungeon_converter.py DugisGuide_Dungeons_Alliance_En/")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if os.path.isfile(target_path):
        convert_dungeon_file(target_path)
    elif os.path.isdir(target_path):
        convert_directory(target_path)
    else:
        print(f"Path not found: {target_path}")