#!/usr/bin/env hise-cli run
# math.mod2sig: inspect a known unipolar value before and after conversion to bipolar range.

/hise playground open
/builder
reset

add ScriptFX as "UnipolarToBipolar"
set UnipolarToBipolar.network "unipolar_to_bipolar"
/exit

/dsp
cd UnipolarToBipolar
add math.add as "SeedValue"
set SeedValue.Value 0.25
add analyse.specs as "InputSpecs"
add math.mod2sig as "RangeConverter"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set RangeConverter.NodeColour 0xFF2F80ED
set RangeConverter.Comment "**Modulation to signal** - Maps a 0..1 modulation value into the bipolar -1..1 range."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
