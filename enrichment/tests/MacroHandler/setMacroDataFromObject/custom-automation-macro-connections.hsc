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
// Context: Connect macro slots to custom automation parameters defined
// through UserPresetHandler.setCustomAutomation()

const var uph = Engine.createUserPresetHandler();
const var mh = Engine.createMacroHandler();
mh.setExclusiveMode(true);

// Custom automation requires the custom user preset model
uph.setUseCustomUserPresetModel(function(obj){}, function(){ return {}; }, false);

// Custom automation must be set up before macro connections reference it
uph.setCustomAutomation([
    {"ID": "ParamX", "min": 0.0, "max": 1.0, "defaultValue": 0.5, "connections": []},
    {"ID": "ParamY", "min": 0.0, "max": 1.0, "defaultValue": 0.5, "connections": []}
]);

// Connect macro 0 -> ParamX, macro 1 -> ParamY
mh.setMacroDataFromObject([
    {
        "MacroIndex": 0,
        "Processor": "Interface",
        "Attribute": "ParamX",
        "CustomAutomation": true,
        "FullStart": 0.0,
        "FullEnd": 1.0,
        "Start": 0.0,
        "End": 1.0,
        "Inverted": false,
        "Interval": 0.0,
        "Skew": 1.0
    },
    {
        "MacroIndex": 1,
        "Processor": "Interface",
        "Attribute": "ParamY",
        "CustomAutomation": true,
        "FullStart": 0.0,
        "FullEnd": 1.0,
        "Start": 0.0,
        "End": 1.0,
        "Inverted": false,
        "Interval": 0.0,
        "Skew": 1.0
    }
]);

var result = mh.getMacroDataObject();
// test
/compile

# Verify
/expect result.length is 2
/expect result[0].MacroIndex is 0
/expect result[1].MacroIndex is 1
/exit
// end test
