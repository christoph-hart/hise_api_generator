#!/usr/bin/env hise-cli run
# math.inv: seed a known signal, invert its polarity, inspect both stages, then clear it.

/hise playground open
/builder
reset

add ScriptFX as "SignalPolarityInverter"
set SignalPolarityInverter.network "signal_polarity_inverter"
/exit

/dsp
cd SignalPolarityInverter
add math.add as "SeedValue"
set SeedValue.Value 0.6
add analyse.specs as "InputSpecs"
add math.inv as "InvertPolarity"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set InvertPolarity.NodeColour 0xFF2F80ED
set InvertPolarity.Comment "**Polarity inverter** - Negates every sample to flip a bipolar signal around zero."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
