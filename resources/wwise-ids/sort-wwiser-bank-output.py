import json

unique_lines = []

def parse_file(input_file_path, output_file_path):

    with open(input_file_path, 'r', encoding='utf-8') as infile:
        for line in infile:
            stripped = line.strip()
            if stripped and not stripped.startswith('#') and stripped not in unique_lines:
                print(stripped)
                unique_lines.append(stripped)

    with open(output_file_path, 'w', encoding='utf-8') as outfile:
        json.dump(list(sorted(unique_lines)), outfile, indent=4)

parse_file('E:\\PAYDAY 2 Modding Workspace\\4. Sound\\wwise-banks-with-names.txt', 'E:\\PAYDAY 2 Modding Workspace\\4. Sound\\wwise-string-list.json')