---
id: fx.haas.voice-haas-scatter
node: fx.haas
domain: scriptnode
category: dsp-network
title: Per-voice stereo scatter
summary: Uses fx.haas in a PolyScriptFX to give each note a stable random Haas stereo position.
useCase: Use this when each active voice should receive its own stereo placement without amplitude panning.
difficulty: intermediate
networkName: voice_haas_scatter
moduleType: PolyScriptFX
moduleId: VoiceHaasScatter
tags:
  - haas
  - stereo
  - polyphonic
  - random
aliases:
  - per-voice haas panner
  - random stereo scatter
relatedNodes:
  - fx.haas
  - control.voice_bang
  - control.random
  - control.bipolar
parameters:
  Spread: Public root parameter matched to SpreadScale.Scale.
  StereoScatter.Position: Driven by the centred random modulation path.
---

scriptnode example: fx.haas

Per-voice stereo scatter.
Use this to randomise the Haas stereo position of each note in a polyphonic voice effect.

Graph:
```text
voice_haas_scatter
  NoteTrigger      control.voice_bang
  VoicePosition    control.random
  SpreadScale      control.bipolar
  StereoScatter    fx.haas
```

Host:
  Module: `VoiceHaasScatter`
  Type: `PolyScriptFX`
  Network: `voice_haas_scatter`
  Routing: default stereo, hosted in `VoiceSource` SineSynth `FX Chain`
  Builder setup: add a `SineSynth` named `VoiceSource`, then add `PolyScriptFX` as `VoiceHaasScatter` to `VoiceSource."FX Chain"`.

Support nodes:
  Required: `control.voice_bang`, `control.random`, `control.bipolar`

Key rules:
  - Use `PolyScriptFX`, not `ScriptFX`; `control.voice_bang` requires a polyphonic voice context.
  - `control.voice_bang` triggers `control.random` once per note-on.
  - `control.bipolar` centres the random value around the middle and lets the public `Spread` parameter scale the width.
  - Do not connect `Spread` directly to `fx.haas.Position`; that would replace the random per-voice position instead of scaling it.
  - `fx.haas` requires stereo input and delays one channel rather than changing amplitude balance.

Public controls:
  - `Spread` -> `SpreadScale.Scale`, matched, range `0..1`, default `0.65`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id VoiceSource --agent
hise-cli builder add --type PolyScriptFX --id VoiceHaasScatter --parent VoiceSource --chain "FX Chain" --agent
hise-cli builder set --module VoiceHaasScatter --network voice_haas_scatter --agent
hise-cli dsp add --module VoiceHaasScatter --type control.voice_bang --id NoteTrigger --agent
hise-cli dsp set --module VoiceHaasScatter --node NoteTrigger --param Value --value 1 --agent
hise-cli dsp add --module VoiceHaasScatter --type control.random --id VoicePosition --agent
hise-cli dsp add --module VoiceHaasScatter --type control.bipolar --id SpreadScale --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param Scale --range "0,1" --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param Scale --value 0.65 --agent
hise-cli dsp add --module VoiceHaasScatter --type fx.haas --id StereoScatter --agent
hise-cli dsp create_parameter --module VoiceHaasScatter --container voice_haas_scatter --id Spread --range "0,1" --default 0.65 --agent
hise-cli dsp connect --module VoiceHaasScatter --source NoteTrigger --target VoicePosition --param Value --agent
hise-cli dsp connect --module VoiceHaasScatter --source VoicePosition --target SpreadScale --param Value --agent
hise-cli dsp connect --module VoiceHaasScatter --source voice_haas_scatter --source-param Spread --target SpreadScale --param Scale --matched --agent
hise-cli dsp connect --module VoiceHaasScatter --source SpreadScale --target StereoScatter --param Position --agent
hise-cli dsp set --module VoiceHaasScatter --node StereoScatter --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module VoiceHaasScatter --node NoteTrigger --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module VoiceHaasScatter --node VoicePosition --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param NodeColour --value 0xFF6F8FAF --agent
```
