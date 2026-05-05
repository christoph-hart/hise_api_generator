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
// Title: Enable only MIDI channel 1, disable all others
Settings.toggleMidiChannel(0, false);
Settings.toggleMidiChannel(1, true);
var ch1 = Settings.isMidiChannelEnabled(1);
Console.print("Channel 1 enabled: " + ch1);
// test
/compile

# Verify
/expect Settings.isMidiChannelEnabled(1) is 1
/exit
// end test
