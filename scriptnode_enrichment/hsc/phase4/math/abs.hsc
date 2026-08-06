#!/usr/bin/env hise-cli run
# math.abs: center and scale a slow ramp so the absolute-value fold becomes visible as a triangle shape.

/hise playground open
/builder
reset

add ScriptFX as "FoldedTriangleShaper"
set FoldedTriangleShaper.network "folded_triangle_shaper"
/exit

/dsp
cd FoldedTriangleShaper
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.add as "BipolarOffset"
set BipolarOffset.Value.range [-1, 1]
set BipolarOffset.Value -0.5
add math.mul as "BipolarScale"
set BipolarScale.Value.range [0, 2]
set BipolarScale.Value 2
add math.abs as "FoldShape"
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

set FoldShape.NodeColour 0xFF2F80ED
set FoldShape.Comment "**Absolute fold** - Reflects negative values into a non-negative triangle-like shape."
set SlowRamp.NodeColour 0xFF6F8FAF
set BipolarOffset.NodeColour 0xFF6F8FAF
set BipolarScale.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
