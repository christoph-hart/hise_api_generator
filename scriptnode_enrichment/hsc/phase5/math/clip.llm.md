---
id: math.clip.hard-clip-shaper
node: math.clip
domain: scriptnode
category: dsp-network
title: Hard-clipped ramp shaper
summary: Uses math.clip to truncate a slow ramp at a symmetric limit.
useCase: Use this for hard clipping or a visible bounded transfer function.
difficulty: beginner
networkName: hard_clip_shaper
moduleType: ScriptFX
moduleId: HardClipShaper
tags:
  - clipping
  - waveshaping
  - transfer-function
aliases:
  - hard clipper
  - symmetric clip
relatedNodes:
  - math.clip
  - core.ramp
  - math.add
  - core.peak
  - math.clear
parameters:
  ClipLimit: Public symmetric clipping limit connected to HardClipper.Value.
---

scriptnode example: math.clip

Hard-clipped ramp shaper.
Use this to show a low symmetric clipping limit producing a flat plateau in the peak display.

Graph:
```text
hard_clip_shaper
  SlowRamp              core.ramp
  RampOffset            math.add
  HardClipper           math.clip
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `HardClipShaper`
  Type: `ScriptFX`
  Network: `hard_clip_shaper`
  Builder setup: add ScriptFX `HardClipShaper`, then set its network.

Support nodes:
  Required: `core.ramp`, `math.add`, `core.peak`, `math.clear`

Key rules:
  - Keep the clip limit below 1.0 so the plateau is visible.
  - `math.clip` clips symmetrically around zero.

Public controls:
  - `ClipLimit` -> `HardClipper.Value`, matched, range `0.1..0.6`, default `0.35`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id HardClipShaper --agent
hise-cli builder set --module HardClipShaper --network hard_clip_shaper --agent
hise-cli dsp add --module HardClipShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module HardClipShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module HardClipShaper --type math.add --id RampOffset --agent
hise-cli dsp set --module HardClipShaper --node RampOffset --param Value --value 0 --agent
hise-cli dsp add --module HardClipShaper --type math.clip --id HardClipper --agent
hise-cli dsp set --module HardClipShaper --node HardClipper --param Value --range "0.1,0.6" --agent
hise-cli dsp set --module HardClipShaper --node HardClipper --param Value --value 0.35 --agent
hise-cli dsp add --module HardClipShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module HardClipShaper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module HardClipShaper --container hard_clip_shaper --id ClipLimit --range "0.1,0.6" --default 0.35 --agent
hise-cli dsp connect --module HardClipShaper --source hard_clip_shaper --source-param ClipLimit --target HardClipper --param Value --matched --agent
```
