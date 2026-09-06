#!/usr/bin/env hise-cli run
# fx.phase_delay: a six-stage PhaseFX-style feedback phaser.

/hise playground open
/builder
reset

add ScriptFX as "PhaseFXRecreation"
set PhaseFXRecreation.network "phase_fx_recreation"
/exit

/dsp
cd PhaseFXRecreation

# Keep the MIDI context outside the frame container for core.extra_mod.
# Register the external modulation slot before creating the processing context.

create_parameter phase_fx_recreation.Mix [0, 1] default 0.75
create_parameter phase_fx_recreation.Feedback [0, 1] default 0.7
create_parameter phase_fx_recreation.Frequency1 [20, 20000] default 400
create_parameter phase_fx_recreation.Frequency2 [20, 20000] default 1600
create_parameter phase_fx_recreation.ModDepth [0, 1] default 0.5 ExternalModulation Combined

add container.midichain as "MidiContext"
add container.frame2_block as "FramePhaseFX" to MidiContext

add core.extra_mod as "PhaseMod" to FramePhaseFX
set PhaseMod.Index 0

add control.minmax as "SweepRange" to FramePhaseFX
add template.dry_wet as "PhaseMix" to FramePhaseFX
add template.feedback_delay as "ResonantLoop" to PhaseMix_wet_path
remove PhaseMix_dummy
remove ResonantLoop_delay

add fx.phase_delay as "Stage1" to ResonantLoop
add fx.phase_delay as "Stage2" to ResonantLoop
add fx.phase_delay as "Stage3" to ResonantLoop
add fx.phase_delay as "Stage4" to ResonantLoop
add fx.phase_delay as "Stage5" to ResonantLoop
add fx.phase_delay as "Stage6" to ResonantLoop

# The feedback send must capture the complete allpass cascade.
set ResonantLoop_fb_in.index 7
set ResonantLoop.index 0
set PhaseMix.DryWet 0.75
set ResonantLoop_fb_out.Feedback.range [0, 0.99]
set ResonantLoop_fb_out.Feedback 0.7
set SweepRange.Minimum.range [20, 20000]
set SweepRange.Maximum.range [20, 20000]
set SweepRange.Minimum 400
set SweepRange.Maximum 1600

connect PhaseMod to SweepRange.Value
connect SweepRange to Stage1.Frequency
connect SweepRange to Stage2.Frequency
connect SweepRange to Stage3.Frequency
connect SweepRange to Stage4.Frequency
connect SweepRange to Stage5.Frequency
connect SweepRange to Stage6.Frequency
connect phase_fx_recreation.Mix to PhaseMix.DryWet matched
connect phase_fx_recreation.Feedback to ResonantLoop_fb_out.Feedback matched
connect phase_fx_recreation.Frequency1 to SweepRange.Minimum matched
connect phase_fx_recreation.Frequency2 to SweepRange.Maximum matched

set Stage1.NodeColour 0xFF2F80ED
set MidiContext.NodeColour 0xFF6F8FAF
set FramePhaseFX.NodeColour 0xFF6F8FAF
set Stage2.NodeColour 0xFF6F8FAF
set Stage3.NodeColour 0xFF6F8FAF
set Stage4.NodeColour 0xFF6F8FAF
set Stage5.NodeColour 0xFF6F8FAF
set Stage6.NodeColour 0xFF6F8FAF
set ResonantLoop.NodeColour 0xFF6F8FAF
set PhaseMix.NodeColour 0xFF6F8FAF
set PhaseMod.NodeColour 0xFF6F8FAF
set SweepRange.NodeColour 0xFF6F8FAF
/exit
