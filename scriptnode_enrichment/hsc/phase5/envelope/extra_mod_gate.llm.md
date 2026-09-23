---
id: envelope.extra_mod_gate.extra-mod-cleanup
node: envelope.extra_mod_gate
domain: scriptnode
category: dsp-network
title: Extra modulation voice cleanup
summary: Pairs an extra modulation value with its per-voice active state in a polyphonic effect.
useCase: Use this when a Polyphonic Script FX consumes an extra modulation chain and must clean up released voices.
difficulty: advanced
aliases:
  - extra modulation voice cleanup
tags:
  - envelope
  - voice-lifecycle
  - scriptnode
relatedNodes:
  - envelope.extra_mod_gate
  - envelope.voice_manager
  - math.fill1
networkName: extra_mod_cleanup
moduleType: PolyScriptFX
moduleId: ExtraModCleanup
parameters:
  ModInput: Root parameter registered for combined external modulation slot 0.
---
scriptnode example: envelope.extra_mod_gate

Extra modulation chain cleanup

Outputs a binary gate signal reflecting whether an extra modulation chain's envelope is still active for the current voice.

Context:
  A polyphonic Script FX uses an extra modulation slot to drive a modulatable container parameter inside the DSP network. `envelope.extra_mod_gate` monitors the same extra modulation chain and kills the voice only after that extra envelope has finished its release.

Use this when:
  Demonstrate how `envelope.extra_mod_gate` monitors an extra modulation chain and provides the binary Gate signal needed for voice lifecycle management.

Graph:
```text
extra_mod_cleanup
  ExtraModHost          container.modchain
    ExtraModValue       core.extra_mod
    ExtraEnvelopeGate   envelope.extra_mod_gate
    VoiceKill           envelope.voice_manager
```

Host:
  Module: ExtraModCleanup
  Network: extra_mod_cleanup
  Host context: PolyScriptFX
  Additional builder steps applied: topology and lifecycle setup from Phase 2.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: container.modchain, core.extra_mod, envelope.voice_manager
  Optional: core.gain, filters.svf_eq
  `container.modchain` provides the internal modulation context, `core.extra_mod` provides the continuous modulation value from the same extra chain, and `envelope.extra_mod_gate` provides the matching lifecycle gate. `envelope.voice_manager` performs the actual voice reset.

Public controls:
  - ModInput -> external modulation slot `0`
  - Target range before connection: `[0, 1]`
  - Macro range: `[0, 1]`
  - Default: `1`
  - External modulation mode: `Combined`

Verified connections:
  - Public parameter connections match the Phase 4 script.
  - Lifecycle output connections were verified live where available.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EffectHost --agent
hise-cli builder add --type PolyScriptFX --id ExtraModCleanup --parent EffectHost --chain "FX Chain" --agent
hise-cli builder set --module ExtraModCleanup --network extra_mod_cleanup --agent
hise-cli dsp create_parameter --module ExtraModCleanup --container extra_mod_cleanup --id ModInput --range "0,1" --default 1 --external-modulation Combined --agent
hise-cli dsp add --module ExtraModCleanup --type container.modchain --id ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type core.extra_mod --id ExtraModValue --parent ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type envelope.extra_mod_gate --id ExtraEnvelopeGate --parent ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type envelope.voice_manager --id VoiceKill --parent ExtraModHost --agent
hise-cli dsp connect --module ExtraModCleanup --source ExtraEnvelopeGate --target VoiceKill --param 'Kill Voice' --agent
```

Key rules:
  - Register the externally modulatable root parameter before adding core.extra_mod.
  - With HISE_NUM_SCRIPTNODE_FX_MODS=1, both nodes must use slot 0.
