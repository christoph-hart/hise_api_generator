#!/usr/bin/env hise-cli run
# math.tanh: shape a slow ramp with a public soft-saturation drive value.

/hise playground open
/builder
reset

add ScriptFX as "SoftSaturationShaper"
set SoftSaturationShaper.network "soft_saturation_shaper"
/exit

/dsp
cd SoftSaturationShaper
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.tanh as "SoftClipper"
set SoftClipper.Value.range [0.4, 1]
set SoftClipper.Value 0.75
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter soft_saturation_shaper.Drive [0.4, 1] default 0.75
connect soft_saturation_shaper.Drive to SoftClipper.Value matched

set SoftClipper.NodeColour 0xFF2F80ED
set SoftClipper.Comment "**Soft saturation** - Rounds peaks with a tanh transfer curve."
set SlowRamp.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
