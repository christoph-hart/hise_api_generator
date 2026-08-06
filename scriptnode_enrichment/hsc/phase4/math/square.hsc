#!/usr/bin/env hise-cli run
# math.square: inspect a known value before and after the fixed x*x transform.

/hise playground open
/builder
reset

add ScriptFX as "SquaringCurveShaper"
set SquaringCurveShaper.network "squaring_curve_shaper"
/exit

/dsp
cd SquaringCurveShaper
add math.add as "SeedValue"
set SeedValue.Value 0.5
add analyse.specs as "InputSpecs"
add math.square as "SquareShape"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set SquareShape.NodeColour 0xFF2F80ED
set SquareShape.Comment "**Square shaper** - Multiplies each sample by itself; Value is unused."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
