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
const var fft = Engine.createFFT();

fft.setSpectrum2DParameters({
    "FFTSize": 10,
    "Oversampling": 4,
    "ColourScheme": 3,
    "Gamma": 80,
    "DynamicRange": 90,
    "ResamplingQuality": "High"
});

var p = fft.getSpectrum2DParameters();
Console.print(p.Gamma);
// test
/compile

# Verify
/expect-logs ["80"]
/exit
// end test
