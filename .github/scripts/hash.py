import hashlib, os, json

MODS_DIR = "mods"
OUTPUT_DIR = "meta_out"

def hash_mod(mod_name):
    file_hashes = []

    # Walk the folder and get all file paths
    for root, _, files in os.walk(MODS_DIR + os.path.sep + mod_name):
        for file in files:
            # Get full file path
            full_path = os.path.join(root, file)

            # Get relative path from mod_path
            rel_path = os.path.relpath(full_path, MODS_DIR + os.path.sep + mod_name).lower()

            # Read file content and hash it
            with open(full_path, "rb") as f:
                file_content = f.read()
                file_hash = hashlib.sha256(file_content).hexdigest()

            file_hashes.append((rel_path, file_hash))

    # Sort by relative file path (case-insensitive)
    file_hashes.sort(key=lambda x: x[0])

    # Concatenate all individual hashes
    concatenated = "".join([h[1] for h in file_hashes])

    # Hash the final concatenated string
    return hashlib.sha256(concatenated.encode("utf-8")).hexdigest()

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    mods = [d for d in os.listdir(MODS_DIR) if os.path.isdir(os.path.join(MODS_DIR, d))]

    for mod in mods:
        if not os.path.exists(os.path.join(MODS_DIR, mod, "mod.txt")):
            continue

        print(mod)

        with open(os.path.join(MODS_DIR, mod, "mod.txt"), "r") as f:
            mod_definition = json.load(f)
        
        if "updates" not in mod_definition:
            continue

        meta = [{
            "ident" : mod_definition["updates"][0]["identifier"],
            "hash" : hash_mod(mod)
        }]
        
        with open(os.path.join(OUTPUT_DIR, meta[0]["ident"] + ".meta.json"), "w") as f:
            json.dump(meta, f, indent=4)

if __name__ == "__main__":
    main()