#!/usr/bin/env hise-cli run
# math.intensity: reduce modulation depth around unity instead of scaling around zero.

/hise playground open
/builder
reset

add ScriptFX as "UnityAnchoredDepth"
set UnityAnchoredDepth.network "unity_anchored_depth"
/exit

/dsp
cd UnityAnchoredDepth
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.intensity as "UnityDepth"
set UnityDepth.Value.range [0, 1]
set UnityDepth.Value 0.4
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter unity_anchored_depth.Depth [0, 1] default 0.4
connect unity_anchored_depth.Depth to UnityDepth.Value matched

set UnityDepth.NodeColour 0xFF2F80ED
set UnityDepth.Comment "**Unity-anchored depth** - Crossfades modulation toward unity rather than multiplying around zero."
set SlowRamp.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
