// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add StreamingSampler as "Sampler1"
/exit

/script
/callback onInit
// end setup
// Context: When enabling dynamics crossfade on a sampler, the table needs a
// simple linear fade-out shape. Only the two default edge points are modified.
const var tp = Synth.getTableProcessor("Sampler1");
const var sampler = Synth.getChildSynth("Sampler1");

// Enable crossfade on the sampler (attribute index for crossfade varies by module)
sampler.setAttribute(11, 1);

// Shape the crossfade: full volume at low velocity, silent at high
tp.reset(0);
tp.setTablePoint(0, 0, 0, 1.0, 0.5);   // edge point: y=1 (full)
tp.setTablePoint(0, 1, 1.0, 0.0, 0.5);  // edge point: y=0 (silent)

// Reset the second table to default
tp.reset(1);
// test
/compile

# Verify
/expect tp.getTable(0).getTableValueNormalised(0.0) is 1.0
/expect tp.getTable(0).getTableValueNormalised(1.0) is 0.0
/exit
// end test
