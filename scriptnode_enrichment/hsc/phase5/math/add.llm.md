---
id: math.add.dc-offset-adder
node: math.add
domain: scriptnode
category: dsp-network
title: DC offset adder
summary: Uses math.add to add a public raw scalar offset to a known test signal.
useCase: Use this when a signal must be shifted by a constant value before downstream processing.
difficulty: beginner
networkName: dc_offset_adder
moduleType: ScriptFX
moduleId: DcOffsetAdder
tags:
  - arithmetic
  - dc-offset
  - scalar
aliases:
  - scalar offset
  - DC adder
relatedNodes:
  - math.add
  - analyse.specs
  - math.clear
parameters:
  DcOffset: Public scalar added to every sample by OffsetAdder.Value.
  OffsetAdder.Value: Raw linear offset, demonstrated with a 0.3 default.
---

scriptnode example: math.add

DC offset adder.
Use this to demonstrate that `math.add` adds a constant value to every sample. The example uses a seeded test signal and analyser nodes so the offset is visible without relying on external audio.

Graph:
```text
dc_offset_adder
  SeedValue             math.add
  InputSpecs            analyse.specs
  OffsetAdder           math.add
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `DcOffsetAdder`
  Type: `ScriptFX`
  Network: `dc_offset_adder`
  Builder setup: `add ScriptFX as "DcOffsetAdder"`, then set its network to `dc_offset_adder`.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Seed a non-zero signal before the input analyser so the transform is measurable.
  - `math.add` is raw linear offset, not decibel-scaled gain.
  - Clear the artificial signal after the output analyser.

Public controls:
  - `DcOffset` -> `OffsetAdder.Value`, matched, range `0..0.5`, default `0.3`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DcOffsetAdder --agent
hise-cli builder set --module DcOffsetAdder --network dc_offset_adder --agent
hise-cli dsp add --module DcOffsetAdder --type math.add --id SeedValue --agent
hise-cli dsp set --module DcOffsetAdder --node SeedValue --param Value --value 0.2 --agent
hise-cli dsp add --module DcOffsetAdder --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module DcOffsetAdder --type math.add --id OffsetAdder --agent
hise-cli dsp set --module DcOffsetAdder --node OffsetAdder --param Value --range "0,0.5" --agent
hise-cli dsp set --module DcOffsetAdder --node OffsetAdder --param Value --value 0.3 --agent
hise-cli dsp add --module DcOffsetAdder --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module DcOffsetAdder --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module DcOffsetAdder --container dc_offset_adder --id DcOffset --range "0,0.5" --default 0.3 --agent
hise-cli dsp connect --module DcOffsetAdder --source dc_offset_adder --source-param DcOffset --target OffsetAdder --param Value --matched --agent
```
