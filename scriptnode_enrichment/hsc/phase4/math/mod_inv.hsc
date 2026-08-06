#!/usr/bin/env hise-cli run
# math.mod_inv: inspect a known modulation value before and after its 1-x complement.

/hise playground open
/builder
reset

add ScriptFX as "ModulationInverter"
set ModulationInverter.network "modulation_inverter"
/exit

/dsp
cd ModulationInverter
add math.add as "SeedValue"
set SeedValue.Value 0.25
add analyse.specs as "InputSpecs"
add math.mod_inv as "InvertModulation"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set InvertModulation.NodeColour 0xFF2F80ED
set InvertModulation.Comment "**Modulation inverter** - Complements a unipolar value around one-half."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
