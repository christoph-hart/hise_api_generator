#!/usr/bin/env hise-cli run
# fx.haas: random per-voice stereo placement inside a PolyScriptFX.

/hise playground open
/builder
reset

add SineSynth as "VoiceSource"

# Use PolyScriptFX, not ScriptFX: Haas placement is per voice and needs note-on events.
add PolyScriptFX as "VoiceHaasScatter" to VoiceSource."FX Chain"
set VoiceHaasScatter.network "voice_haas_scatter"
/exit

/dsp
cd VoiceHaasScatter

add control.voice_bang as "NoteTrigger"
set NoteTrigger.Value 1
add control.random as "VoicePosition"

# Centre and scale the random value before it reaches fx.haas.Position.
add control.bipolar as "SpreadScale"
set SpreadScale.Scale.range [0, 1]
set SpreadScale.Scale 0.65

# Haas positioning is stereo delay panning, not amplitude panning.
add fx.haas as "StereoScatter"

create_parameter voice_haas_scatter.Spread [0, 1] default 0.65

connect NoteTrigger to VoicePosition.Value
connect VoicePosition to SpreadScale.Value
connect voice_haas_scatter.Spread to SpreadScale.Scale matched
connect SpreadScale to StereoScatter.Position

set StereoScatter.NodeColour 0xFF2F80ED
set NoteTrigger.NodeColour 0xFF6F8FAF
set VoicePosition.NodeColour 0xFF6F8FAF
set SpreadScale.NodeColour 0xFF6F8FAF
/exit
