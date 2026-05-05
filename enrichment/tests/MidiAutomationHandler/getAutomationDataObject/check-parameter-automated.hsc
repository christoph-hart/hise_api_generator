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
// Context: Before assigning a CC to a parameter, check the current
// automation data to see if an assignment already exists.

const var mah = Engine.createMidiAutomationHandler();

inline function isParameterAutomated(attributeId)
{
    local data = mah.getAutomationDataObject();

    for (entry in data)
    {
        if (entry.Attribute == attributeId)
            return true;
    }

    return false;
}

var result = isParameterAutomated("FilterCutoff");
Console.print(result); // true if assigned, false in a fresh session
// test
/compile

# Verify
/expect result is 0
/expect Array.isArray(mah.getAutomationDataObject()) is true
/exit
// end test
