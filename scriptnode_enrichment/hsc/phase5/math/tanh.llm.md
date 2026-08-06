---
id: math.tanh.soft-saturation-shaper
node: math.tanh
domain: scriptnode
category: dsp-network
title: Soft saturation shaper
summary: Uses math.tanh to round a slow ramp into a soft saturation curve.
useCase: Use this for smooth soft clipping and transfer-function shaping.
difficulty: beginner
networkName: soft_saturation_shaper
moduleType: ScriptFX
moduleId: SoftSaturationShaper
tags:
  - saturation
  - soft-clipping
  - waveshaping
aliases:
  - tanh saturator
  - soft clipper
relatedNodes:
  - math.tanh
  - core.ramp
  - core.peak
  - math.clear
parameters:
  Drive: Public tanh drive control connected to SoftClipper.Value.
---

scriptnode example: math.tanh

Soft saturation shaper.
Use this to show a rounded tanh transfer curve rather than a hard clip.

Graph:
```text
soft_saturation_shaper
  SlowRamp              core.ramp
  SoftClipper           math.tanh
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `SoftSaturationShaper`
  Type: `ScriptFX`
  Network: `soft_saturation_shaper`
  Builder setup: add ScriptFX `SoftSaturationShaper`, then set its network.

Support nodes:
  Required: `core.ramp`, `core.peak`, `math.clear`

Key rules:
  - Use enough drive that the curve is visibly rounded.
  - This is a transfer-function demonstration, not a full distortion patch.

Public controls:
  - `Drive` -> `SoftClipper.Value`, matched, range `0.4..1`, default `0.75`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SoftSaturationShaper --agent
hise-cli builder set --module SoftSaturationShaper --network soft_saturation_shaper --agent
hise-cli dsp add --module SoftSaturationShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module SoftSaturationShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module SoftSaturationShaper --type math.tanh --id SoftClipper --agent
hise-cli dsp set --module SoftSaturationShaper --node SoftClipper --param Value --range "0.4,1" --agent
hise-cli dsp set --module SoftSaturationShaper --node SoftClipper --param Value --value 0.75 --agent
hise-cli dsp add --module SoftSaturationShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module SoftSaturationShaper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module SoftSaturationShaper --container soft_saturation_shaper --id Drive --range "0.4,1" --default 0.75 --agent
hise-cli dsp connect --module SoftSaturationShaper --source soft_saturation_shaper --source-param Drive --target SoftClipper --param Value --matched --agent
```
