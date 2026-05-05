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
// Title: Loading a programmatically generated mono buffer
const var af = Engine.createAndRegisterAudioFile(0);
const var buf = Buffer.create(128);

// Fill with a sine wave
for (i = 0; i < 128; i++)
    buf[i] = Math.sin(2.0 * Math.PI * 440.0 * i / 44100.0);

af.loadBuffer(buf, 44100.0, []);
// test
/compile

# Verify
/expect af.getNumSamples() is 128
/expect af.getSampleRate() is 44100.0
/exit
// end test
