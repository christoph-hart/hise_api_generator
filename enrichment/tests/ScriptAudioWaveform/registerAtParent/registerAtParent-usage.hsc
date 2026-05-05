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
// Title: Register waveform data at parent and get audio file handle
const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
const var af = wf.registerAtParent(0);
// test
/compile

# Verify
/expect af.getNumSamples() is 0
/exit
// end test
