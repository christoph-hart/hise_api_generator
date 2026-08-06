#!/usr/bin/env hise-cli run
# math.sin: convert a slow 0..1 ramp into a sine-shaped display curve.

/hise playground open
/builder
reset

add ScriptFX as "RampToSineConverter"
set RampToSineConverter.network "ramp_to_sine_converter"
/exit

/dsp
cd RampToSineConverter
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.pi as "RadianScale"
add math.sin as "SineShape"
add math.sig2mod as "DisplayRange"
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

set SineShape.NodeColour 0xFF2F80ED
set SineShape.Comment "**Sine converter** - Turns a ramp phase into a sine-shaped modulation curve."
set RadianScale.NodeColour 0xFF6F8FAF
set DisplayRange.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
