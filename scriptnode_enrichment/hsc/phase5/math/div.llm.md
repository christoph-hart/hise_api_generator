---
id: math.div.wrapped-ramp-normalizer
node: math.div
domain: scriptnode
category: dsp-network
title: Wrapped ramp normalizer
summary: Uses math.div to normalize a repeatedly wrapped ramp with a shared positive control.
useCase: Use this when a wrapped signal must be rescaled back into a predictable display range.
difficulty: beginner
networkName: wrapped_ramp_normalizer
moduleType: ScriptFX
moduleId: WrappedRampNormalizer
tags:
  - arithmetic
  - normalization
  - ramp
aliases:
  - ramp normalizer
  - wrapped signal division
relatedNodes:
  - math.div
  - math.fmod
  - core.ramp
  - core.peak
  - math.clear
parameters:
  WrapAmount: Shared positive control for WrapStage.Value and NormalizeStage.Value.
  NormalizeStage.Value: Positive divisor; zero and negative values produce silence.
---

scriptnode example: math.div

Wrapped ramp normalizer.
Use this to show `math.div` as the normalization companion to a wrapped signal. The same positive control drives both the wrap count and the divisor.

Graph:
```text
wrapped_ramp_normalizer
  SlowRamp              core.ramp
  WrapStage             math.fmod
  NormalizeStage        math.div
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `WrappedRampNormalizer`
  Type: `ScriptFX`
  Network: `wrapped_ramp_normalizer`
  Builder setup: `add ScriptFX as "WrappedRampNormalizer"`, then set its network to `wrapped_ramp_normalizer`.

Support nodes:
  Required: `core.ramp`, `math.fmod`, `core.peak`, `math.clear`

Key rules:
  - Keep the divisor positive; zero and negative values produce silence.
  - Drive wrapping and normalization from the same narrowed control.
  - Use `core.peak` to make the normalized output visible.

Public controls:
  - `WrapAmount` -> `WrapStage.Value` and `NormalizeStage.Value`, matched, range `0.2..1`, default `1`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WrappedRampNormalizer --agent
hise-cli builder set --module WrappedRampNormalizer --network wrapped_ramp_normalizer --agent
hise-cli dsp add --module WrappedRampNormalizer --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module WrappedRampNormalizer --node SlowRamp --param PeriodTime --range "250,4000" --stepSize 1 --agent
hise-cli dsp set --module WrappedRampNormalizer --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.fmod --id WrapStage --agent
hise-cli dsp set --module WrappedRampNormalizer --node WrapStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampNormalizer --node WrapStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.div --id NormalizeStage --agent
hise-cli dsp set --module WrappedRampNormalizer --node NormalizeStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampNormalizer --node NormalizeStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampNormalizer --type core.peak --id OutputPeak --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module WrappedRampNormalizer --container wrapped_ramp_normalizer --id WrapAmount --range "0.2,1" --default 1 --agent
hise-cli dsp connect --module WrappedRampNormalizer --source wrapped_ramp_normalizer --source-param WrapAmount --target WrapStage --param Value --matched --agent
hise-cli dsp connect --module WrappedRampNormalizer --source wrapped_ramp_normalizer --source-param WrapAmount --target NormalizeStage --param Value --matched --agent
```
