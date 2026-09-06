---
id: envelope.ahdsr.script-envelope-ahdsr
node: envelope.ahdsr
domain: scriptnode
category: dsp-network
title: Custom AHDSR Script Envelope
summary: Shapes a constant control signal with an AHDSR envelope and manages voice cleanup from its Gate output.
useCase: Use this when a custom Script Envelope Modulator needs standard AHDSR controls.
difficulty: intermediate
aliases:
  - custom AHDSR
  - script envelope AHDSR
networkName: script_envelope_ahdsr
moduleType: ScriptEnvelopeModulator
moduleId: ScriptEnvelopeAhdsr
tags:
  - ahdsr
  - envelope
  - voice-management
relatedNodes:
  - envelope.ahdsr
  - math.fill1
  - envelope.voice_manager
parameters:
  Attack: Attack time.
  Decay: Decay time.
  Sustain: Sustain level.
  Release: Release time.
---
scriptnode example: envelope.ahdsr

Script Envelope AHDSR contour

A full AHDSR envelope with attack curve shaping, manual gate, and retrigger support.

Context:
  A HISE Sine Wave Generator needs a custom envelope module instead of a built-in AHDSR. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.ahdsr` shapes into the modulation output used by the audio module.

Use this when:
  Demonstrate the standard custom-envelope pattern: generate a constant modulation signal with `math.fill1`, shape it with `envelope.ahdsr`, and use the Gate output for voice cleanup.

Graph:
```text
script_envelope_ahdsr
  EnvelopeSeed          math.fill1
  MainEnvelope          envelope.ahdsr
  VoiceKill             envelope.voice_manager
```

Host:
  Module: ScriptEnvelopeAhdsr
  Network: script_envelope_ahdsr
  Host context: Script Envelope
  Additional builder steps applied: added a SineSynth host and attached the Script Envelope Modulator to its Gain Modulation chain.
  Channel/routing setup verified: default stereo control signal routing.

Support nodes:
  Required: math.fill1, envelope.voice_manager
  `math.fill1` provides the static 1.0 signal that becomes the custom envelope output. `envelope.voice_manager` is required so the Gate output teaches the standard voice lifecycle pattern.

Public controls:
  - Attack -> `MainEnvelope.Attack` matched
  - Target range before connection: `[1, 200]`
  - Macro range: `[1, 200]`
  - Default: `10`
  - Decay -> `MainEnvelope.Decay` matched
  - Target range before connection: `[40, 800]`
  - Macro range: `[40, 800]`
  - Default: `300`
  - Sustain -> `MainEnvelope.Sustain` matched
  - Target range before connection: `[0.2, 0.9]`
  - Macro range: `[0.2, 0.9]`
  - Default: `0.5`
  - Release -> `MainEnvelope.Release` matched
  - Target range before connection: `[20, 500]`
  - Macro range: `[20, 500]`
  - Default: `160`

Verified connections:
  - `script_envelope_ahdsr.Attack -> MainEnvelope.Attack` matched
  - `script_envelope_ahdsr.Decay -> MainEnvelope.Decay` matched
  - `script_envelope_ahdsr.Sustain -> MainEnvelope.Sustain` matched
  - `script_envelope_ahdsr.Release -> MainEnvelope.Release` matched
  - `MainEnvelope.Gate -> VoiceKill.Kill Voice` (HSC-only named parameter)

Key rules:
  - Use math.fill1 as the constant control source.
  - Connect MainEnvelope.Gate to VoiceKill.Kill Voice for voice cleanup.

Common mistakes:
  - Connect Gate output for voice management: The envelope multiplies the audio to silence, but HISE still renders the voice unless it receives an explicit voice reset message. The Gate output provides the signal that tells voice_manager when to stop the voice.
  - Retrigger only affects monophonic mode: In polyphonic mode every note-on starts a fresh voice with its own envelope state. The Retrigger parameter is only relevant when the node operates monophonically.
  - Monophonic mode disables voice killing: In monophonic mode the envelope loses its ability to terminate voices. The voice-kill detection that normally ensures an envelope is present in the signal chain does not work correctly with monophonic envelopes.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id ScriptEnvelopeAhdsr --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module ScriptEnvelopeAhdsr --network script_envelope_ahdsr --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type envelope.ahdsr --id MainEnvelope --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Attack --range "1,200" --default 10 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Decay --range "40,800" --default 300 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Sustain --range "0.2,0.9" --default 0.5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Release --range "20,500" --default 160 --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Attack --target MainEnvelope --param Attack --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Decay --target MainEnvelope --param Decay --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Sustain --target MainEnvelope --param Sustain --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Release --target MainEnvelope --param Release --matched --agent
```
