#!/usr/bin/env hise-cli run
# routing.selector: choose one of two internal stereo mic pairs, then process only the selected pair.
#
# Notes for this example:
# - The ScriptFX is explicitly routed as four internal channels, but the Master Chain still folds those
#   channels back to the normal stereo output.
# - The public MicPosition parameter uses actual channel offsets: 0 = first stereo pair, 2 = second stereo pair.
# - ChannelIndex is narrowed before connecting MicPosition, then connected with matched so the macro range
#   mirrors the meaningful target range.
# - container.multi is necessary after routing.selector: otherwise the EQ, compressor, and gain would still
#   process the whole 4-channel buffer. The multi container splits the buffer into stereo slices.
# - SelectOutput and ClearOtherChannels are left at their defaults: selected channels are copied to the front,
#   and non-selected channels are cleared.
# - Colours use 0xAARRGGBB literals so screenshot rendering is deterministic.

/builder
reset

add ScriptFX as "CabMicSelector"
set CabMicSelector.network "cab_mic_selector"

# Four internal source channels, folded back to the stereo output of HISE.
set "Master Chain".routing [0, 1, 0, 1]
set CabMicSelector.routing [0, 1, 2, 3]
/exit

/dsp
cd CabMicSelector
add routing.selector as "MicPairSelector"
set MicPairSelector.NumChannels 2
set MicPairSelector.ChannelIndex.range [0, 2], MicPairSelector.ChannelIndex.stepSize 2

# Split the post-selector buffer into stereo slices so only channels 0-1 hit the FX chain.
add container.multi as "PairSplit"
add container.chain as "SelectedPair" to PairSplit
add container.chain as "UnusedPair" to PairSplit

add filters.svf_eq as "CabToneEQ" to SelectedPair
set CabToneEQ.Mode 4
set CabToneEQ.Frequency 3500
set CabToneEQ.Q 1.2
set CabToneEQ.Gain -3

add jdsp.jcompressor as "CabGlueComp" to SelectedPair
set CabGlueComp.Treshold -18
set CabGlueComp.Ratio 3
set CabGlueComp.Attack 12
set CabGlueComp.Release 120

add core.gain as "CabMakeupGain" to SelectedPair
set CabMakeupGain.Gain.range [-24, 6], CabMakeupGain.Gain.stepSize 0.1
set CabMakeupGain.Gain 3

# Root macro: 0 selects channels 0-1, 2 selects channels 2-3.
create_parameter cab_mic_selector.MicPosition [0, 2] default 2 stepSize 2
connect cab_mic_selector.MicPosition to MicPairSelector.ChannelIndex matched

# Screenshot-oriented annotations and layout.
set MicPairSelector.NodeColour 0xFF2F80ED
set MicPairSelector.Comment "**Mic pair selector** - Dynamically routes one of two input stereo pairs into a subsequent FX chain."

set PairSplit.Comment "**Channel isolation** - Splits the 4-channel buffer into stereo slices so the FX chain only processes the selected pair on channels 0-1."

set CabToneEQ.NodeColour 0xFF6F8FAF
set CabGlueComp.NodeColour 0xFF6F8FAF

set UnusedPair.Folded true
set CabToneEQ.Folded true
set CabGlueComp.Folded true
set CabMakeupGain.Folded true
/exit
