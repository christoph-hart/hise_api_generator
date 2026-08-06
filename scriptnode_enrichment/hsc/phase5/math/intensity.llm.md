---
id: math.intensity.unity-anchored-depth
node: math.intensity
domain: scriptnode
category: dsp-network
title: Unity-anchored modulation depth
summary: Uses math.intensity to reduce modulation depth while keeping the unity ceiling anchored.
useCase: Use this when reducing modulation excursion without scaling the top of the range toward zero.
difficulty: beginner
networkName: unity_anchored_depth
moduleType: ScriptFX
moduleId: UnityAnchoredDepth
tags:
  - modulation-depth
  - unity-anchor
  - scaling
aliases:
  - intensity control
  - unity depth
relatedNodes:
  - math.intensity
  - math.mul
  - core.ramp
  - core.peak
  - math.clear
parameters:
  Depth: Public intensity control connected to UnityDepth.Value.
---

scriptnode example: math.intensity

Unity-anchored modulation depth.
Use this to contrast unity-anchored depth control with ordinary multiplication around zero.

Graph:
```text
unity_anchored_depth
  SlowRamp              core.ramp
  UnityDepth            math.intensity
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `UnityAnchoredDepth`
  Type: `ScriptFX`
  Network: `unity_anchored_depth`
  Builder setup: add ScriptFX `UnityAnchoredDepth`, then set its network.

Support nodes:
  Required: `core.ramp`, `core.peak`, `math.clear`

Key rules:
  - `math.intensity` crossfades toward unity, unlike `math.mul`.
  - Keep the source in the 0..1 modulation range.

Public controls:
  - `Depth` -> `UnityDepth.Value`, matched, range `0..1`, default `0.4`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id UnityAnchoredDepth --agent
hise-cli builder set --module UnityAnchoredDepth --network unity_anchored_depth --agent
hise-cli dsp add --module UnityAnchoredDepth --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module UnityAnchoredDepth --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module UnityAnchoredDepth --type math.intensity --id UnityDepth --agent
hise-cli dsp set --module UnityAnchoredDepth --node UnityDepth --param Value --range "0,1" --agent
hise-cli dsp set --module UnityAnchoredDepth --node UnityDepth --param Value --value 0.4 --agent
hise-cli dsp add --module UnityAnchoredDepth --type core.peak --id OutputPeak --agent
hise-cli dsp add --module UnityAnchoredDepth --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module UnityAnchoredDepth --container unity_anchored_depth --id Depth --range "0,1" --default 0.4 --agent
hise-cli dsp connect --module UnityAnchoredDepth --source unity_anchored_depth --source-param Depth --target UnityDepth --param Value --matched --agent
```
