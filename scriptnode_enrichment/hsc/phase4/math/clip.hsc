#!/usr/bin/env hise-cli run
# math.clip: shape a slow ramp with a visible symmetric hard-clipping limit.

/hise playground open
/builder
reset

add ScriptFX as "HardClipShaper"
set HardClipShaper.network "hard_clip_shaper"
/exit

/dsp
cd HardClipShaper
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.add as "RampOffset"
set RampOffset.Value 0
add math.clip as "HardClipper"
set HardClipper.Value.range [0.1, 0.6]
set HardClipper.Value 0.35
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter hard_clip_shaper.ClipLimit [0.1, 0.6] default 0.35
connect hard_clip_shaper.ClipLimit to HardClipper.Value matched

set HardClipper.NodeColour 0xFF2F80ED
set HardClipper.Comment "**Hard clipper** - Truncates the ramp at a symmetric signal limit."
set SlowRamp.NodeColour 0xFF6F8FAF
set RampOffset.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
