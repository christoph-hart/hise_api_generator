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
// Context: After creating objects or retrieving properties, assertIsDefined
// catches undefined values immediately rather than letting them propagate.

const var config = {
    "oscillator": {"type": "sine", "gain": 0.5},
    "filter": {"cutoff": 1000, "resonance": 0.7}
};

inline function validateConfig(cfg)
{
    Console.assertIsDefined(cfg.oscillator);
    Console.assertIsDefined(cfg.filter);
    Console.assertIsDefined(cfg.oscillator.type);
    Console.assertIsDefined(cfg.filter.cutoff);
}

validateConfig(config);
// test
/compile

# Verify
/expect config.oscillator.gain is 0.5
/exit
// end test
