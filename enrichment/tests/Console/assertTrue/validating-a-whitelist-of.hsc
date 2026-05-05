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
// Title: Validating a whitelist of allowed keys
// Context: When a function accepts a string key that must be one of
// a known set, assertTrue with indexOf catches typos at the call site.

const var settings = {"AutoPlay": true, "Volume": 0.8, "Quality": "High"};

inline function changeSetting(key, value)
{
    Console.assertTrue(["AutoPlay", "Volume", "Quality"].indexOf(key) != -1);
    settings[key] = value;
}

changeSetting("Volume", 0.5);
// test
/compile

# Verify
/expect settings.Volume is 0.5
/exit
// end test
