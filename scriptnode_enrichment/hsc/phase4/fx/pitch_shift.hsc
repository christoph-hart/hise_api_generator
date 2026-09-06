#!/usr/bin/env hise-cli run
# fx.pitch_shift: narrow microshift doubler in a dry/wet insert.
/hise playground open
/builder
reset
add ScriptFX as "MicroshiftDoubler"
set MicroshiftDoubler.network "microshift_doubler"
/exit
/dsp
cd MicroshiftDoubler
add template.dry_wet as "ShiftMix"
add fx.pitch_shift as "MicroPitch" to ShiftMix_wet_path
add core.gain as "WetTrim" to ShiftMix_wet_path
remove ShiftMix_dummy
set MicroPitch.FreqRatio.range [0.96, 1.04]
set MicroPitch.FreqRatio 1.015
set ShiftMix.DryWet 0.35
set MicroPitch.index 0
set WetTrim.index 1
create_parameter microshift_doubler.Mix [0, 1] default 0.35
create_parameter microshift_doubler.Ratio [0.96, 1.04] default 1.015
connect microshift_doubler.Mix to ShiftMix.DryWet matched
connect microshift_doubler.Ratio to MicroPitch.FreqRatio matched
set MicroPitch.NodeColour 0xFF2F80ED
set ShiftMix.NodeColour 0xFF6F8FAF
set WetTrim.Folded true
/exit
