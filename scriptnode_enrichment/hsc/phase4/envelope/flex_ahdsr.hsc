/hise playground open
/builder
reset
add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "ScriptEnvelopeFlexAhdsr" to EnvelopeHost."Gain Modulation"
set ScriptEnvelopeFlexAhdsr.network "script_envelope_flex_ahdsr"
/exit
/dsp
cd ScriptEnvelopeFlexAhdsr
add math.fill1 as "EnvelopeSeed"
add envelope.flex_ahdsr as "FlexEnvelope"
set FlexEnvelope.Mode.range [0,2]
set FlexEnvelope.Mode 1
set FlexEnvelope.Attack.range [1,250]
set FlexEnvelope.Attack 5
set FlexEnvelope.Decay.range [20,800]
set FlexEnvelope.Decay 100
set FlexEnvelope.Sustain.range [0.2,0.9]
set FlexEnvelope.Sustain 0.5
set FlexEnvelope.Release.range [40,1200]
set FlexEnvelope.Release 300
add envelope.voice_manager as "VoiceKill"
create_parameter script_envelope_flex_ahdsr.Mode [0,2] default 1
create_parameter script_envelope_flex_ahdsr.Attack [1,250] default 5
create_parameter script_envelope_flex_ahdsr.Decay [20,800] default 100
create_parameter script_envelope_flex_ahdsr.Sustain [0.2,0.9] default 0.5
create_parameter script_envelope_flex_ahdsr.Release [40,1200] default 300
connect script_envelope_flex_ahdsr.Mode to FlexEnvelope.Mode matched
connect script_envelope_flex_ahdsr.Attack to FlexEnvelope.Attack matched
connect script_envelope_flex_ahdsr.Decay to FlexEnvelope.Decay matched
connect script_envelope_flex_ahdsr.Sustain to FlexEnvelope.Sustain matched
connect script_envelope_flex_ahdsr.Release to FlexEnvelope.Release matched
/exit
