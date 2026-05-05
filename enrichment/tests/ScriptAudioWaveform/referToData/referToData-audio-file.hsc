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
// Title: Connect waveform to a ScriptAudioFile handle
const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
const var af = Engine.createAndRegisterAudioFile(0);
wf.referToData(af);
// test
/compile

# Verify
/expect af.getNumSamples() is 0
/expect wf.getRangeEnd() is 0
/exit
// end test
