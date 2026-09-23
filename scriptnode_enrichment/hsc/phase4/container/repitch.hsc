/hise playground open
/builder
reset
add ScriptFX as "RepitchedReverbSpace"
set RepitchedReverbSpace.network "repitched_reverb_space"

/exit

/dsp
cd RepitchedReverbSpace
add template.dry_wet as "ReverbMix"
# Only the wet reverb is placed in the changed sample-rate context.
add container.repitch as "ReverbResampler" to ReverbMix_wet_path
add fx.reverb as "WetReverb" to ReverbResampler
remove ReverbMix_dummy
set ReverbResampler.index 0
# Preserve the generated wet gain as the last wet-path node.
set ReverbMix_wet_gain.index 1

set ReverbResampler.RepitchFactor.range [0.5, 2], ReverbResampler.RepitchFactor.stepSize 0, ReverbResampler.RepitchFactor.middlePosition 1
set ReverbResampler.RepitchFactor 1
set WetReverb.Size 0.7
set WetReverb.Damping 0.45
set WetReverb.Width 0.8

create_parameter repitched_reverb_space.RepitchFactor [0.5, 2] default 1 middlePosition 1
create_parameter repitched_reverb_space.Mix [0, 1] default 0.4
connect repitched_reverb_space.RepitchFactor to ReverbResampler.RepitchFactor matched
connect repitched_reverb_space.Mix to ReverbMix.DryWet matched

# Expose both inner container targets so their root cables are visible.
set ReverbMix.ShowParameters true
set ReverbResampler.ShowParameters true

set ReverbResampler.NodeColour 0xFF2F80ED
set ReverbResampler.Comment "Changes the effective sample rate seen by WetReverb. Effects-only pitch direction can seem inverted, so verify both factor endpoints by ear."
set ReverbMix.NodeColour 0xFF6F8FAF
set ReverbMix.Comment "Only the wet reverb is repitched. The dry signal remains at the host sample rate."
set WetReverb.NodeColour 0xFF6F8FAF
set WetReverb.Comment "This 100 percent wet reverb runs at the effective sample rate supplied by ReverbResampler."
set ReverbMix_wet_path.Comment "Keep ReverbMix_wet_gain last after the resampled reverb."
set repitched_reverb_space.Comment "repitch supports mono or stereo only. Additional channels pass unchanged, and unreported resampling latency rules out an uncompensated parallel path."
set ReverbMix_wet_gain.Folded true
/exit
