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
// Title: Converting normalised values with different range conventions
// Scriptnode convention
var freq = Math.from0To1(0.5, {
    "MinValue": 20.0,
    "MaxValue": 20000.0,
    "SkewFactor": 0.3
});

// UI Component convention (middlePosition = centre frequency)
var freq2 = Math.from0To1(0.5, {
    "min": 20.0,
    "max": 20000.0,
    "middlePosition": 1000.0
});

Console.print(freq);
Console.print(freq2);
// test
/compile

# Verify
/expect freq > 20.0 && freq < 3000.0 is true
/expect Math.abs(freq2 - 1000.0) < 1.0 is true
/exit
// end test
