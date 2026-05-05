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
// Title: Rotating step sequencer data using the buffer reference
// Context: A sequencer "rotate" operation shifts all step values by an
// offset amount, wrapping around. Reading via getDataAsBuffer() is
// efficient for copying values, then setValueWithUndo() writes them
// back with undo support.

const var spd = Engine.createAndRegisterSliderPackData(0);
spd.setNumSliders(8);
spd.setAllValues(0.0);
spd.setValue(0, 0.9);
spd.setValue(1, 0.6);
spd.setValue(2, 0.3);

inline function rotateSteps(data, amount, limit)
{
    // Copy current values via buffer reference
    local copy = [];
    copy.reserve(limit);

    for (s in data.getDataAsBuffer())
        copy.push(s);

    // Write rotated values with undo support
    for (i = 0; i < limit; i++)
        data.setValueWithUndo(i, copy[(i + amount) % limit]);
}

rotateSteps(spd, 2, 8);

Console.print(spd.getValue(0)); // 0.3
Console.print(spd.getValue(6)); // 0.9
Console.print(spd.getValue(7)); // 0.6
// test
/compile

# Verify
/expect spd.getValue(0) is 0.3
/expect spd.getValue(6) is 0.9
/expect spd.getValue(7) is 0.6
/exit
// end test
