---
id: envelope.flex_ahdsr.script-envelope-flex-ahdsr
node: envelope.flex_ahdsr
domain: scriptnode
category: dsp-network
title: Flexible AHDSR Script Envelope
summary: Shapes a constant control signal with selectable trigger, note, or loop behavior.
useCase: Use this when an envelope needs selectable modes and flexible segment timing.
difficulty: intermediate
aliases:
  - flexible ahdsr script envelope
tags:
  - envelope
  - voice-lifecycle
  - scriptnode
relatedNodes:
  - envelope.flex_ahdsr
  - envelope.voice_manager
  - math.fill1
networkName: script_envelope_flex_ahdsr
moduleType: ScriptEnvelopeModulator
moduleId: ScriptEnvelopeFlexAhdsr
parameters:
  Mode: Trigger, note, or loop mode.
  Attack: Attack time.
  Decay: Decay time.
  Sustain: Sustain level.
  Release: Release time.
---
scriptnode example: envelope.flex_ahdsr

Script Envelope loop contour

An advanced AHDSR envelope with per-segment curve shaping, three playback modes, and a draggable graph UI.

Context:
  A HISE Sine Wave Generator needs a custom envelope that can behave like a standard note envelope, a one-shot trigger envelope, or a looping contour. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.flex_ahdsr` reshapes according to its Mode and curve parameters.

Use this when:
  Demonstrate how `envelope.flex_ahdsr` creates custom Script Envelope outputs with per-segment curve shaping and Trigger, Note, and Loop playback modes.

Graph:
```text
script_envelope_flex_ahdsr
  EnvelopeSeed          math.fill1
  FlexEnvelope          envelope.flex_ahdsr
  VoiceKill             envelope.voice_manager
```

Host:
  Module: ScriptEnvelopeFlexAhdsr
  Network: script_envelope_flex_ahdsr
  Host context: Script Envelope
  Additional builder steps applied: topology and lifecycle setup from Phase 2.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: math.fill1, envelope.voice_manager
  `math.fill1` provides the static modulation source for the Script Envelope output. `envelope.voice_manager` is included as a lifecycle contrast, but cannot be connected directly because `envelope.flex_ahdsr` does not expose a Gate output.

Public controls:
  - Mode -> `FlexEnvelope.Mode` matched
  - Target range before connection: `[Trigger, Note, Loop]`
  - Macro range: `[Trigger, Note, Loop]`
  - Default: `Note`
  - Attack -> `FlexEnvelope.Attack` matched
  - Target range before connection: `[1, 250]`
  - Macro range: `[1, 250]`
  - Default: `5`
  - Decay -> `FlexEnvelope.Decay` matched
  - Target range before connection: `[20, 800]`
  - Macro range: `[20, 800]`
  - Default: `100`
  - Sustain -> `FlexEnvelope.Sustain` matched
  - Target range before connection: `[0.2, 0.9]`
  - Macro range: `[0.2, 0.9]`
  - Default: `0.5`
  - Release -> `FlexEnvelope.Release` matched
  - Target range before connection: `[40, 1200]`
  - Macro range: `[40, 1200]`
  - Default: `300`

Verified connections:
  - Public parameter connections match the Phase 4 script.
  - Lifecycle output connections were verified live where available.

Key rules:
  - Preserve the verified polyphonic lifecycle context.

Common mistakes:
  - Trigger mode skips the sustain phase: In Trigger mode the envelope runs from attack through to release in one continuous pass, regardless of note-off timing. This is useful for percussive sounds but not for sustained notes.
  - AttackLevel cannot be lower than Sustain: The envelope enforces AttackLevel >= Sustain to maintain a coherent shape where the decay always moves downward.
  - No modulation slots for envelope parameters: The flex_ahdsr currently lacks modulation slots for its parameters. The author has acknowledged this limitation.
  - Do not set envelope parameters from the Interface script: The Interface script should always be deferred. Setting envelope parameters from a deferred script will produce a HISE runtime error. Use a dedicated MIDI processor for realtime manipulation.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id ScriptEnvelopeFlexAhdsr --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module ScriptEnvelopeFlexAhdsr --network script_envelope_flex_ahdsr --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type envelope.flex_ahdsr --id FlexEnvelope --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Mode --range "0,2" --default 1 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Attack --range "1,250" --default 5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Decay --range "20,800" --default 100 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Sustain --range "0.2,0.9" --default 0.5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Release --range "40,1200" --default 300 --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Mode --target FlexEnvelope --param Mode --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Attack --target FlexEnvelope --param Attack --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Decay --target FlexEnvelope --param Decay --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Sustain --target FlexEnvelope --param Sustain --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Release --target FlexEnvelope --param Release --matched --agent
```
