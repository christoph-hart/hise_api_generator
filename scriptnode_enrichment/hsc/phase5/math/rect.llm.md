---
id: math.rect.threshold-rectifier
node: math.rect
domain: scriptnode
category: dsp-network
title: Threshold rectifier
summary: Uses math.rect to convert a normalized value into a binary result at its fixed threshold.
useCase: Use this as a hard 0.5 threshold gate for normalized signals.
difficulty: beginner
networkName: threshold_rectifier
moduleType: ScriptFX
moduleId: ThresholdRectifier
tags:
  - threshold
  - binary
  - gate
aliases:
  - binary rectifier
  - threshold gate
relatedNodes:
  - math.rect
  - math.add
  - analyse.specs
  - math.clear
parameters:
  BinaryGate.Value: Unused interface parameter; threshold is fixed at 0.5.
---

scriptnode example: math.rect

Threshold rectifier.
Use this to show a continuous normalized input becoming a hard binary 0 or 1 result.

Graph:
```text
threshold_rectifier
  SeedValue             math.add
  InputSpecs            analyse.specs
  BinaryGate            math.rect
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ThresholdRectifier`
  Type: `ScriptFX`
  Network: `threshold_rectifier`
  Builder setup: add ScriptFX `ThresholdRectifier`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - The threshold is hardcoded at 0.5 and cannot be adjusted.
  - Keep the seed in the normalized range.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ThresholdRectifier --agent
hise-cli builder set --module ThresholdRectifier --network threshold_rectifier --agent
hise-cli dsp add --module ThresholdRectifier --type math.add --id SeedValue --agent
hise-cli dsp set --module ThresholdRectifier --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ThresholdRectifier --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ThresholdRectifier --type math.rect --id BinaryGate --agent
hise-cli dsp add --module ThresholdRectifier --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ThresholdRectifier --type math.clear --id SignalClear --agent
```
