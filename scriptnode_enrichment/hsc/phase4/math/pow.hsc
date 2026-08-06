#!/usr/bin/env hise-cli run
# math.pow: inspect a non-negative value before and after the exponent transform.

/hise playground open
/builder
reset

add ScriptFX as "ExponentCurveShaper"
set ExponentCurveShaper.network "exponent_curve_shaper"
/exit

/dsp
cd ExponentCurveShaper
add math.add as "SeedValue"
set SeedValue.Value 0.25
add analyse.specs as "InputSpecs"
add math.pow as "PowerShape"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set PowerShape.NodeColour 0xFF2F80ED
set PowerShape.Comment "**Exponent shaper** - Raises non-negative samples to a power; fractional powers need non-negative input."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
