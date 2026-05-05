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
// Context: Clear the console before a multi-step operation so its
// output is easy to read without scrolling past prior noise.

const var presetList = [
    {"Name": "Preset A"},
    {"Name": "Preset B"},
    {"Name": "Preset C"}
];

inline function startBatchExport()
{
    Console.clear();
    Console.print("Starting batch export of " + presetList.length + " presets...");

    for (i = 0; i < presetList.length; i++)
    {
        Console.print("Exporting: " + presetList[i].Name);
    }

    Console.print("Batch export complete");
}

startBatchExport();
// test
/compile

# Verify
/expect-logs ["Starting batch export of 3 presets...", "Exporting: Preset A", "Exporting: Preset B", "Exporting: Preset C", "Batch export complete"]
/exit
// end test
