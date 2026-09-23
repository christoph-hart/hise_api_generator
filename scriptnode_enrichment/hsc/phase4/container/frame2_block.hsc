/hise playground open
/builder
reset
add ScriptFX as "MidiTunedStereoResonator"
set MidiTunedStereoResonator.network "midi_tuned_stereo_resonator"

/exit

/dsp
cd MidiTunedStereoResonator
add container.midichain as "MidiContext"
# Compact self-contained noise-burst exciter.
add container.chain as "Exciter" to MidiContext
set Exciter.IsVertical false
add core.oscillator as "ExciterNoise" to Exciter
add envelope.ahdsr as "ExciterEnvelope" to Exciter
add container.frame2_block as "StereoFrames" to MidiContext

add control.midi as "NoteFrequency" to StereoFrames
add control.pma_unscaled as "FrequencyHz" to StereoFrames
add control.converter as "PeriodMs" to StereoFrames
add control.pma_unscaled as "LeftPeriod" to StereoFrames
add control.pma_unscaled as "RightPeriod" to StereoFrames
add template.feedback_delay as "ResonantLoop" to StereoFrames

# Replace the template delay with independent fractional stereo delays.
remove ResonantLoop_delay
add container.multi as "StereoDelays" to ResonantLoop
add jdsp.jdelay_cubic as "LeftDelay" to StereoDelays
add jdsp.jdelay_cubic as "RightDelay" to StereoDelays
add filters.one_pole as "LoopDamping" to ResonantLoop
set ResonantLoop_fb_out.index 0
set StereoDelays.index 1
set LoopDamping.index 2
# The feedback send must remain last so it captures the delayed and damped signal.
set ResonantLoop_fb_in.index 3

set ExciterNoise.Mode 4
set ExciterNoise.Gain 0.25
set ExciterEnvelope.Attack 0
set ExciterEnvelope.Hold 1
set ExciterEnvelope.Decay 8
set ExciterEnvelope.Sustain 0
set ExciterEnvelope.Release 5
set ExciterEnvelope.NumParameters 3

# Frequency mode emits note Hz divided by 20000, so restore raw Hertz before Freq2Ms conversion.
set NoteFrequency.Mode Frequency
set FrequencyHz.Multiply.range [0, 20000]
set FrequencyHz.Multiply 20000
set PeriodMs.Mode Freq2Ms
set LeftPeriod.Multiply.range [0, 2]
set LeftPeriod.Multiply 0.998
set RightPeriod.Multiply.range [0, 2]
set RightPeriod.Multiply 1.002
set LeftDelay.Limit 30
set LeftDelay.DelayTime.range [0, 30]
set RightDelay.Limit 30
set RightDelay.DelayTime.range [0, 30]

connect NoteFrequency to FrequencyHz.Value
connect FrequencyHz to PeriodMs.Value
connect PeriodMs to LeftPeriod.Value
connect PeriodMs to RightPeriod.Value
connect LeftPeriod to LeftDelay.DelayTime
connect RightPeriod to RightDelay.DelayTime

set LoopDamping.Frequency.range [500, 12000], LoopDamping.Frequency.middlePosition 3000
set LoopDamping.Frequency 6000
set LoopDamping.Smoothing 0
set ResonantLoop_fb_out.Feedback.range [0, 0.995]
set ResonantLoop_fb_out.Feedback 0.985
create_parameter midi_tuned_stereo_resonator.Feedback [0, 0.995] default 0.985
create_parameter midi_tuned_stereo_resonator.Damping [500, 12000] default 6000 middlePosition 3000
connect midi_tuned_stereo_resonator.Feedback to ResonantLoop_fb_out.Feedback matched
connect midi_tuned_stereo_resonator.Damping to LoopDamping.Frequency matched

# Interpreted stereo frame feedback is expensive; compile this network to C++ for practical use.
set midi_tuned_stereo_resonator.Comment "**CPU warning** - Interpreted stereo frame feedback is expensive. Compile this network to a C++ node before practical use."
set StereoFrames.NodeColour 0xFF8E44AD
set StereoFrames.Comment "**MIDI-tuned stereo resonator** - One-sample frame feedback creates a simple Karplus-Strong-style decay."
set MidiContext.NodeColour 0xFF7F6A91
set Exciter.NodeColour 0xFF7F6A91
set ExciterNoise.NodeColour 0xFF7F6A91
set ExciterEnvelope.NodeColour 0xFF7F6A91
set NoteFrequency.NodeColour 0xFF7F6A91
set FrequencyHz.Folded true
set PeriodMs.Folded true
set LeftPeriod.Folded true
set RightPeriod.Folded true
set ResonantLoop_fb_out.Folded true
set ResonantLoop_fb_in.Folded true
/exit
