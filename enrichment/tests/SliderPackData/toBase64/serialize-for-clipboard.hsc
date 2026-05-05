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
// Title: Serializing step sequencer data for clipboard and preset storage
// Context: A sequencer exports each channel's step data as a Base64 string
// for copy/paste and custom preset serialization.

const var spd = Engine.createAndRegisterSliderPackData(0);
spd.setNumSliders(8);
spd.setAllValues(0.0);
spd.setValue(0, 0.9);
spd.setValue(3, 0.5);

// Export to JSON-friendly format
inline function exportChannelData(data)
{
    local obj = {};

    if (hasNonZeroValues(data))
        obj.steps = data.toBase64();
    else
        obj.steps = "EMPTY";

    return obj;
}

// Check if any step has a non-zero value
inline function hasNonZeroValues(data)
{
    local buf = data.getDataAsBuffer();

    for (s in buf)
    {
        if (s != 0.0)
            return true;
    }

    return false;
}

var exported = exportChannelData(spd);
Console.print(exported.steps != "EMPTY"); // 1
// test
const var roundtrip = Engine.createAndRegisterSliderPackData(1);
roundtrip.fromBase64(exported.steps);
/compile

# Verify
/expect roundtrip.getValue(0) is 0.9
/expect roundtrip.getValue(3) is 0.5
/expect roundtrip.getNumSliders() is 8
/exit
// end test
