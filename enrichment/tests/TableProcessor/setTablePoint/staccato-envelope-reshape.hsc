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
// Title: Reshaping a table envelope for staccato articulation
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.TableEnvelope, "StaccatoEnvelope", ss, builder.ChainIndexes.Gain);
builder.flush();

// Context: When switching to staccato mode, the table envelope is rebuilt to
// create a sharp attack spike followed by silence.
const var envelope = Synth.getModulator("StaccatoEnvelope");

// asTableProcessor() returns undefined if the modulator has no table
const var tp = envelope.asTableProcessor();

if (isDefined(tp))
{
    // Set attack time on the modulator itself
    envelope.setAttribute(envelope.Attack, 200);
    
    // Build a spike shape: silent start, sharp peak at 3%, silent end
    tp.reset(0);
    tp.setTablePoint(0, 0, 0, 0, 0.5);    // start silent
    tp.setTablePoint(0, 1, 1, 0, 0.4);    // end silent (curve 0.4 for slight concavity)
    tp.addTablePoint(0, 0.03, 1);          // sharp peak near the start
}
// test
/compile

# Verify
/expect tp.getTable(0).getTableValueNormalised(0.0) is 0.0
/expect tp.getTable(0).getTableValueNormalised(0.03) > 0.8 is true
/expect tp.getTable(0).getTableValueNormalised(1.0) is 0.0
/exit
// end test
