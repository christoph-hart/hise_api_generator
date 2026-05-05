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
// Context: Selecting a random preset from a list while avoiding
// the currently loaded preset requires a retry loop.

const var presets = ["Warm Pad", "Bright Lead", "Deep Bass", "Soft Keys"];
var lastPresetIndex = -1;

inline function loadRandomPreset()
{
    local index = Math.randInt(0, presets.length);

    // Retry until we get a different preset (up to 10 attempts)
    local attempts = 0;
    while (index == lastPresetIndex && attempts < 10)
    {
        index = Math.randInt(0, presets.length);
        attempts++;
    }

    lastPresetIndex = index;
    return presets[index];
}

var result = loadRandomPreset();
Console.print(result);
// test
/compile

# Verify
/expect lastPresetIndex >= 0 && lastPresetIndex < 4 is true
/expect presets.indexOf(result) >= 0 is true
/exit
// end test
