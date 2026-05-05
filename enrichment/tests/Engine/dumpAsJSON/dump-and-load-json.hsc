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
// Title: Save and load a JSON configuration file
var config = {"volume": 0.8, "mode": "stereo", "channels": 2};
Engine.dumpAsJSON(config, "myConfig.json");
var loaded = Engine.loadFromJSON("myConfig.json");
Console.print(loaded.volume);
// test
/compile

# Verify
/expect loaded.volume is 0.8
/expect loaded.mode is "stereo"
/expect loaded.channels is 2
/exit
// end test
