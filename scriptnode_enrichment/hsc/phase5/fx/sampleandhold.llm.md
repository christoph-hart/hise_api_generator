---
id: fx.sampleandhold.stepped-noise-texture
node: fx.sampleandhold
domain: scriptnode
category: dsp-network
title: Tempo-stepped random texture
summary: Uses a noise oscillator and sample-and-hold stage to create a controlled stepped texture.
useCase: Use this for deliberately reduced-rate random modulation or lo-fi texture.
difficulty: beginner
aliases:
  - stepped noise
  - sample hold texture
networkName: stepped_noise_texture
moduleType: ScriptFX
moduleId: SteppedNoiseTexture
tags:
  - sample-and-hold
  - noise
  - texture
relatedNodes:
  - fx.sampleandhold
  - core.oscillator
  - core.gain
parameters:
  Counter: Number of input samples held for each captured output value.
---
scriptnode example: fx.sampleandhold

Tempo-stepped random texture

Reduces the effective sample rate by holding each captured sample for a configurable number of periods.

Context:
  A sound-design insert needs stepped, low-rate movement rather than smooth modulation. A noise source or simple generated signal is reduced by `fx.sampleandhold`, then used as a visibly staircase-like random texture or control-rate modulation source.

Use this when:
  Demonstrate that `fx.sampleandhold` holds samples for a fixed Counter value, making Counter the direct control over time resolution.

Graph:
```text
stepped_noise_texture
  NoiseSource      core.oscillator
  StepHolder       fx.sampleandhold
  TextureTrim      core.gain
```

Host:
  Module: SteppedNoiseTexture
  Network: stepped_noise_texture
  Host context: Script FX
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: core.oscillator, core.gain
  Optional: control.converter, core.tempo_sync, filters.one_pole
  A noise oscillator makes the sample-hold steps obvious, gain keeps the generated texture controlled, and optional tempo conversion can map musical rates to the Counter value if the live graph can do this cleanly.

Public controls:
  - Counter -> `StepHolder.Counter` matched
  - Target range before connection: `[2, 64]`
  - Macro range: `[2, 64]`
  - Default: `16`

Verified connections:
  - `stepped_noise_texture.Counter -> StepHolder.Counter` matched

Key rules:
  - Keep Counter at 2 or above for an audible stepped texture.
  - Use gain attenuation when the noise source is used in an insert effect.

Common mistakes:
  - Counter of 1 is a pass-through: At Counter=1 every input sample is captured and output unchanged. The effect only becomes audible at Counter=2 and above.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SteppedNoiseTexture --agent
hise-cli builder set --module SteppedNoiseTexture --network stepped_noise_texture --agent
hise-cli dsp add --module SteppedNoiseTexture --type core.oscillator --id NoiseSource --agent
hise-cli dsp set --module SteppedNoiseTexture --node NoiseSource --param Mode --value 4 --agent
hise-cli dsp set --module SteppedNoiseTexture --node NoiseSource --param Gain --value 0.25 --agent
hise-cli dsp add --module SteppedNoiseTexture --type fx.sampleandhold --id StepHolder --agent
hise-cli dsp set --module SteppedNoiseTexture --node StepHolder --param Counter --range "2,64" --agent
hise-cli dsp set --module SteppedNoiseTexture --node StepHolder --param Counter --value 16 --agent
hise-cli dsp add --module SteppedNoiseTexture --type core.gain --id TextureTrim --agent
hise-cli dsp set --module SteppedNoiseTexture --node TextureTrim --param Gain --value -12 --agent
hise-cli dsp create_parameter --module SteppedNoiseTexture --container stepped_noise_texture --id Counter --range "2,64" --default 16 --agent
hise-cli dsp connect --module SteppedNoiseTexture --source stepped_noise_texture --source-param Counter --target StepHolder --param Counter --matched --agent
```
