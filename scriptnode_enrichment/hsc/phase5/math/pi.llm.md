---
id: math.pi.visible-radian-scaler
node: math.pi
domain: scriptnode
category: dsp-network
title: Visible radian scaler
summary: Uses math.pi to scale a known value into a radian-oriented range before display conversion.
useCase: Use this as the PI support stage before trigonometric shaping.
difficulty: beginner
networkName: visible_radian_scaler
moduleType: ScriptFX
moduleId: VisibleRadianScaler
tags:
  - pi
  - radians
  - trigonometry
aliases:
  - PI scaler
  - radian support
relatedNodes:
  - math.pi
  - math.sig2mod
  - math.add
  - core.peak
  - math.clear
parameters:
  CycleScale: Public multiplier applied by PiScaler.Value.
---

scriptnode example: math.pi

Visible radian scaler.
Use this as a small support-node example showing PI scaling followed by modulation-range conversion.

Graph:
```text
visible_radian_scaler
  SeedValue             math.add
  PiScaler              math.pi
  DisplayRange          math.sig2mod
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `VisibleRadianScaler`
  Type: `ScriptFX`
  Network: `visible_radian_scaler`
  Builder setup: add ScriptFX `VisibleRadianScaler`, then set its network.

Support nodes:
  Required: `math.add`, `math.sig2mod`, `core.peak`, `math.clear`

Key rules:
  - `math.pi` multiplies by PI times Value.
  - Convert the scaled result before sending it to a modulation-oriented display.

Public controls:
  - `CycleScale` -> `PiScaler.Value`, matched, range `1..2`, default `2`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id VisibleRadianScaler --agent
hise-cli builder set --module VisibleRadianScaler --network visible_radian_scaler --agent
hise-cli dsp add --module VisibleRadianScaler --type math.add --id SeedValue --agent
hise-cli dsp set --module VisibleRadianScaler --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module VisibleRadianScaler --type math.pi --id PiScaler --agent
hise-cli dsp set --module VisibleRadianScaler --node PiScaler --param Value --range "1,2" --agent
hise-cli dsp set --module VisibleRadianScaler --node PiScaler --param Value --value 2 --agent
hise-cli dsp add --module VisibleRadianScaler --type math.sig2mod --id DisplayRange --agent
hise-cli dsp add --module VisibleRadianScaler --type core.peak --id OutputPeak --agent
hise-cli dsp add --module VisibleRadianScaler --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module VisibleRadianScaler --container visible_radian_scaler --id CycleScale --range "1,2" --default 2 --agent
hise-cli dsp connect --module VisibleRadianScaler --source visible_radian_scaler --source-param CycleScale --target PiScaler --param Value --matched --agent
```
