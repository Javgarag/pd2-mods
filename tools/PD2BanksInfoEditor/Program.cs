using DieselEngineFormats.BNK;

namespace PD2BanksInfoEditor
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine("Usage: <.banksinfo file>");
                return;
            }

            if (!File.Exists(args[0])) {
                Console.WriteLine("File does not exist; run the tool with the path to your existing_banks.banksinfo!");
                return;
            }

            BanksInfoEditor editor = new(args[0]);
            editor.MainMenu();
        }
    }

    class BanksInfoEditor
    {
        public BanksInfo BanksInfoObject { get; set; }
        public string FilePath { get; set; }

        public BanksInfoEditor(string file)
        {
            FilePath = file;
            BanksInfoObject = new BanksInfo(file);
        }

        public void MainMenu()
        {
            Console.Clear();
            Console.WriteLine("Options:");
            Console.WriteLine("\t[1] SHOW contents");
            Console.WriteLine("\t[2] EDIT contents");
            Console.WriteLine("\n\t[3] Exit");

            var optionChosen = Console.ReadKey(intercept: true);

            if (optionChosen.KeyChar == '1')
            {
                DisplayContentsMenu();
                return;
            } 
            else if (optionChosen.KeyChar == '2')
            {
                DisplayEditMode();
                return;
            }
            else if (optionChosen.KeyChar == '3')
            {
                return;
            }

            MainMenu();
        }

        private void AnyKeyListener()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();

            MainMenu();
        }

        private void AnyKeyListenerEditing()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();

            DisplayEditMode();
        }

        private void DisplayContentsMenu()
        {
            Console.Clear();
            Console.WriteLine("Select content type:");
            Console.WriteLine("\t[1] Soundbank paths");
            Console.WriteLine("\t[2] File lookup table");

            var optionChosen = Console.ReadKey(intercept: true);

            if (optionChosen.KeyChar == '1')
            {
                DisplaySoundbanks();
                return;
            } 
            else if (optionChosen.KeyChar == '2')
            {
                DisplayLookupTable();
                return;
            }

            DisplayContentsMenu();
        }

        private void DisplaySoundbanks()
        {
            Console.WriteLine("Soundbanks:");

            foreach (var soundbank in BanksInfoObject.Soundbanks)
            {
                Console.WriteLine(soundbank);
            }

            AnyKeyListener();
        }

        private void DisplayLookupTable()
        {
            Console.WriteLine("Lookup Table:");
            Console.WriteLine("ID\t|\tName\t|\tHashed ID");

            foreach (var value in BanksInfoObject.SoundLookups)
            {
                Console.WriteLine(value.Key + "\t\t" + (value.Value.Item1 ?? value.Key.ToString()) + "\t\t" + value.Value.Item2);
            }

            Console.WriteLine("\nFirst row is the key corresponding to the FNV hash of the name. Second row is the stringified name of the file without extension. Third row is the Idstring hash (lookup8) corresponding to the filepath.");
            Console.WriteLine("Example: 'npc_russian_thugs' has a FNV hash of '427227690', while its referenced filepath, 'soundbanks/npc_russian_thugs', has the Idstring hash of 'fedee307ef0a878e'.");

            AnyKeyListener();
        }

        private void DisplayEditMode()
        {
            Console.Clear();
            Console.WriteLine("EDIT:");
            Console.WriteLine("\t[1] Add Object");
            Console.WriteLine("\t[2] Remove Object");
            Console.WriteLine("\n\t[3] Save Changes and return");
            Console.WriteLine("\t[4] Discard Changes and return");

            var optionChosen = Console.ReadKey(intercept: true);

            if (optionChosen.KeyChar == '1')
            {
                AddObject();
                return;
            }
            else if (optionChosen.KeyChar == '2')
            {
                RemoveObject();
                return;
            }
            else if (optionChosen.KeyChar == '3')
            {
                using (FileStream str = new FileStream(FilePath, FileMode.Open))
                {
                    using (BinaryWriter bw = new BinaryWriter(str))
                    {
                        BanksInfoObject.WriteFile(bw);
                        Console.WriteLine("Success!");
                        MainMenu();
                    }
                }
                return;
            }
            else if (optionChosen.KeyChar == '4')
            {
                MainMenu();
                return;
            }

            DisplayEditMode();
        }

        private void AddObject()
        {
            string? nameString = "";
            while (nameString == "")
            {
                Console.WriteLine("\nName of the file that should be added: ");
                nameString = Console.ReadLine();
            }

            string? pathString = "";
            while (pathString == "")
            {
                Console.WriteLine("Path to the file that should be added, without extension (e.g: 'soundbanks/streamed/npc_biker_thugs/13495836'): ");
                pathString = Console.ReadLine();
            }

            char? isStream = '?';
            while (isStream == '?')
            {
                Console.WriteLine("Is the file a .stream file? [Y/N]: ");
                isStream = char.ToLowerInvariant(Console.ReadKey(intercept: true).KeyChar);
            }

            char? isBank = '?';
            if (isStream == 'n')
            {
                while (isBank == '?')
                {
                    Console.WriteLine("Is the file a .bnk file? [Y/N]: ");
                    isBank = char.ToLowerInvariant(Console.ReadKey(intercept: true).KeyChar);
                }
            }

            BanksInfoObject.AddObject(nameString, pathString, isStream == 'y' ? true : false, isBank == 'y' ? true : false);
            AnyKeyListenerEditing();
        }

        private void RemoveObject()
        {
            string? nameString = "";
            while (nameString == "")
            {
                Console.WriteLine("\nName of the file that should be de-referenced: ");
                nameString = Console.ReadLine();
            }

            char? isStream = '?';
            while (isStream == '?')
            {
                Console.WriteLine("Is the file a .stream file? [Y/N]: ");
                isStream = char.ToLowerInvariant(Console.ReadKey(intercept: true).KeyChar);
            }

            char? isBank = '?';
            if (isStream == 'n')
            {
                while (isBank == '?')
                {
                    Console.WriteLine("Is the file a .bnk file? [Y/N]: ");
                    isBank = char.ToLowerInvariant(Console.ReadKey(intercept: true).KeyChar);
                }
            }

            string bankPath = "";
            if (isBank == 'y')
            {
                while (bankPath == "")
                {
                    Console.WriteLine("Path to the soundbank: ");
                    bankPath = Console.ReadLine();
                }
            }

            BanksInfoObject.RemoveObject(nameString, isStream == 'y' ? true : false, isBank == 'y' ? bankPath : null);
            AnyKeyListenerEditing();
        }
    }
}