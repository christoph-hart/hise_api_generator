---
id: math.fmod.wrapped-ramp-repeater
node: math.fmod
domain: scriptnode
category: dsp-network
title: Wrapped ramp repeater
summary: Uses math.fmod to repeat a slow ramp and math.div to normalize the segments.
useCase: Use this for floating-point wrapping of a signal into repeating segments.
difficulty: beginner
networkName: wrapped_ramp_repeater
moduleType: ScriptFX
moduleId: WrappedRampRepeater
tags:
  - modulus
  - wrapping
  - ramp
aliases:
  - floating-point wrap
  - ramp repeater
relatedNodes:
  - math.fmod
  - math.div
  - core.ramp
  - core.peak
  - math.clear
parameters:
  WrapAmount: Shared positive wrap and normalization control.
---

scriptnode example: math.fmod

Wrapped ramp repeater.
Use this to show repeated floating-point modulus segments with a matching normalization stage.

Graph:
```text
wrapped_ramp_repeater
  SlowRamp              core.ramp
  WrapStage             math.fmod
  NormalizeStage        math.div
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `WrappedRampRepeater`
  Type: `ScriptFX`
  Network: `wrapped_ramp_repeater`
  Builder setup: add ScriptFX `WrappedRampRepeater`, then set its network.

Support nodes:
  Required: `core.ramp`, `math.div`, `core.peak`, `math.clear`

Key rules:
  - Drive `math.fmod` and `math.div` from the same positive control.
  - Avoid zero so the zero guard does not collapse the example.

Public controls:
  - `WrapAmount` -> `WrapStage.Value` and `NormalizeStage.Value`, matched, range `0.2..1`, default `1`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WrappedRampRepeater --agent
hise-cli builder set --module WrappedRampRepeater --network wrapped_ramp_repeater --agent
hise-cli dsp add --module WrappedRampRepeater --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module WrappedRampRepeater --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module WrappedRampRepeater --type math.fmod --id WrapStage --agent
hise-cli dsp set --module WrappedRampRepeater --node WrapStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampRepeater --node WrapStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampRepeater --type math.div --id NormalizeStage --agent
hise-cli dsp set --module WrappedRampRepeater --node NormalizeStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampRepeater --node NormalizeStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampRepeater --type core.peak --id OutputPeak --agent
hise-cli dsp add --module WrappedRampRepeater --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module WrappedRampRepeater --container wrapped_ramp_repeater --id WrapAmount --range "0.2,1" --default 1 --agent
hise-cli dsp connect --module WrappedRampRepeater --source wrapped_ramp_repeater --source-param WrapAmount --target WrapStage --param Value --matched --agent
hise-cli dsp connect --module WrappedRampRepeater --source wrapped_ramp_repeater --source-param WrapAmount --target NormalizeStage --param Value --matched --agent
```
