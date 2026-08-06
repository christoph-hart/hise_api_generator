#!/usr/bin/env hise-cli run
# math.sig2mod: compare a bipolar oscillator directly and after conversion to modulation range.

/hise playground open
/builder
reset

add ScriptFX as "AudioToModulation"
set AudioToModulation.network "audio_to_modulation"
/exit

/dsp
cd AudioToModulation
add core.oscillator as "SlowOscillator"
set SlowOscillator.Mode 4
set SlowOscillator.Frequency 20
add core.peak as "SourcePeak"
add math.sig2mod as "RangeConverter"
add core.peak as "ConvertedPeak"
add math.clear as "SignalClear"

set RangeConverter.NodeColour 0xFF2F80ED
set RangeConverter.Comment "**Signal to modulation** - Converts bipolar signal values into the 0..1 modulation range."
set SourcePeak.NodeColour 0xFF6F8FAF
set ConvertedPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
