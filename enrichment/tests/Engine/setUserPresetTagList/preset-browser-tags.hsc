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
// Title: Configuring preset browser tags at initialization
// Context: Call setUserPresetTagList during onInit to define the
// tag categories that appear in the preset browser filter panel.
// Tags should reflect the sonic categories of the preset library.

Engine.setUserPresetTagList([
    "Bass",
    "Lead",
    "Pad",
    "Sequenced",
    "Mono",
    "Orchestral",
    "Synth",
    "Dark",
    "Epic"
]);
// test
/compile

# Verify
/expect Engine.getUptime() >= 0 is true
/exit
// end test
