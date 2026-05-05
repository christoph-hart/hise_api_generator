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
// Context: A UI button removes the automation entry for a particular CC.
// Read the array, filter out the matching entry, write back.

const var mah = Engine.createMidiAutomationHandler();

inline function removeAutomationForCC(ccNumber)
{
    local data = mah.getAutomationDataObject();

    for (i = 0; i < data.length; i++)
    {
        if (data[i].Controller == ccNumber)
        {
            data.removeElement(i);
            break;
        }
    }

    mah.setAutomationDataFromObject(data);
}

removeAutomationForCC(20);

// Verify the operation completed (data is re-read after write-back)
var dataAfter = mah.getAutomationDataObject();
// test
/compile

# Verify
/expect Array.isArray(dataAfter) is true
/expect dataAfter.length is 0
/exit
// end test
