/hise playground open
/builder
reset
add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "GateBasedVoiceCleanup" to EnvelopeHost."Gain Modulation"
set GateBasedVoiceCleanup.network "gate_based_voice_cleanup"
/exit
/dsp
cd GateBasedVoiceCleanup
add math.fill1 as "EnvelopeSeed"
add envelope.ahdsr as "MainEnvelope"
set MainEnvelope.Attack 10
set MainEnvelope.Decay 200
set MainEnvelope.Sustain 0.5
set MainEnvelope.Release 160
add envelope.voice_manager as "VoiceKill"
connect MainEnvelope.Gate to VoiceKill."Kill Voice"
set VoiceKill.NodeColour 0xFF8E44AD
set EnvelopeSeed.NodeColour 0xFF7F6A91
set MainEnvelope.NodeColour 0xFF7F6A91
/exit
