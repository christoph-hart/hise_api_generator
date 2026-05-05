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
// Title: Compressor threshold curve with inverse power mapping
// Context: Mapping a 0-1 slider to a logarithmic dB threshold
// requires a steep power curve. Using pow(x, 4.0) for the forward
// mapping and pow(x, 0.25) for the inverse keeps the conversions
// symmetrical.

inline function sliderToThreshold(value)
{
    local s = 1.0 - value;
    s = Math.pow(s, 4.0);
    s *= 0.999;
    s += 0.001;
    return Engine.getDecibelsForGainFactor(s);
}

inline function thresholdToSlider(dB)
{
    if (dB < -60.0)
        return 1.0;

    local s = Engine.getGainFactorForDecibels(dB);
    s -= 0.001;
    s /= 0.999;
    s = Math.pow(s, 0.25);  // Inverse of the forward curve
    return 1.0 - s;
}

// Round-trip test: slider -> dB -> slider should return the original value
var threshold = sliderToThreshold(0.7);
var roundTrip = thresholdToSlider(threshold);
Console.print(threshold);
Console.print(roundTrip);
// test
/compile

# Verify
/expect threshold < 0.0 is true
/expect Math.abs(roundTrip - 0.7) < 0.001 is true
/exit
// end test
