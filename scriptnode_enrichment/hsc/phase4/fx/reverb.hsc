#!/usr/bin/env hise-cli run
# fx.reverb: wrap the wet-only Freeverb node in a dry/wet mixer with public room controls.

/hise playground open
/builder
reset

add ScriptFX as "WetReverbWrapper"
set WetReverbWrapper.network "wet_reverb_wrapper"
/exit

/dsp
cd WetReverbWrapper

# fx.reverb outputs wet signal only, so a practical insert needs an external dry/wet mixer.
add template.dry_wet as "RoomMix"
add fx.reverb as "RoomVerb" to RoomMix_wet_path
remove RoomMix_dummy

# Keep the reverb before the template's wet gain so the mix control scales the processed signal.
set RoomVerb.index 0
set RoomMix_wet_gain.index 1
set RoomMix.DryWet 0.35

set RoomVerb.Size.range [0.1, 0.9]
set RoomVerb.Size 0.65
set RoomVerb.Damping 0.45

create_parameter wet_reverb_wrapper.Mix [0, 1] default 0.35
create_parameter wet_reverb_wrapper.Size [0.1, 0.9] default 0.65
create_parameter wet_reverb_wrapper.Damping [0, 1] default 0.45

connect wet_reverb_wrapper.Mix to RoomMix.DryWet matched
connect wet_reverb_wrapper.Size to RoomVerb.Size matched
connect wet_reverb_wrapper.Damping to RoomVerb.Damping matched

# Expose the reliable room controls and omit Width until the setter bug is fixed.
set RoomVerb.NodeColour 0xFF2F80ED
set RoomMix.NodeColour 0xFF6F8FAF
set RoomMix_dry_wet_mixer.Folded true
set RoomMix_dry_gain.Folded true
set RoomMix_wet_gain.Folded true
/exit
