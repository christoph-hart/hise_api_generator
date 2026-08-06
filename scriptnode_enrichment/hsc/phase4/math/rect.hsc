#!/usr/bin/env hise-cli run
# math.rect: convert a known normalized value into a fixed-threshold binary gate.

/hise playground open
/builder
reset

add ScriptFX as "ThresholdRectifier"
set ThresholdRectifier.network "threshold_rectifier"
/exit

/dsp
cd ThresholdRectifier
add math.add as "SeedValue"
set SeedValue.Value 0.25
add analyse.specs as "InputSpecs"
add math.rect as "BinaryGate"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set BinaryGate.NodeColour 0xFF2F80ED
set BinaryGate.Comment "**Threshold rectifier** - Produces a binary 0 or 1 result at the fixed 0.5 threshold."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
