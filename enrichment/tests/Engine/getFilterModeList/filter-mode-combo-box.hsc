// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add PolyphonicFilter as "Filter1"
/exit

# Setup: UI scaffold
/ui
add ScriptComboBox "FilterSelector" at 0 0 128 32
/exit

/script
/callback onInit
// end setup
// Context: Rather than hardcoding filter mode integers, store the
// filter mode list object and index into it from a combo box callback.
// This makes the code readable and robust against future mode additions.
const var filterModes = Engine.getFilterModeList();

// Map combo box items to specific filter modes
const var availableFilters = [
    filterModes.StateVariableLP,
    filterModes.StateVariableHP,
    filterModes.Allpass
];

const var myFilter = Synth.getEffect("Filter1");

inline function onFilterSelectorControl(component, value)
{
    if (value)
    {
        local mode = availableFilters[parseInt(value - 1)];
        myFilter.setAttribute(myFilter.Mode, mode);
    }
};

Content.getComponent("FilterSelector").setControlCallback(onFilterSelectorControl);
// test
/compile

# Verify
/expect typeof filterModes is "object"
/expect filterModes.StateVariableLP >= 0 is true
/expect availableFilters.length is 3
/exit
// end test
