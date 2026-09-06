/hise playground open
/builder
reset
add SineSynth as "EffectHost"
add PolyScriptFX as "ExtraModCleanup" to EffectHost."FX Chain"
set ExtraModCleanup.network "extra_mod_cleanup"
/exit
/dsp
cd ExtraModCleanup
create_parameter extra_mod_cleanup.ModInput [0,1] default 1 ExternalModulation Combined
add container.modchain as "ExtraModHost"
add core.extra_mod as "ExtraModValue" to ExtraModHost
set ExtraModValue.Index 0
set ExtraModValue.ProcessSignal 1
add envelope.extra_mod_gate as "ExtraEnvelopeGate" to ExtraModHost
set ExtraEnvelopeGate.Index 0
add envelope.voice_manager as "VoiceKill" to ExtraModHost
connect ExtraEnvelopeGate to VoiceKill."Kill Voice"
set ExtraEnvelopeGate.NodeColour 0xFF8E44AD
set ExtraModValue.NodeColour 0xFF7F6A91
set VoiceKill.NodeColour 0xFF7F6A91
/exit
