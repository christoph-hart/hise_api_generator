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
// Title: Connecting a global LFO modulator to a cable
const var builder = Synth.createBuilder();
builder.clear();
var gmcIndex = builder.create(builder.SoundGenerators.GlobalModulatorContainer,
                              "GMC1", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.LFO, "TestLFO", gmcIndex, 1);
builder.flush();

// Context: A GlobalModulatorContainer hosts shared modulators
// (LFOs, envelopes, velocity, etc.) whose output can be
// distributed to any part of the project via cables.

const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("LfoMod");

// Connect the LFO to this cable. The modulator must be
// a child of a GlobalModulatorContainer.
cable.connectToGlobalModulator("TestLFO", true);
// test
const var th = Engine.createTransportHandler();
th.startInternalClock(0);
reg v1 = 0.0;
reg v2 = 0.0;
/compile

# Verify
/wait 200ms
/expect (v1 = cable.getValueNormalised()) || true is true
/wait 800ms
/expect (v2 = cable.getValueNormalised()) || true is true
/expect Math.abs(v1 - v2) > 0.01 is true
/exit
// end test
