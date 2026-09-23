/hise playground open
/builder
reset
add ScriptFX as "SidechainDynamicMidCut"
set SidechainDynamicMidCut.network "sidechain_dynamic_mid_cut"

# Thirty-two samples is the maximum child chunk size and is a practical envelope-follower cadence.
/exit

/dsp
cd SidechainDynamicMidCut
add container.fix32_block as "ThirtyTwoSampleDucker"
# This creates and later discards an internal auxiliary pair; it is not an external DAW sidechain input.
add container.sidechain as "InternalSidechain" to ThirtyTwoSampleDucker
add container.multi as "ChannelSlices" to InternalSidechain
# Intentionally empty: channels 0-1 pass unchanged into the dynamic EQ.
add container.chain as "MainAudio" to ChannelSlices
add container.no_midi as "KeyDetector" to ChannelSlices
add core.oscillator as "KeyOscillator" to KeyDetector
add dynamics.envelope_follower as "KeyFollower" to KeyDetector
# Value carries raw negative dB; Multiply receives the normalised follower amount.
add control.pma_unscaled as "CutDepthPMA" to KeyDetector
# Keep the EQ after ChannelSlices so key analysis completes before each EQ chunk.
add filters.svf_eq as "DynamicMidEQ" to InternalSidechain

set KeyOscillator.Frequency.range [0.5, 8]
set KeyOscillator.Frequency 2
set KeyFollower.Attack 10
set KeyFollower.Release 150
set KeyFollower.ProcessSignal 0
set CutDepthPMA.Multiply.range [0, 1]

set DynamicMidEQ.Mode 4
set DynamicMidEQ.Frequency 1800
set DynamicMidEQ.Q 2
# EQ smoothing must remain zero so the follower and fixed-block cadence remain authoritative.
set DynamicMidEQ.Smoothing 0
set DynamicMidEQ.Gain.range [0, -18], DynamicMidEQ.Gain.stepSize 0.1

create_parameter sidechain_dynamic_mid_cut.MaxCut [-18, 0] default -9 stepSize 0.1
connect sidechain_dynamic_mid_cut.MaxCut to CutDepthPMA.Value
connect KeyFollower to CutDepthPMA.Multiply
connect CutDepthPMA to DynamicMidEQ.Gain

set ThirtyTwoSampleDucker.NodeColour 0xFF2F80ED
set ThirtyTwoSampleDucker.Comment "**Sidechain dynamic mid cut** - Thirty-two-sample chunks provide a practical envelope-follower cadence for frequency ducking."
set InternalSidechain.NodeColour 0xFF6F8FAF
set InternalSidechain.Comment "Creates an internal auxiliary pair for teaching; this is not an external DAW sidechain input."
set ChannelSlices.NodeColour 0xFF6F8FAF
set MainAudio.NodeColour 0xFF6F8FAF
set MainAudio.Comment "Intentionally empty: channels 0-1 pass unchanged before the dynamic EQ."
set KeyDetector.NodeColour 0xFF6F8FAF
set KeyOscillator.NodeColour 0xFF6F8FAF
set KeyFollower.NodeColour 0xFF6F8FAF
set CutDepthPMA.NodeColour 0xFF6F8FAF
set CutDepthPMA.Comment "Multiplies raw negative MaxCut dB by the normalised key envelope."
set DynamicMidEQ.NodeColour 0xFF6F8FAF
set DynamicMidEQ.Comment "Placed after channel slicing so key analysis updates Gain before each EQ chunk; Smoothing remains zero."
set MainAudio.Folded true
/exit
