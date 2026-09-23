/hise playground open
/builder
reset
add ScriptSynth as "ThreeLevelPhaseModulation"
set ThreeLevelPhaseModulation.network "three_level_phase_modulation"

# One multi child receives the complete stereo slice. Adding a second child would reduce each slice to one channel.
/exit

/dsp
cd ThreeLevelPhaseModulation
add container.multi as "ChannelAllocator"
add container.framex_block as "DynamicFrames" to ChannelAllocator
set DynamicFrames.IsVertical false

# Horizontal frame layout containing four vertical serial stage groups.
add container.chain as "OSC1" to DynamicFrames
set OSC1.IsVertical true
add container.chain as "OSC2" to DynamicFrames
set OSC2.IsVertical true
add container.chain as "OSC3" to DynamicFrames
set OSC3.IsVertical true
add container.chain as "ENV" to DynamicFrames
set ENV.IsVertical true

# Oscillator stage 1 clears host input and generates the first phase modulator.
add math.clear as "InputClear" to OSC1
add core.oscillator as "Sine1" to OSC1

# sig2mod maps -1..1 to 0..1 before peak, avoiding absolute-value folding at zero.
add math.sig2mod as "Normalise1" to OSC2
add core.peak as "Peak1" to OSC2
add math.clear as "Clear1" to OSC2
add core.oscillator as "Sine2" to OSC2

add math.sig2mod as "Normalise2" to OSC3
add core.peak as "Peak2" to OSC3
add math.clear as "Clear2" to OSC3
add core.oscillator as "Sine3" to OSC3

add envelope.simple_ar as "OutputEnvelope" to ENV
add envelope.voice_manager as "VoiceLifecycle" to ENV
# mono2stereo copies channel 0 to channel 1 in the existing stereo synth context.
add core.mono2stereo as "StereoOutput"

# MIDI supplies each oscillator base frequency; static ratios define the PM structure.
set Sine1."Freq Ratio".range [0.5, 2], Sine1."Freq Ratio".middlePosition 1
set Sine1."Freq Ratio" 2
set Sine2."Freq Ratio".range [0.5, 2], Sine2."Freq Ratio".middlePosition 1
set Sine2."Freq Ratio" 0.5
set Sine3."Freq Ratio".range [0.5, 2], Sine3."Freq Ratio".middlePosition 1
set Sine3."Freq Ratio" 1
set Sine3.Gain 0.15
set OutputEnvelope.Attack 5
set OutputEnvelope.Release 80

connect Peak1 to Sine2.Phase
connect Peak2 to Sine3.Phase
connect OutputEnvelope.1 to VoiceLifecycle."Kill Voice"

# Comments explain channel adaptation, signal conversion, voice lifetime, and output behavior at the nodes they constrain.
set three_level_phase_modulation.Comment "**CPU warning** - Polyphonic interpreted framex processing is extremely expensive. Compile this network to C++ for practical use."
set ChannelAllocator.NodeColour 0xFF7F6A91
set ChannelAllocator.Comment "With one child, DynamicFrames inherits both stereo channels. Add a second multi child and its frame width becomes one channel."
set DynamicFrames.NodeColour 0xFF8E44AD
set DynamicFrames.Comment "Horizontal layout presents four vertical serial stages; framex still processes every inherited channel one sample at a time."
set OSC1.NodeColour 0xFF7F6A91
set OSC1.Comment "Clear host audio, then generate the 2.0-ratio first phase modulator."
set OSC2.NodeColour 0xFF7F6A91
set OSC2.Comment "sig2mod preserves the bipolar sine shape as 0..1 phase control before peak exports it; clear then starts the 0.5-ratio oscillator."
set OSC3.NodeColour 0xFF7F6A91
set OSC3.Comment "The second normalized phase signal drives the 1.0-ratio carrier; intermediate audio is cleared first."
set ENV.NodeColour 0xFF7F6A91
set ENV.Comment "The AR envelope shapes output and its Gate output releases the polyphonic voice."
set StereoOutput.NodeColour 0xFF7F6A91
set StereoOutput.Comment "Copies channel 0 to channel 1, preserving dual-mono output whether framex receives one or two channels."

set InputClear.Folded true
set Normalise1.Folded true
set Peak1.Folded true
set Clear1.Folded true
set Normalise2.Folded true
set Peak2.Folded true
set Clear2.Folded true
set VoiceLifecycle.Folded true
/exit
