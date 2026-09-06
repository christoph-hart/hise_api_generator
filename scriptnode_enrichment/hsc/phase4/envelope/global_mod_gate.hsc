/hise playground open
/builder
reset
add GlobalModulatorContainer as "GlobalSource"
add AHDSR as "GlobalEnvelope" to GlobalSource."Global Modulators"
add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "GlobalModCleanup" to EnvelopeHost."Gain Modulation"
set GlobalModCleanup.network "global_mod_cleanup"
/exit
/dsp
cd GlobalModCleanup
add core.global_mod as "GlobalModValue"
set GlobalModValue.Index 0
add envelope.global_mod_gate as "GlobalEnvelopeGate"
set GlobalEnvelopeGate.Index 0
add envelope.voice_manager as "VoiceKill"
connect GlobalEnvelopeGate to VoiceKill."Kill Voice"
set GlobalEnvelopeGate.NodeColour 0xFF8E44AD
set GlobalModValue.NodeColour 0xFF7F6A91
set VoiceKill.NodeColour 0xFF7F6A91
/exit
