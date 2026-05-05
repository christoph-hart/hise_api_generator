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
// Context: A sequencer stores per-channel step data as Base64 strings
// in a JSON preset. On restore, each channel's data is loaded from
// the string, with "EMPTY" as a sentinel for cleared channels.

const var spd = Engine.createAndRegisterSliderPackData(0);
spd.setNumSliders(8);
spd.setUsePreallocatedLength(8);

// Simulate preset data with Base64-encoded step values
spd.setAllValues(0.0);
spd.setValue(0, 0.9);
spd.setValue(3, 0.5);
var savedState = spd.toBase64();

// Clear and restore
spd.setAllValues(0.0);

inline function restoreChannel(data, b64)
{
    if (b64 == "EMPTY")
        data.setAllValuesWithUndo(0.0);
    else
        data.fromBase64(b64);
}

restoreChannel(spd, savedState);
Console.print(spd.getValue(0)); // 0.9
Console.print(spd.getValue(3)); // 0.5
// test
/compile

# Verify
/expect spd.getValue(0) is 0.9
/expect spd.getValue(3) is 0.5
/exit
// end test
