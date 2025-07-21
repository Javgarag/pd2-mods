import shutil, os, json

MODS_DIR = "mods"
OUTPUT_DIR = "compressed"

def compress_mod(mod_name, ident):
    mod_path = os.path.join(MODS_DIR, mod_name)
    shutil.make_archive(
        base_name = os.path.join(OUTPUT_DIR, ident),
        format = "zip", 
        root_dir = MODS_DIR,
        base_dir = mod_name
    )

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
            print("Skipped compressing (no auto-updating)")
            continue
        
        compress_mod(mod, mod_definition["updates"][0]["identifier"])

if __name__ == "__main__":
    main()