/hise playground open
/builder
reset
add ScriptFX as "EventRasterVibrato"
set EventRasterVibrato.network "event_raster_vibrato"

# Eight samples mirrors HISE_EVENT_RASTER and is the maximum child chunk size; a final remainder can be shorter.
/exit

/dsp
cd EventRasterVibrato
add container.fix8_block as "EightSampleVibrato"
add container.modchain as "VibratoControl" to EightSampleVibrato
# MIDI isolation prevents played notes from retuning the fixed-rate LFO.
add container.no_midi as "MidiIsolation" to VibratoControl
add core.oscillator as "TriangleLfo" to MidiIsolation
add math.sig2mod as "NormaliseLfo" to MidiIsolation
add core.peak as "LfoValue" to MidiIsolation
add control.bipolar as "VibratoDepth" to VibratoControl
# Sine mode reveals subtle stepped-pitch sidebands that saw harmonics would mask.
add core.oscillator as "AudibleTone" to EightSampleVibrato

set TriangleLfo.Mode 2
set TriangleLfo.Frequency.range [0.5, 8]
set TriangleLfo.Frequency 5
set AudibleTone.Mode 0
set AudibleTone.Frequency 220
set AudibleTone.Gain 0.125
# Reciprocal frequency-ratio bounds create symmetric plus or minus 20-cent pitch excursion.
set AudibleTone."Freq Ratio".range [0.9885140204, 1.0116194403], AudibleTone."Freq Ratio".middlePosition 1

connect LfoValue to VibratoDepth.Value
connect VibratoDepth to AudibleTone."Freq Ratio"

# Set the Scale target range before matching. A matched connection can copy the target range back to the root parameter.
set VibratoDepth.Scale.range [0, 1]
create_parameter event_raster_vibrato.Intensity [0, 1] default 1
connect event_raster_vibrato.Intensity to VibratoDepth.Scale matched

set EightSampleVibrato.NodeColour 0xFF2F80ED
set EightSampleVibrato.Comment "**Event-raster vibrato** - Eight-sample chunks mirror HISE_EVENT_RASTER for high-resolution pitch modulation."
set VibratoControl.NodeColour 0xFF6F8FAF
set MidiIsolation.NodeColour 0xFF6F8FAF
set MidiIsolation.Comment "Blocks MIDI from retuning the fixed-rate triangle LFO."
set TriangleLfo.NodeColour 0xFF6F8FAF
set NormaliseLfo.NodeColour 0xFF6F8FAF
set LfoValue.NodeColour 0xFF6F8FAF
set VibratoDepth.NodeColour 0xFF6F8FAF
set VibratoDepth.Comment "Set Scale to 0..1 before matching Intensity; matched connections can copy the target range back to the root parameter."
set AudibleTone.NodeColour 0xFF6F8FAF
set AudibleTone.Comment "Sine mode exposes subtle stepped-pitch sidebands that saw harmonics would mask; the ratio range is exactly plus or minus 20 cents."
set NormaliseLfo.Folded true
/exit
