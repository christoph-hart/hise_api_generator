---
id: math.map.clamped-range-mapper
node: math.map
domain: scriptnode
category: dsp-network
title: Clamped range mapper
summary: Uses math.map to remap a known value into a second range with input clamping.
useCase: Use this to convert normalized controls between bounded numeric ranges.
difficulty: intermediate
networkName: clamped_range_mapper
moduleType: ScriptFX
moduleId: ClampedRangeMapper
tags:
  - mapping
  - range
  - clamping
aliases:
  - range remapper
  - normalized mapper
relatedNodes:
  - math.map
  - math.add
  - analyse.specs
  - math.clear
parameters:
  InputEnd: Upper input bound.
  OutputStart: Lower output bound.
  OutputEnd: Upper output bound.
---

scriptnode example: math.map

Clamped range mapper.
Use this to show linear range conversion and clamping with a known seeded input.

Graph:
```text
clamped_range_mapper
  SeedValue             math.add
  InputSpecs            analyse.specs
  RangeMapper           math.map
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ClampedRangeMapper`
  Type: `ScriptFX`
  Network: `clamped_range_mapper`
  Builder setup: add ScriptFX `ClampedRangeMapper`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Narrow the bounds so the remap math is visible.
  - Values outside the input range are clamped.

Public controls:
  - `InputEnd` -> `RangeMapper.InputEnd`, matched, range `0.4..0.8`, default `0.6`
  - `OutputStart` -> `RangeMapper.OutputStart`, matched, range `0..0.3`, default `0.2`
  - `OutputEnd` -> `RangeMapper.OutputEnd`, matched, range `0.6..1`, default `0.9`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ClampedRangeMapper --agent
hise-cli builder set --module ClampedRangeMapper --network clamped_range_mapper --agent
hise-cli dsp add --module ClampedRangeMapper --type math.add --id SeedValue --agent
hise-cli dsp set --module ClampedRangeMapper --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module ClampedRangeMapper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ClampedRangeMapper --type math.map --id RangeMapper --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param InputEnd --range "0.4,0.8" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param InputEnd --value 0.6 --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputStart --range "0,0.3" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputStart --value 0.2 --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputEnd --range "0.6,1" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputEnd --value 0.9 --agent
hise-cli dsp add --module ClampedRangeMapper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ClampedRangeMapper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id InputEnd --range "0.4,0.8" --default 0.6 --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id OutputStart --range "0,0.3" --default 0.2 --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id OutputEnd --range "0.6,1" --default 0.9 --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param InputEnd --target RangeMapper --param InputEnd --matched --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param OutputStart --target RangeMapper --param OutputStart --matched --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param OutputEnd --target RangeMapper --param OutputEnd --matched --agent
```
