#!/usr/bin/env hise-cli run
# math.div: wrap a slow ramp and normalize it with the same positive public control.
# Zero and negative divisors are intentionally excluded because math.div outputs silence there.

/hise playground open
/builder
reset

add ScriptFX as "WrappedRampNormalizer"
set WrappedRampNormalizer.network "wrapped_ramp_normalizer"
/exit

/dsp
cd WrappedRampNormalizer
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime.range [250, 4000], SlowRamp.PeriodTime.stepSize 1
set SlowRamp.PeriodTime 1000
add math.fmod as "WrapStage"
set WrapStage.Value.range [0.2, 1], WrapStage.Value 1
add math.div as "NormalizeStage"
set NormalizeStage.Value.range [0.2, 1], NormalizeStage.Value 1
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter wrapped_ramp_normalizer.WrapAmount [0.2, 1] default 1
connect wrapped_ramp_normalizer.WrapAmount to WrapStage.Value matched
connect wrapped_ramp_normalizer.WrapAmount to NormalizeStage.Value matched

set NormalizeStage.NodeColour 0xFF2F80ED
set NormalizeStage.Comment "**Ramp normalizer** - Divides the wrapped ramp by the same positive amount used for wrapping."
set WrapStage.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
