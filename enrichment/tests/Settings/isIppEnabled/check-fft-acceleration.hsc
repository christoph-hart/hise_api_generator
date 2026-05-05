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
// Title: Check for fast FFT support across platforms
var hasFastFFT = Settings.isIppEnabled(true);
Console.print(hasFastFFT ? "Fast FFT available" : "No hardware FFT acceleration");
// test
/compile

# Verify
/expect hasFastFFT == 0 || hasFastFFT == 1 is true
/exit
// end test
