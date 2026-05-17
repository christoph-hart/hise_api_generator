---
id: dynamics.envelope_follower.dynamic-mid-cut-eq
node: dynamics.envelope_follower
domain: scriptnode
category: dsp-network
title: Dynamic mid-cut EQ
summary: Tracks input amplitude with dynamics.envelope_follower and uses it to drive a level-dependent EQ cut.
useCase: Use this when you need an envelope follower to modulate another parameter, such as a dynamic EQ band, without replacing the audio signal.
difficulty: intermediate
networkName: dynamic_mid_cut
moduleType: ScriptFX
moduleId: DynamicMidCut
tags:
  - envelope-follower
  - dynamic-eq
  - amplitude-tracking
  - parameter-modulation
  - fixed-block
  - raw-db-control
aliases:
  - dynamic EQ
  - envelope controlled EQ
  - level dependent EQ
  - duck harsh frequencies
  - amplitude follower modulation
relatedNodes:
  - dynamics.envelope_follower
  - container.fix16_block
  - control.pma_unscaled
  - filters.svf_eq
parameters:
  FollowerAttack: Controls how quickly InputFollower responds to rising input amplitude.
  FollowerRelease: Controls how quickly InputFollower falls after the source gets quieter.
  MidCutDepth: Raw dB depth passed into CutDepthPMA.Value and scaled by the follower output.
  HarshBandEQ.Gain: Receives the unscaled PMA output as the final dynamic EQ cut amount.
---

scriptnode example: dynamics.envelope_follower

Dynamic mid-cut EQ.
Use this to track input amplitude with `dynamics.envelope_follower` and apply a level-dependent EQ cut without compressing the full signal.

Graph:
```text
dynamic_mid_cut
  TimingBlock           container.fix16_block
    InputFollower       dynamics.envelope_follower
    CutDepthPMA         control.pma_unscaled
    HarshBandEQ         filters.svf_eq
```

Host:
  Module: `DynamicMidCut`
  Type: `ScriptFX`
  Network: `dynamic_mid_cut`
  Routing: default stereo
  Builder setup:
    - `add ScriptFX as "DynamicMidCut"`
    - `set DynamicMidCut.network "dynamic_mid_cut"`

Support nodes:
  Required: `container.fix16_block`, `filters.svf_eq`
  Optional: `container.fix8_block`, `math.mul`, `math.add`

Key rules:
  - Use a fixed-block container because the follower output drives another parameter; `container.fix16_block` makes follower-to-EQ modulation timing deterministic.
  - Leave `InputFollower.ProcessSignal` off so the node analyses input amplitude while passing audio through unchanged.
  - Use `control.pma_unscaled` so `MidCutDepth` stays a raw dB value and the follower output scales how much cut is applied.
  - Set `CutDepthPMA.Multiply` range to `0..1` before connecting `InputFollower`; `Multiply` is range-scaled, while `Value` and `Add` are raw/unscaled.
  - Set `HarshBandEQ.Gain` range to `0..-18` before connecting `CutDepthPMA`, because the PMA output already produces the dB gain value.
  - Set `HarshBandEQ.Smoothing` to `0` so envelope timing comes from `InputFollower.Attack` and `InputFollower.Release`, not an added EQ smoothing stage.

Public controls:
  - `FollowerAttack` -> `InputFollower.Attack`, matched, `5..80`, default `20`
  - `FollowerRelease` -> `InputFollower.Release`, matched, `40..300`, default `120`
  - `MidCutDepth` -> `CutDepthPMA.Value`, unscaled raw dB, `-18..-3`, default `-9`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DynamicMidCut --agent
hise-cli builder set --module DynamicMidCut --network dynamic_mid_cut --agent

hise-cli dsp add --module DynamicMidCut --type container.fix16_block --id TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type dynamics.envelope_follower --id InputFollower --parent TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type control.pma_unscaled --id CutDepthPMA --parent TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type filters.svf_eq --id HarshBandEQ --parent TimingBlock --agent

hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Mode --value 4 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Frequency --value 2500 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Q --value 2.5 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Smoothing --value 0 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Gain --range "0,-18" --stepSize 0.1 --agent

hise-cli dsp set --module DynamicMidCut --node InputFollower --param Attack --range "5,80" --stepSize 0.1 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Attack --value 20 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Release --range "40,300" --stepSize 0.1 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Release --value 120 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Multiply --range "0,1" --stepSize 0.0001 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Add --value 0 --agent

hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id FollowerAttack --range "5,80" --default 20 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id FollowerRelease --range "40,300" --default 120 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id MidCutDepth --range "-18,-3" --default -9 --stepSize 0.1 --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param FollowerAttack --target InputFollower --param Attack --matched --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param FollowerRelease --target InputFollower --param Release --matched --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param MidCutDepth --target CutDepthPMA --param Value --agent
hise-cli dsp connect --module DynamicMidCut --source InputFollower --target CutDepthPMA --param Multiply --agent
hise-cli dsp connect --module DynamicMidCut --source CutDepthPMA --target HarshBandEQ --param Gain --agent

hise-cli dsp set --module DynamicMidCut --node InputFollower --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Comment --value '"**Envelope follower** - Tracks input level while leaving the audio path unchanged."' --agent
hise-cli dsp set --module DynamicMidCut --node TimingBlock --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node TimingBlock --param Comment --value '"Fixed 16-sample blocks make the follower-to-EQ modulation update interval deterministic."' --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Comment --value '"PMA unscaled multiplies raw depth dB by the follower amount."' --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Comment --value '"Peak EQ cuts more as the follower output rises."' --agent
```
