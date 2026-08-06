#!/usr/bin/env hise-cli run
# math.fmod: wrap a slow ramp into repeated segments and normalize them with math.div.

/hise playground open
/builder
reset

add ScriptFX as "WrappedRampRepeater"
set WrappedRampRepeater.network "wrapped_ramp_repeater"
/exit

/dsp
cd WrappedRampRepeater
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.fmod as "WrapStage"
set WrapStage.Value.range [0.2, 1], WrapStage.Value 1
add math.div as "NormalizeStage"
set NormalizeStage.Value.range [0.2, 1], NormalizeStage.Value 1
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter wrapped_ramp_repeater.WrapAmount [0.2, 1] default 1
connect wrapped_ramp_repeater.WrapAmount to WrapStage.Value matched
connect wrapped_ramp_repeater.WrapAmount to NormalizeStage.Value matched

set WrapStage.NodeColour 0xFF2F80ED
set WrapStage.Comment "**Wrapped repeater** - Repeats a ramp with a positive floating-point modulus."
set NormalizeStage.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
