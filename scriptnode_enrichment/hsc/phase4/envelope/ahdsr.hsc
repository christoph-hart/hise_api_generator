#!/usr/bin/env hise-cli run
# envelope.ahdsr: standard custom Script Envelope with voice cleanup.
/hise playground open
/builder
reset
add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "ScriptEnvelopeAhdsr" to EnvelopeHost."Gain Modulation"
set ScriptEnvelopeAhdsr.network "script_envelope_ahdsr"
/exit
/dsp
cd ScriptEnvelopeAhdsr
add math.fill1 as "EnvelopeSeed"
add envelope.ahdsr as "MainEnvelope"
set MainEnvelope.Attack.range [1, 200]
set MainEnvelope.Attack 10
set MainEnvelope.Decay.range [40, 800]
set MainEnvelope.Decay 300
set MainEnvelope.Sustain.range [0.2, 0.9]
set MainEnvelope.Sustain 0.5
set MainEnvelope.Release.range [20, 500]
set MainEnvelope.Release 160
add envelope.voice_manager as "VoiceKill"
create_parameter script_envelope_ahdsr.Attack [1, 200] default 10
create_parameter script_envelope_ahdsr.Decay [40, 800] default 300
create_parameter script_envelope_ahdsr.Sustain [0.2, 0.9] default 0.5
create_parameter script_envelope_ahdsr.Release [20, 500] default 160
connect script_envelope_ahdsr.Attack to MainEnvelope.Attack matched
connect script_envelope_ahdsr.Decay to MainEnvelope.Decay matched
connect script_envelope_ahdsr.Sustain to MainEnvelope.Sustain matched
connect script_envelope_ahdsr.Release to MainEnvelope.Release matched
connect MainEnvelope.Gate to VoiceKill."Kill Voice"
set MainEnvelope.NodeColour 0xFF8E44AD
set EnvelopeSeed.NodeColour 0xFF7F6A91
set VoiceKill.NodeColour 0xFF7F6A91
/exit
