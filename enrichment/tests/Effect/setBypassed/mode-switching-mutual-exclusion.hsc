// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "LR2MS"
add SimpleGain as "MS2LR"
add SimpleGain as "MasterEQ"
add SimpleGain as "MidEQ"
add SimpleGain as "SideEQ"
/exit

/script
/callback onInit
// end setup
// Context: A mid/side EQ where selecting "Master", "Mid", or "Side" mode
// bypasses the unused EQ instances and the MS encoder/decoder.
const var msEncode = Synth.getEffect("LR2MS");
const var msDecode = Synth.getEffect("MS2LR");

const var eqs = [Synth.getEffect("MasterEQ"),
                 Synth.getEffect("MidEQ"),
                 Synth.getEffect("SideEQ")];

// index: 0 = Master (L/R), 1 = Mid, 2 = Side
inline function setEqMode(index)
{
    // MS encoding only needed for mid/side modes
    msEncode.setBypassed(index == 0);
    msDecode.setBypassed(index == 0);

    // Only the active EQ is unbypassed
    eqs[0].setBypassed(index != 0);
    eqs[1].setBypassed(index == 0);
    eqs[2].setBypassed(index == 0);
}
// test
setEqMode(1);
/compile

# Verify
/expect msEncode.isBypassed() is 0
/expect eqs[0].isBypassed() is 1
/expect eqs[1].isBypassed() is 0
/exit
// end test
