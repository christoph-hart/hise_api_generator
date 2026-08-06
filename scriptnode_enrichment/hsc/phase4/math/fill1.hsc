#!/usr/bin/env hise-cli run
# math.fill1: provide a constant 1.0 source for a simple envelope-style control signal.
# The Script Envelope Modulator is attached to a SineSynth host's gain modulation chain.

/hise playground open
/builder
reset

add SineSynth as "EnvelopeHost"
add ScriptEnvelopeModulator as "EnvelopeSeedSource" to EnvelopeHost."Gain Modulation"
set EnvelopeSeedSource.network "envelope_seed_source"
/exit

/dsp
cd EnvelopeSeedSource
add math.fill1 as "EnvelopeSeed"
add envelope.simple_ar as "ShapeEnvelope"
set ShapeEnvelope.Attack 10
set ShapeEnvelope.Release.range [40, 500], ShapeEnvelope.Release.stepSize 1
set ShapeEnvelope.Release 180
set ShapeEnvelope.Gate 1
add math.clear as "SignalClear"

create_parameter envelope_seed_source.Release [40, 500] default 180
connect envelope_seed_source.Release to ShapeEnvelope.Release matched

set EnvelopeSeed.NodeColour 0xFF2F80ED
set EnvelopeSeed.Comment "**Envelope seed source** - Replaces incoming audio with a constant 1.0 control signal."
set ShapeEnvelope.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
