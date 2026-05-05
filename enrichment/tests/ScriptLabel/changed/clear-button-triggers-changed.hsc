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
// Title: Trigger callbacks after programmatic reset
// Context: Clear a search field from a button and notify listeners

const var searchLabel = Content.addLabel("SearchField", 12, 10);
searchLabel.set("text", "");
searchLabel.set("alignment", "left");
searchLabel.set("updateEachKey", true);
searchLabel.set("saveInPreset", false);

const var clearButton = Content.addButton("ClearSearch", 220, 10);
clearButton.set("text", "Clear");

reg lastQuery = "";

inline function onSearchChange(component, value)
{
    lastQuery = component.getValue();
    Console.print("Query: " + component.getValue()); // e.g. Query: Kick
}

inline function onClear(component, value)
{
    if (value)
    {
        searchLabel.set("text", "");
        searchLabel.changed();
    }
}

searchLabel.setControlCallback(onSearchChange);
clearButton.setControlCallback(onClear);
// test
/compile

# Trigger
/ui set SearchField.value "Kick"
/ui set ClearSearch.value 1

# Verify
/expect lastQuery is ""
/exit
// end test
