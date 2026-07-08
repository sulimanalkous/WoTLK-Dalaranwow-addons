#!/usr/bin/env python3
"""
Final Correct DugisGuide Content Converter
Encodes guide files by extracting the RegisterGuide call from within the module structure
and placing it at the top level of the generated file.
"""

import os
import re
import sys

def get_dungeon_name_from_filename(backup_path):
    """Extracts the dungeon name from a filename like '15_16_Ragefire_Chasm.lua.backup'."""
    basename = os.path.basename(backup_path)
    name_part = basename.replace('.lua.backup', '')
    
    match = re.match(r'(\d+)_(\d+)_(.*)', name_part)
    if not match:
        # Fallback for filenames that don't match the pattern
        return name_part.replace('_', ' ')

    min_level, max_level, dungeon_name_part = match.groups()
    
    level_range = f"({min_level}-{max_level})"
    dungeon_name = dungeon_name_part.replace('_', ' ')

    return f"{dungeon_name} {level_range}"

def encode_line(line):
    """Encodes a single line of text using a -3 Caesar cipher shift."""
    encoded_chars = []
    for char in line:
        byte_val = ord(char)
        k = 3
        if 32 <= byte_val <= 126:
            encoded_byte = byte_val - k
            encoded_chars.append(chr(encoded_byte))
        else:
            encoded_chars.append(char)
    return "".join(encoded_chars)

def convert_guide_file(backup_path, dungeon_id_map):
    """Converts a single guide file by extracting and encoding its content."""
    try:
        with open(backup_path, 'r', encoding='utf-8') as f:
            original_module_content = f.read()

        # 1. Extract the RegisterGuide call and its arguments from the module content
        # This regex is designed to capture the arguments within the RegisterGuide call
        # and the content block that follows it.
        register_guide_match = re.search(
            r'DugisGuideViewer:RegisterGuide\([^,]*,\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)",\s*[^,]*,\s*"([^"]*)",\s*[^,]*,\s*function\(\)\s*return \[\[(.*?)\]\]\s*end\)',
            original_module_content, re.DOTALL
        )

        if not register_guide_match:
            print(f"Could not find RegisterGuide pattern in {os.path.basename(backup_path)}")
            return False

        # Extract captured groups
        title_id_str, next_guide_id_str, faction, guide_type, plain_text_content = register_guide_match.groups()

        # 2. Resolve proper titles for current and next guide
        proper_title = get_dungeon_name_from_filename(backup_path)
        next_guide_title = ""
        if next_guide_id_str:
            next_level_match = re.search(r'(\d+)\((\d+-\d+)\)', next_guide_id_str)
            if next_level_match:
                next_id, next_level_range = next_level_match.groups()
                if next_id in dungeon_id_map:
                    next_guide_title = f"{dungeon_id_map[next_id]} ({next_level_range})"

        # 3. Encode the guide content

        encoded_lines = [encode_line(line) for line in plain_text_content.strip().split('\n')]
        encoded_block = '\n'.join(encoded_lines)

        # 4. Construct the new top-level RegisterGuide call  
        new_content_template = '''DugisGuideViewer:RegisterGuide("{title}", "{next_guide}", "{faction}", "{type}", function()
return [[
AAA
{content}
]]
end)'''
        new_content = new_content_template.format(
            title=proper_title, 
            next_guide=next_guide_title,
            faction=faction, 
            type=guide_type, 
            content=encoded_block
        )

        # 5. Write to the .lua file
        output_path = backup_path.replace('.lua.backup', '.lua')
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
            
        print(f"Successfully converted: {os.path.basename(output_path)}")
        return True

    except Exception as e:
        print(f"Error converting {backup_path}: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 correct_converter.py <directory_path>")
        sys.exit(1)
        
    target_dir = sys.argv[1]
    if not os.path.isdir(target_dir):
        print(f"Error: Directory not found at '{target_dir}'")
        sys.exit(1)

    backup_files = [f for f in os.listdir(target_dir) if f.endswith('.lua.backup')]
    if not backup_files:
        print(f"No '.lua.backup' files found in '{target_dir}'.")
        return

    # --- PASS 1: Build a map of Dungeon ID -> Dungeon Name ---
    dungeon_id_map = {}
    for filename in backup_files:
        try:
            full_path = os.path.join(target_dir, filename)
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract title_id_str from the module's RegisterGuide call
            reg_match = re.search(r'DugisGuideViewer:RegisterGuide\([^,]*,\s*"([^"]*)",', content)
            if reg_match:
                title_id_str = reg_match.group(1)
                id_match = re.search(r'(\d+)\(.*', title_id_str)
                if id_match:
                    dungeon_id = id_match.group(1)
                    dungeon_name = get_dungeon_name_from_filename(full_path)
                    dungeon_id_map[dungeon_id] = dungeon_name
        except Exception:
            continue # Ignore files that can't be parsed

    print(f"--- Built map of {len(dungeon_id_map)} dungeon IDs ---")

    # --- PASS 2: Convert files using the map ---
    print(f"--- Running conversion for: {target_dir} ---")
    converted_count = 0
    for filename in backup_files:
        full_path = os.path.join(target_dir, filename)
        if convert_guide_file(full_path, dungeon_id_map):
            converted_count += 1
            
    print(f"\nConversion complete. {converted_count}/{len(backup_files)} files converted.")

if __name__ == "__main__":
    main()
