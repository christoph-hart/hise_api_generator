#!/usr/bin/env hise-cli run
# math.sqrt: inspect a non-negative value before and after the concave root transform.

/hise playground open
/builder
reset

add ScriptFX as "RootCurveShaper"
set RootCurveShaper.network "root_curve_shaper"
/exit

/dsp
cd RootCurveShaper
add math.add as "SeedValue"
set SeedValue.Value 0.25
add analyse.specs as "InputSpecs"
add math.sqrt as "RootShape"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

set RootShape.NodeColour 0xFF2F80ED
set RootShape.Comment "**Root shaper** - Applies square root to a non-negative signal; negative inputs produce NaN."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
