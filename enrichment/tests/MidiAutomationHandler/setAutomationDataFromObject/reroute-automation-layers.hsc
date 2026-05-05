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
// Title: Re-route automation connections between parameter layers
// Context: When switching parameter layers (e.g., from individual layers
// to a linked "all" mode), existing CC assignments need their Attribute
// field updated to point to the new target parameter.

const var mah = Engine.createMidiAutomationHandler();

inline function transferConnections(oldSuffix, newSuffix)
{
    local data = mah.getAutomationDataObject();
    local changed = false;

    for (entry in data)
    {
        if (entry.Attribute.contains(oldSuffix))
        {
            entry.Attribute = entry.Attribute.replace(oldSuffix, newSuffix);
            changed = true;
        }
    }

    // Only write back if something actually changed
    if (changed)
        mah.setAutomationDataFromObject(data);
}

// Transfer connections from layer "A" to linked mode "All"
transferConnections(" A1", " All1");

// Verify that the handler is still functional after the operation
var verifyData = mah.getAutomationDataObject();
// test
/compile

# Verify
/expect Array.isArray(verifyData) is true
/expect verifyData.length is 0
/exit
// end test
