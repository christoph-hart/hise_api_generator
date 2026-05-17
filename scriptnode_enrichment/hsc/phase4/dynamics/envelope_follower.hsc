#!/usr/bin/env hise-cli run
# dynamics.envelope_follower: drive a dynamic midrange EQ cut from the incoming signal level.
#
# Notes for this example:
# - The follower analyses the input while leaving audio unchanged.
# - A fixed 16-sample block makes the follower-to-EQ parameter update interval deterministic.
# - control.pma_unscaled keeps MidCutDepth in raw dB and multiplies it by the follower amount.
# - EQ smoothing is disabled so the visible envelope timing comes from the envelope follower.

/builder
reset

add ScriptFX as "DynamicMidCut"
set DynamicMidCut.network "dynamic_mid_cut"
/exit

/dsp
cd DynamicMidCut

# Fixed 16-sample blocks make the exported follower-to-EQ parameter modulation interval deterministic.
add container.fix16_block as "TimingBlock"
add dynamics.envelope_follower as "InputFollower" to TimingBlock

# PMA unscaled multiplies raw depth dB by the follower amount.
add control.pma_unscaled as "CutDepthPMA" to TimingBlock
add filters.svf_eq as "HarshBandEQ" to TimingBlock

set HarshBandEQ.Mode 4
set HarshBandEQ.Frequency 2500
set HarshBandEQ.Q 2.5

# Disable EQ smoothing so InputFollower controls the envelope timing.
set HarshBandEQ.Smoothing 0

# The PMA output is already in dB, so connect it directly after setting the target range.
set HarshBandEQ.Gain.range [0, -18], HarshBandEQ.Gain.stepSize 0.1

set InputFollower.Attack.range [5, 80], InputFollower.Attack.stepSize 0.1
set InputFollower.Attack 20
set InputFollower.Release.range [40, 300], InputFollower.Release.stepSize 0.1
set InputFollower.Release 120

# Multiply is range-scaled; Value and Add are raw/unscaled inputs.
set CutDepthPMA.Multiply.range [0, 1], CutDepthPMA.Multiply.stepSize 0.0001
set CutDepthPMA.Add 0

create_parameter dynamic_mid_cut.FollowerAttack [5, 80] default 20 stepSize 0.1
create_parameter dynamic_mid_cut.FollowerRelease [40, 300] default 120 stepSize 0.1
create_parameter dynamic_mid_cut.MidCutDepth [-18, -3] default -9 stepSize 0.1
connect dynamic_mid_cut.FollowerAttack to InputFollower.Attack matched
connect dynamic_mid_cut.FollowerRelease to InputFollower.Release matched
connect dynamic_mid_cut.MidCutDepth to CutDepthPMA.Value
connect InputFollower to CutDepthPMA.Multiply
connect CutDepthPMA to HarshBandEQ.Gain

# Screenshot-oriented annotations and layout.
set InputFollower.NodeColour 0xFFE67E22
set InputFollower.Comment "**Envelope follower** - Tracks input level while leaving the audio path unchanged."

set TimingBlock.NodeColour 0xFF8F7766
set TimingBlock.Comment "Fixed 16-sample blocks make the follower-to-EQ modulation update interval deterministic."

set CutDepthPMA.NodeColour 0xFF8F7766
set CutDepthPMA.Comment "PMA unscaled multiplies raw depth dB by the follower amount."

set HarshBandEQ.NodeColour 0xFF8F7766
set HarshBandEQ.Comment "Peak EQ cuts more as the follower output rises."
/exit
