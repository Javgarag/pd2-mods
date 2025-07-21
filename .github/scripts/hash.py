import hashlib, os, json

MODS_DIR = "mods"
OUTPUT_DIR = "meta_out"

def hash_mod(mod_name): # Hash mod folder according to SuperBLT specification
    file_hashes = []

    for root, _, files in os.walk(MODS_DIR + os.path.sep + mod_name):
        for file in files:
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, MODS_DIR + os.path.sep + mod_name).replace(os.path.sep, '/').lower()

            with open(full_path, "rb") as f:
                file_content = f.read()
                file_hash = hashlib.sha256(file_content).hexdigest()

            file_hashes.append((rel_path, file_hash))

    file_hashes.sort(key=lambda x: x[0])
    concatenated = "".join([h[1] for h in file_hashes])

    return hashlib.sha256(concatenated.encode("utf-8")).hexdigest()

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    mods = [d for d in os.listdir(MODS_DIR) if os.path.isdir(os.path.join(MODS_DIR, d))]

    for mod in mods:
        if not os.path.exists(os.path.join(MODS_DIR, mod, "mod.txt")):
            print("Skipping '" + mod + "' (no mod.txt)")
            continue

        print("\nProcessing: " + mod)

        with open(os.path.join(MODS_DIR, mod, "mod.txt"), "r") as f:
            mod_definition = json.load(f)
        
        if "updates" not in mod_definition:
            print("Skipped hashing (no auto-updating)")
            continue

        mod_identifier = mod_definition["updates"][0]["identifier"]
        meta = [{
            "ident" : mod_identifier,
            "hash" : hash_mod(mod),
            "patchnotes_url" : "https://github.com/Javgarag/pd2-mods/tree/main/changelogs/" + mod_identifier + ".md",
            "download_url" : "https://github.com/Javgarag/pd2-mods/releases/download/updates/" + mod_identifier + ".zip",
        }]

        print(meta[0]["hash"])
        
        with open(os.path.join(OUTPUT_DIR, meta[0]["ident"] + ".meta.json"), "w") as f:
            json.dump(meta, f, indent=4)

if __name__ == "__main__":
    main()