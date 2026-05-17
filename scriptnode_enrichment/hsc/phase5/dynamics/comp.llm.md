---
id: dynamics.comp.sidechain-ducking-compressor
node: dynamics.comp
domain: scriptnode
category: dsp-network
title: Sidechain ducking compressor
summary: Uses dynamics.comp inside container.sidechain to duck a stereo program signal from a separate detector pair.
useCase: Use this when you need external sidechain compression, pumping, or ducking where one signal controls gain reduction on another.
difficulty: intermediate
networkName: sidechain_ducker
moduleType: ScriptFX
moduleId: SidechainDucker
tags:
  - compressor
  - sidechain
  - ducking
  - pump
  - multichannel-routing
  - detector-signal
aliases:
  - sidechain compressor
  - ducking compressor
  - pump effect
  - external key compression
  - sidechain detector pair
relatedNodes:
  - dynamics.comp
  - container.sidechain
  - container.multi
  - container.chain
  - math.clear
  - core.ramp
  - math.mul
parameters:
  DuckThreshold: Controls the compressor threshold on DuckComp.Threshhold.
  DuckRelease: Controls how quickly DuckComp recovers after gain reduction.
  DuckRatio: Controls the compression depth/ratio on DuckComp.Ratio.
  PumpTime: Controls PumpRamp.PeriodTime for the synthetic detector ramp.
  DuckComp.Sidechain: Must be set to Sidechain so DuckComp reads detector channels instead of self-keying.
---

scriptnode example: dynamics.comp

Sidechain ducking compressor.
Use this to build external sidechain ducking with `dynamics.comp` inside `container.sidechain`, replacing the detector pair with a synthetic ramp that makes the pumping behavior obvious.

Graph:
```text
sidechain_ducker
  SidechainHost         container.sidechain
    PairView            container.multi
      ProgramPair       container.chain
      SidechainPair     container.chain
        DetectorClear   math.clear
        PumpRamp        core.ramp
    DuckComp            dynamics.comp
```

Host:
  Module: `SidechainDucker`
  Type: `ScriptFX`
  Network: `sidechain_ducker`
  Routing: default stereo externally; four internal channels inside `SidechainHost`
  Builder setup:
    - `add ScriptFX as "SidechainDucker"`
    - `set SidechainDucker.network "sidechain_ducker"`

Support nodes:
  Required: `container.sidechain`, `routing.receive`, `routing.send`
  Optional: `container.fix16_block`, `math.mul`

Key rules:
  - Use `container.sidechain` to expand stereo into program channels 0-1 and detector channels 2-3.
  - Set `DuckComp.Sidechain` to `Sidechain`; `Disabled` and `Original` self-key from the program signal.
  - Use `container.multi` only to expose the two stereo pairs visually; it is not a dry/wet split.
  - Clear the duplicated detector channels before `PumpRamp`, otherwise source audio leaks into the sidechain key.
  - `PumpRamp` replaces the detector pair with a synthetic ramp; `PumpTime` controls the ramp period.
  - Do not add fixed-block processing for ordinary sidechain compression unless the exported compressor modulation drives another parameter.
  - Invert the compressor modulation output if routing it to gain, because it represents inverse gain reduction.

Public controls:
  - `DuckThreshold` -> `DuckComp.Threshhold`, matched, `-36..-12`, default `-24`
  - `DuckRelease` -> `DuckComp.Release`, matched, `40..220`, default `140`
  - `DuckRatio` -> `DuckComp.Ratio`, matched, `2..12`, default `6`
  - `PumpTime` -> `PumpRamp.PeriodTime`, matched, `250..4000`, default `1000`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SidechainDucker --agent
hise-cli builder set --module SidechainDucker --network sidechain_ducker --agent

hise-cli dsp add --module SidechainDucker --type container.sidechain --id SidechainHost --agent
hise-cli dsp add --module SidechainDucker --type container.multi --id PairView --parent SidechainHost --agent
hise-cli dsp add --module SidechainDucker --type container.chain --id ProgramPair --parent PairView --agent
hise-cli dsp add --module SidechainDucker --type container.chain --id SidechainPair --parent PairView --agent
hise-cli dsp add --module SidechainDucker --type math.clear --id DetectorClear --parent SidechainPair --agent
hise-cli dsp add --module SidechainDucker --type core.ramp --id PumpRamp --parent SidechainPair --agent
hise-cli dsp add --module SidechainDucker --type dynamics.comp --id DuckComp --parent SidechainHost --agent

hise-cli dsp set --module SidechainDucker --node PumpRamp --param PeriodTime --range "250,4000" --stepSize 1 --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Sidechain --value 2 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Threshhold --range "-36,-12" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Threshhold --value -24 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Release --range "40,220" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Release --value 140 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Ratio --range "2,12" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Ratio --value 6 --agent

hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckThreshold --range "-36,-12" --default -24 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckRelease --range "40,220" --default 140 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckRatio --range "2,12" --default 6 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id PumpTime --range "250,4000" --default 1000 --stepSize 1 --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckThreshold --target DuckComp --param Threshhold --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckRelease --target DuckComp --param Release --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckRatio --target DuckComp --param Ratio --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param PumpTime --target PumpRamp --param PeriodTime --matched --agent

hise-cli dsp set --module SidechainDucker --node DuckComp --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Comment --value '"**Sidechain compressor** - DuckComp listens to the synthetic detector pair while compressing the program pair."' --agent
hise-cli dsp set --module SidechainDucker --node SidechainHost --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node SidechainHost --param Comment --value '"SidechainHost expands stereo into four internal channels: program 0-1 and detector 2-3."' --agent
hise-cli dsp set --module SidechainDucker --node PairView --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node PairView --param Comment --value '"PairView exposes the two stereo pairs before DuckComp processes the full four-channel stream."' --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param Comment --value '"Clear the duplicated detector pair before replacing it with the synthetic pump ramp."' --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param Comment --value '"Pump time controls the ramp period for wider ducking cycles."' --agent
hise-cli dsp set --module SidechainDucker --node ProgramPair --param Folded --value true --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param Folded --value true --agent
```
