// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Context: Defensive pattern for loading optional images (e.g., from
// expansion packs) where the file may not exist.

const var laf = Content.createLocalLookAndFeel();

laf.loadImage("{PROJECT_FOLDER}background.png", "bg");

// loadImage prints a console warning but does not throw if missing.
// Use isImageLoaded() to verify before referencing in draw functions.
if (!laf.isImageLoaded("bg"))
    Console.print("Warning: background image not found");
// test
/compile

# Verify
/expect laf.isImageLoaded("bg") is 0
/exit
// end test
