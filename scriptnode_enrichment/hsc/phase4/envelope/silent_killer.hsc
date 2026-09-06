/hise playground open
/builder
reset
add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "SilentEnvelopeCleanup" to EnvelopeHost."Gain Modulation"
set SilentEnvelopeCleanup.network "silent_envelope_cleanup"
/exit
/dsp
cd SilentEnvelopeCleanup
add math.fill1 as "EnvelopeSeed"
add envelope.simple_ar as "ReleaseEnvelope"
set ReleaseEnvelope.Attack 10
set ReleaseEnvelope.Release 180
add envelope.silent_killer as "SilentCleanup"
create_parameter silent_envelope_cleanup.CleanupActive [0,1] default 1
connect silent_envelope_cleanup.CleanupActive to SilentCleanup.Active matched
set SilentCleanup.NodeColour 0xFF8E44AD
set EnvelopeSeed.NodeColour 0xFF7F6A91
set ReleaseEnvelope.NodeColour 0xFF7F6A91
/exit
