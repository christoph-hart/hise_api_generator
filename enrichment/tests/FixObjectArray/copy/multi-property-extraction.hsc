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
// Context: A fixed-size object pool tracks visual elements with typed
// properties. Each timer tick updates the elements, then extracts
// property columns into Buffers for downstream consumption.

const var f = Engine.createFixObjectFactory({
    "x": 0,
    "y": 0.0,
    "seed": 0.0,
    "gain": 1.0
});

const var NUM_ELEMENTS = 4;
const var pool = f.createArray(NUM_ELEMENTS);

// Pre-allocate one Buffer per property column -- sizes must match
const var xBuf = Buffer.create(NUM_ELEMENTS);
const var yBuf = Buffer.create(NUM_ELEMENTS);
const var gainBuf = Buffer.create(NUM_ELEMENTS);

// Populate the pool
pool[0].x = 60; pool[0].y = 0.5; pool[0].gain = 0.9;
pool[1].x = 64; pool[1].y = 1.2; pool[1].gain = 0.7;
pool[2].x = 67; pool[2].y = 0.8; pool[2].gain = 0.5;
pool[3].x = 72; pool[3].y = 1.5; pool[3].gain = 0.3;

// Extract each property into its own Buffer
pool.copy("x", xBuf);
pool.copy("y", yBuf);
pool.copy("gain", gainBuf);

Console.print(xBuf[0]);    // 60.0
Console.print(gainBuf[2]); // 0.5
// test
/compile

# Verify
/expect xBuf[0] is 60.0
/expect xBuf[2] is 67.0
/expect gainBuf[2] is 0.5
/expect yBuf[1] is 1.2
/exit
// end test
