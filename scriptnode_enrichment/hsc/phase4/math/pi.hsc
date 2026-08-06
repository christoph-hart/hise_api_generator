#!/usr/bin/env hise-cli run
# math.pi: scale a known value by PI, convert it for display, and inspect the result.

/hise playground open
/builder
reset

add ScriptFX as "VisibleRadianScaler"
set VisibleRadianScaler.network "visible_radian_scaler"
/exit

/dsp
cd VisibleRadianScaler
add math.add as "SeedValue"
set SeedValue.Value 0.5
add math.pi as "PiScaler"
set PiScaler.Value.range [1, 2]
set PiScaler.Value 2
add math.sig2mod as "DisplayRange"
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

create_parameter visible_radian_scaler.CycleScale [1, 2] default 2
connect visible_radian_scaler.CycleScale to PiScaler.Value matched

set PiScaler.NodeColour 0xFF2F80ED
set PiScaler.Comment "**PI scaler** - Multiplies the input by PI times Value for radian-domain shaping."
set DisplayRange.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
