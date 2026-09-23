/hise playground open
/builder
reset
add ScriptSynth as "SnappyFilterEnvelope"
set SnappyFilterEnvelope.network "snappy_filter_envelope"

# The Scriptnode Synthesiser root already supplies MIDI and voice context, so no extra midichain is required.
# Sixteen samples is the maximum child chunk size; a final remainder may be shorter.
/exit

/dsp
cd SnappyFilterEnvelope
add container.fix16_block as "SixteenSampleVoice"
add core.oscillator as "SawVoice" to SixteenSampleVoice
add envelope.ahdsr as "FilterEnvelope" to SixteenSampleVoice
add filters.svf as "SnappyLowPass" to SixteenSampleVoice
add envelope.voice_manager as "VoiceLifecycle" to SixteenSampleVoice

set SawVoice.Mode 1
set SawVoice.Gain 0.125
set FilterEnvelope.Attack 1
set FilterEnvelope.Hold 0
set FilterEnvelope.Decay 300
set FilterEnvelope.Sustain 0.5
set FilterEnvelope.Release 50
set FilterEnvelope.NumParameters 2

# Smoothing must be zero or filter interpolation will hide the sixteen-sample envelope updates.
set SnappyLowPass.Frequency.range [120, 12000], SnappyLowPass.Frequency.middlePosition 1000
set SnappyLowPass.Frequency 120
set SnappyLowPass.Q 0.8
set SnappyLowPass.Smoothing 0
connect FilterEnvelope.0 to SnappyLowPass.Frequency
# Use the envelope Gate output, not CV, for voice cleanup.
connect FilterEnvelope.1 to VoiceLifecycle."Kill Voice"

set SixteenSampleVoice.NodeColour 0xFF2F80ED
set SixteenSampleVoice.Comment "**Snappy filter envelope** - Sixteen-sample chunks provide fast cutoff updates without the iteration cost of eight-sample pitch modulation."
set SawVoice.NodeColour 0xFF6F8FAF
set FilterEnvelope.NodeColour 0xFF6F8FAF
set FilterEnvelope.Comment "The Scriptnode Synthesiser root already supplies MIDI and voice context; a redundant midichain is unnecessary."
set SnappyLowPass.NodeColour 0xFF6F8FAF
set SnappyLowPass.Comment "Smoothing must remain at zero so interpolation does not hide the sixteen-sample envelope updates."
set VoiceLifecycle.NodeColour 0xFF6F8FAF
set VoiceLifecycle.Comment "The envelope Gate output kills each voice after release; do not connect the CV output here."
set VoiceLifecycle.Folded true
/exit
