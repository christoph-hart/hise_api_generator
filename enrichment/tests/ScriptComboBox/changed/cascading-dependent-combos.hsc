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
// Title: Cascading dependent combo boxes
// Context: Three combo boxes form a hierarchy: category -> option -> variant.
// When the category changes, the dependent lists are rebuilt and changed() is called
// to propagate the selection through the callback chain.

const var categories = ["Ambience", "Chambers", "Halls"];

// Simulated data: each category has different options and variants
const var optionData = {
    "Ambience": ["Small", "Medium", "Large"],
    "Chambers": ["Bright", "Dark", "Deep"],
    "Halls":    ["Concert", "Cathedral", "Studio"]
};

const var cbCategory = Content.addComboBox("Category", 0, 0);
const var cbOption = Content.addComboBox("Option", 0, 40);

cbCategory.set("items", categories.join("\n"));
cbCategory.set("saveInPreset", false);
cbOption.set("saveInPreset", false);

var lastOptionText = "";

inline function onCategoryChanged(component, value)
{
    local category = categories[parseInt(value) - 1];
    local options = optionData[category];

    // Rebuild the dependent combo box
    cbOption.set("items", options.join("\n"));

    // Select the first option in the new list (clamp to valid 1-based range)
    cbOption.setValue(1);

    // Trigger the dependent callback so downstream logic updates
    cbOption.changed();
}

inline function onOptionChanged(component, value)
{
    lastOptionText = component.getItemText();
}

cbCategory.setControlCallback(onCategoryChanged);
cbOption.setControlCallback(onOptionChanged);
// test
/compile

# Trigger
/ui set Category.value 2

# Verify
/expect lastOptionText is "Bright"
/expect cbOption.get("items") is "Bright\nDark\nDeep"
/exit
// end test
