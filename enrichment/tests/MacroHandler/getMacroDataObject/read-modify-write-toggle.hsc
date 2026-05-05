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
// Title: Read-modify-write to toggle a single macro connection
const var uph = Engine.createUserPresetHandler();
uph.setUseCustomUserPresetModel(function(obj){}, function(){ return {}; }, false);
uph.setCustomAutomation([
    {"ID": "MyParam", "min": 0.0, "max": 1.0, "defaultValue": 0.5, "connections": []}
]);

// Context: A context menu action that connects or disconnects a
// parameter to/from a specific macro slot without affecting others

const var mh = Engine.createMacroHandler();
mh.setExclusiveMode(true);

const var PARAM_ID = "MyParam";
const var MACRO_SLOT = 0;

// Read current connections
var connections = mh.getMacroDataObject();

// Remove existing connection on this slot (if any)
for (item in connections)
{
    if (item.MacroIndex == MACRO_SLOT)
    {
        connections.remove(item);
        break;
    }
}

// Add new connection with custom automation target
connections.push({
    "MacroIndex": MACRO_SLOT,
    "Processor": "Interface",
    "Attribute": PARAM_ID,
    "CustomAutomation": true,
    "FullStart": 0.0,
    "FullEnd": 1.0,
    "Start": 0.0,
    "End": 1.0,
    "Inverted": false,
    "Interval": 0.0,
    "Skew": 1.0
});

// Write back the modified array
mh.setMacroDataFromObject(connections);

var result = mh.getMacroDataObject();
// test
/compile

# Verify
/expect result.length is 1
/expect result[0].MacroIndex is 0
/expect result[0].Attribute is "MyParam"
/exit
// end test
