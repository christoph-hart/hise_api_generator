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
// Title: Update-then-extract pattern in a timer callback
// Context: For-in gives live references -- modify properties in-place,
// then bulk-extract the updated values with copy().

const var f = Engine.createFixObjectFactory({
    "value": 0.0,
    "active": false
});

const var NUM_SLOTS = 4;
const var slots = f.createArray(NUM_SLOTS);
const var valueBuf = Buffer.create(NUM_SLOTS);

// Initialize with non-zero values so the decay is observable
slots[0].value = 1.0;
slots[1].value = 0.8;
slots[2].value = 0.6;
slots[3].value = 0.4;

// Simulate decay: scale each element's value, then extract
for (obj in slots)
    obj.value *= 0.5;

slots.copy("value", valueBuf);

// valueBuf now contains the decayed values as a flat float array
Console.print(valueBuf[0]); // 0.5 (1.0 * 0.5)
Console.print(valueBuf[3]); // 0.2 (0.4 * 0.5)
// test
/compile

# Verify
/expect valueBuf[0] is 0.5
/expect valueBuf[1] is 0.4
/expect valueBuf[3] is 0.2
/exit
// end test
