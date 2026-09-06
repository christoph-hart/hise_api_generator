---
id: envelope.global_mod_gate.global-mod-cleanup
node: envelope.global_mod_gate
domain: scriptnode
category: dsp-network
title: Global envelope voice cleanup
summary: Reads a global envelope value and its active state for voice lifecycle management.
useCase: Use this when a Script Envelope follows an envelope hosted by a Global Modulator Container.
difficulty: advanced
aliases:
  - global envelope voice cleanup
tags:
  - envelope
  - voice-lifecycle
  - scriptnode
relatedNodes:
  - envelope.global_mod_gate
  - envelope.voice_manager
  - math.fill1
networkName: global_mod_cleanup
moduleType: ScriptEnvelopeModulator
moduleId: GlobalModCleanup
parameters:
  Index: Both global nodes select the first hosted envelope at index 0.
---
scriptnode example: envelope.global_mod_gate

Global envelope voice cleanup

Outputs a binary gate signal reflecting whether a global modulator's envelope is still active for the current voice.

Context:
  A custom control-signal network uses a GlobalModulatorContainer envelope as the shared contour for several synchronized sound generators. The scriptnode graph reads the continuous global modulator value elsewhere, but needs a matching gate signal to stop each voice when that global envelope has released.

Use this when:
  Demonstrate how `envelope.global_mod_gate` turns the selected global modulator's per-voice active state into a binary Gate signal for `envelope.voice_manager`.

Graph:
```text
global_mod_cleanup
  GlobalModValue        core.global_mod
  GlobalEnvelopeGate    envelope.global_mod_gate
  VoiceKill             envelope.voice_manager
```

Host:
  Module: GlobalModCleanup
  Network: global_mod_cleanup
  Host context: Script Envelope
  Additional builder steps applied: topology and lifecycle setup from Phase 2.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: core.global_mod, envelope.voice_manager
  Optional: math.fill1
  `core.global_mod` is the continuous-value companion that makes the shared global envelope context concrete. `envelope.voice_manager` consumes the binary gate and performs the actual voice reset.

Public controls:
  - None

Verified connections:
  - Public parameter connections match the Phase 4 script.
  - Lifecycle output connections were verified live where available.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type GlobalModulatorContainer --id GlobalSource --agent
hise-cli builder add --type AHDSR --id GlobalEnvelope --parent GlobalSource --chain "Global Modulators" --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id GlobalModCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module GlobalModCleanup --network global_mod_cleanup --agent
hise-cli dsp add --module GlobalModCleanup --type core.global_mod --id GlobalModValue --agent
hise-cli dsp add --module GlobalModCleanup --type envelope.global_mod_gate --id GlobalEnvelopeGate --agent
hise-cli dsp add --module GlobalModCleanup --type envelope.voice_manager --id VoiceKill --agent
```

Key rules:
  - Keep both global nodes on index 0 so they reference the same envelope.
  - Create the global modulation source before its consumer.
