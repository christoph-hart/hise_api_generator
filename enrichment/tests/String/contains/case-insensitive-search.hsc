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
// Context: A preset browser filters its list as the user types.
// Both the search term and the preset name are lowercased before
// checking, since contains() is case-sensitive.

reg searchTerm = "";

inline function onSearchChanged(text)
{
    searchTerm = text.toLowerCase();
}

inline function shouldHidePreset(presetName)
{
    if (searchTerm.length == 0)
        return false;
    
    return !presetName.toLowerCase().contains(searchTerm);
}

onSearchChanged("warm");
Console.print(shouldHidePreset("Warm Pad"));    // 0 (false - matches)
Console.print(shouldHidePreset("Bright Lead")); // 1 (true - no match)
// test
/compile

# Verify
/expect-logs ["0", "1"]
/exit
// end test
