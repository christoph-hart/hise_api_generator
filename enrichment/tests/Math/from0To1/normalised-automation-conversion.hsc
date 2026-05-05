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
// Title: Converting normalised automation values using parameter metadata
// Context: When a plugin stores parameter ranges as JSON objects with
// MinValue/MaxValue/SkewFactor, the same object can be passed directly
// to Math.from0To1() - no manual range extraction needed.

// Parameter metadata from an automation data structure
const var paramRange = {
    "MinValue": 20.0,
    "MaxValue": 20000.0,
    "SkewFactor": 0.3
};

// Convert normalised MIDI CC value to the actual parameter value
inline function ccToParameterValue(normValue, rangeObj)
{
    local realValue = Math.from0To1(normValue, rangeObj);
    return realValue;
}

// Display the value with appropriate formatting
var normalisedInput = 0.5;
var freq = ccToParameterValue(normalisedInput, paramRange);
Console.print(freq); // Skewed frequency value, not linear midpoint
// test
/compile

# Verify
/expect freq > 20.0 && freq < 3000.0 is true
/exit
// end test
