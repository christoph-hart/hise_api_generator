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
// Context: Create and configure combo boxes inside a namespace function that returns
// the configured component. This pattern keeps creation, styling, and callback
// assignment together for reusable selector components.

namespace Selectors
{
    inline function onSelectorChanged(component, value)
    {
        Console.print(component.getId() + ": " + parseInt(value));
    }

    inline function makeSelector(name, items, x, y)
    {
        local cb = Content.addComboBox(name, x, y);
        cb.set("width", 120);
        cb.set("height", 28);
        cb.set("items", items.join("\n"));
        cb.set("text", "Select...");
        cb.set("saveInPreset", false);
        cb.setControlCallback(onSelectorChanged);
        return cb;
    }
}

const var cbWaveform = Selectors.makeSelector("Waveform", ["Sine", "Saw", "Square"], 0, 0);
const var cbFilter = Selectors.makeSelector("FilterType", ["LP", "HP", "BP"], 140, 0);
// test
/compile

# Verify
/expect cbWaveform.get("items") is "Sine\nSaw\nSquare"
/expect cbWaveform.get("text") is "Select..."
/expect cbFilter.get("width") is 120
/exit
// end test
