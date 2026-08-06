---
id: math.inv.signal-polarity-inverter
node: math.inv
domain: scriptnode
category: dsp-network
title: Signal polarity inverter
summary: Uses math.inv to negate a known signal and demonstrate bipolar polarity inversion.
useCase: Use this to flip the polarity of a bipolar audio or modulation signal around zero.
difficulty: beginner
networkName: signal_polarity_inverter
moduleType: ScriptFX
moduleId: SignalPolarityInverter
tags:
  - polarity
  - phase
  - inversion
aliases:
  - phase inverter
  - negate signal
relatedNodes:
  - math.inv
  - math.add
  - analyse.specs
  - math.clear
parameters:
  InvertPolarity.Value: Unused interface parameter; math.inv always negates the signal.
---

scriptnode example: math.inv

Signal polarity inverter.
Use this to demonstrate bipolar phase inversion with a seeded signal and before/after analyser nodes. For unipolar `1 - x` inversion, use `math.mod_inv` instead.

Graph:
```text
signal_polarity_inverter
  SeedValue             math.add
  InputSpecs            analyse.specs
  InvertPolarity        math.inv
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `SignalPolarityInverter`
  Type: `ScriptFX`
  Network: `signal_polarity_inverter`
  Builder setup: `add ScriptFX as "SignalPolarityInverter"`, then set its network to `signal_polarity_inverter`.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Seed a non-zero signal so the sign flip is visible.
  - `math.inv` negates bipolar signals; it is not modulation inversion.
  - Clear the artificial test signal after inspection.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SignalPolarityInverter --agent
hise-cli builder set --module SignalPolarityInverter --network signal_polarity_inverter --agent
hise-cli dsp add --module SignalPolarityInverter --type math.add --id SeedValue --agent
hise-cli dsp set --module SignalPolarityInverter --node SeedValue --param Value --value 0.6 --agent
hise-cli dsp add --module SignalPolarityInverter --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module SignalPolarityInverter --type math.inv --id InvertPolarity --agent
hise-cli dsp add --module SignalPolarityInverter --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module SignalPolarityInverter --type math.clear --id SignalClear --agent
```
