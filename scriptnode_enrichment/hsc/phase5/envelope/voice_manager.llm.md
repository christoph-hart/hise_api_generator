---
id: envelope.voice_manager.gate-based-voice-cleanup
node: envelope.voice_manager
domain: scriptnode
category: dsp-network
title: Gate-based voice cleanup
summary: Uses an AHDSR gate output to terminate a Script Envelope voice after release.
useCase: Use this to connect explicit envelope lifecycle state to voice termination.
difficulty: beginner
aliases:
  - gate-based voice cleanup
tags:
  - envelope
  - voice-lifecycle
  - scriptnode
relatedNodes:
  - envelope.voice_manager
  - envelope.voice_manager
  - math.fill1
networkName: gate_based_voice_cleanup
moduleType: ScriptEnvelopeModulator
moduleId: GateBasedVoiceCleanup
parameters:
  Kill Voice: Control input that terminates the current voice below 0.5.
---
scriptnode example: envelope.voice_manager

Gate-based voice cleanup

Sends a voice reset message when the input value drops below 0.5, providing gate-based voice lifecycle control.

Context:
  A HISE Sine Wave Generator is controlled by a custom Script Envelope module. Inside the Script Envelope, `math.fill1` is shaped by `envelope.ahdsr`, and the AHDSR Gate output is wired into `voice_manager` so the voice stops after the generated envelope has released.

Use this when:
  Demonstrate that `envelope.voice_manager` does not shape audio; it kills the current voice when a connected gate source drives Kill Voice below 0.5.

Graph:
```text
gate_based_voice_cleanup
  EnvelopeSeed          math.fill1
  MainEnvelope          envelope.ahdsr
  VoiceKill             envelope.voice_manager
```

Host:
  Module: GateBasedVoiceCleanup
  Network: gate_based_voice_cleanup
  Host context: Script Envelope
  Additional builder steps applied: topology and lifecycle setup from Phase 2.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: math.fill1, envelope.ahdsr
  `math.fill1` provides the constant Script Envelope signal, and `envelope.ahdsr` provides the Gate modulation source that makes `voice_manager` useful.

Public controls:
  - None

Verified connections:
  - Public parameter connections match the Phase 4 script.
  - Lifecycle output connections were verified live where available.

Key rules:
  - Preserve the verified polyphonic lifecycle context.

Common mistakes:
  - Connect an envelope Gate output to Kill Voice: The default value of 1.0 means no voice is ever killed. The node only acts when a modulation source drives the value below 0.5.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id GateBasedVoiceCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module GateBasedVoiceCleanup --network gate_based_voice_cleanup --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type envelope.ahdsr --id MainEnvelope --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type envelope.voice_manager --id VoiceKill --agent
```
