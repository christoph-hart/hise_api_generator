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
// Context: Synthesizers with a fixed set of modulation sources use
// descriptive macro names that map to the modulation architecture.

Engine.setFrontendMacros([
    "LFO1", "LFO2", "ENV1", "ENV2", "VELO", "NOTE"
]);
// test
/compile

# Verify
/expect Engine.getMacroName(1) is "LFO1"
/expect Engine.getMacroName(6) is "NOTE"
/exit
// end test
