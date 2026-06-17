import json, re

key_map = {
    "BANK NAMES": "bank_names",
    "BUS NAMES": "bus_names",
    "EVENT NAMES": "events",
    "SFX NAMES": "sfx",
    "RTPC/GAME-VARIABLE NAMES": "rtpc_variables",
    "BASE RTPC/GAME-VARIABLE NAMES": "base_rtpc_variables",
    "VARIABLE NAMES": "variables",
    "VALUE NAMES": "values",
}

result = {}
current_bank = None
current_type = None

with open("./wwise-banks-with-names.txt") as f:
    for line in f:
        stripped = line.strip()
        if not stripped:
            continue

        header_match = re.match(r'^### (.+?)(?:\s+\((.+?)\))?$', stripped)
        if header_match:
            section_type = header_match.group(1)
            bank_file = header_match.group(2)
            clean_key = key_map.get(section_type, section_type.lower().replace("/", "_").replace(" ", "_"))

            if bank_file:
                bank_name = re.sub(r'^langs/', '', bank_file)
                bank_name = re.sub(r'\.(?:english\.)?bnk$', '', bank_name)
                current_bank = bank_name
                current_type = clean_key
                if current_bank not in result:
                    result[current_bank] = {}
                if current_type not in result[current_bank]:
                    result[current_bank][current_type] = []
            else:
                # Skip global sections (BANK NAMES, BUS NAMES)
                current_bank = None
                current_type = None
            continue

        if current_bank is not None and current_type is not None:
            num_match = re.match(r'^#\s+(\d+)$', stripped)
            if num_match:
                result[current_bank][current_type].append(int(num_match.group(1)))
            else:
                result[current_bank][current_type].append(stripped)

with open("./WwiseBanks.json", "w") as f:
    json.dump(result, f, indent=2)

total_entries = sum(len(v) for bank in result.values() for v in bank.values())
print(f"Banks: {len(result)}, Total entries: {total_entries}")