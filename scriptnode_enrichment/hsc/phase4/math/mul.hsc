#!/usr/bin/env hise-cli run
# math.mul: seed a known signal, apply public raw gain scaling, inspect both stages, then clear it.
# This is linear multiplication, not decibel-scaled gain control.

/hise playground open
/builder
reset

add ScriptFX as "ScalarGainMultiplier"
set ScalarGainMultiplier.network "scalar_gain_multiplier"
/exit

/dsp
cd ScalarGainMultiplier
add math.add as "SeedValue"
set SeedValue.Value 0.8
add analyse.specs as "InputSpecs"
add math.mul as "GainScale"
set GainScale.Value.range [0, 1], GainScale.Value.stepSize 0.01
set GainScale.Value 0.5
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

create_parameter scalar_gain_multiplier.Multiplier [0, 1] default 0.5
connect scalar_gain_multiplier.Multiplier to GainScale.Value matched

set GainScale.NodeColour 0xFF2F80ED
set GainScale.Comment "**Scalar gain multiplier** - Scales every sample by a raw linear value."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
