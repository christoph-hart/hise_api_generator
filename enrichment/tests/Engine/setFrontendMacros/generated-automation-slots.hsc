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
// Title: Setting up automation slots with generated names
// Context: Plugins with many automatable parameters generate macro
// names programmatically rather than hardcoding them. This pattern
// creates a numbered list of automation slot names and enables the
// macro system at initialization.

const var NUM_SLOTS = 8;

inline function initAutomationSlots()
{
    local slotIds = [];
    slotIds.reserve(NUM_SLOTS);

    for (i = 0; i < NUM_SLOTS; i++)
    {
        // Zero-pad single digits for consistent display
        local label = "Automation " + (i < 9 ? "0" : "") + (i + 1);
        slotIds.push(label);
    }

    Engine.setFrontendMacros(slotIds);
}

initAutomationSlots();
// test
/compile

# Verify
/expect Engine.getMacroName(1) is "Automation 01"
/expect Engine.getMacroName(8) is "Automation 08"
/exit
// end test
