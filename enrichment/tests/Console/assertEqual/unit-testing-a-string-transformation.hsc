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
// Title: Unit-testing a string transformation function
// Context: assertEqual works well for inline unit tests that run
// during init and are stripped in exported builds.

inline function transformName(name, oldMode, newMode)
{
    local modeNames = ["Low", "Mid", "High", "Full"];
    local oldName = modeNames[oldMode];
    local newName = modeNames[newMode];
    
    // Find and replace the mode name (handle numbered suffixes)
    if (name.indexOf(oldName) >= 0)
        return name.replace(oldName, newName);
    
    return name;
}

Console.assertEqual(transformName("Drive Low1", 0, 3), "Drive Full1");
Console.assertEqual(transformName("Drive Full9", 3, 0), "Drive Low9");
Console.assertEqual(transformName("Mixer 2 PanMid", 1, 3), "Mixer 2 PanFull");
// test
/compile

# Verify
/expect typeof(transformName) is "object"
/exit
// end test
