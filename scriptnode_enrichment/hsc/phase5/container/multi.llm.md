---
id: container.multi.per-channel-stereo-panner
node: container.multi
domain: scriptnode
category: dsp-network
title: "Per-Channel Stereo Panner"
summary: "A parallel container that assigns each child a different slice of the audio channels."
useCase: "Demonstrate that `container.multi` assigns non-overlapping channel ranges to its children rather than copying and summing the same channels."
difficulty: beginner
networkName: per_channel_stereo_panner
moduleType: ScriptFX
moduleId: PerChannelStereoPanner
tags:
  - container
  - multi
  - routing
  - parallel-processing
aliases:
  - per-channel stereo panner
  - multi container
relatedNodes:
  - container.multi
  - control.xfader
  - math.mul
parameters:
  Pan: "Pan -> PanLaw.Value scaled"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [-1, 1], labels Left, Centre, Right"
  Default:: "Default: 0"
---

scriptnode example: container.multi

Per-Channel Stereo Panner.

Demonstrate that `container.multi` assigns non-overlapping channel ranges to its children rather than copying and summing the same channels.

Graph:
```text
per_channel_stereo_panner
  PanLaw                 control.xfader
  ChannelSlices          container.multi
    LeftChannel          container.chain
      LeftLevel          math.mul
    RightChannel         container.chain
      RightLevel         math.mul
```

Host:
  Module: PerChannelStereoPanner
  Network: per_channel_stereo_panner
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "PerChannelStereoPanner"`, then set its network to `per_channel_stereo_panner`.

Support nodes:
  Required: control.xfader, math.mul
  `control.xfader` converts the shared Pan position into two complementary coefficients, while one `math.mul` child per channel applies the corresponding coefficient only to the slice assigned by `container.multi`.

Key rules:
  - More children than available channels: Multi divides channels equally among children. If there are more children than channels, an error is raised and excess children are silently skipped.

Public controls:
  - Pan -> PanLaw.Value scaled
  - Target range before connection: [0, 1]
  - Macro range: [-1, 1], labels Left, Centre, Right
  - Default: 0

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id PerChannelStereoPanner --agent
hise-cli builder set --module PerChannelStereoPanner --network per_channel_stereo_panner --agent

hise-cli dsp add --module PerChannelStereoPanner --type control.xfader --id PanLaw --agent
# multi distributes disjoint channel slices rather than copying and summing audio.
hise-cli dsp add --module PerChannelStereoPanner --type container.multi --id ChannelSlices --agent
hise-cli dsp add --module PerChannelStereoPanner --type container.chain --id LeftChannel --parent ChannelSlices --agent
hise-cli dsp add --module PerChannelStereoPanner --type math.mul --id LeftLevel --parent LeftChannel --agent
hise-cli dsp add --module PerChannelStereoPanner --type container.chain --id RightChannel --parent ChannelSlices --agent
hise-cli dsp add --module PerChannelStereoPanner --type math.mul --id RightLevel --parent RightChannel --agent

# RMS mode produces complementary constant-power coefficients.
hise-cli dsp set --module PerChannelStereoPanner --node PanLaw --param Mode --value '"RMS"' --agent
hise-cli dsp create_parameter --module PerChannelStereoPanner --container per_channel_stereo_panner --id Pan --range "-1,1" --default 0 --agent
hise-cli dsp connect --module PerChannelStereoPanner --source per_channel_stereo_panner --source-param Pan --target PanLaw --param Value --agent
hise-cli dsp connect --module PerChannelStereoPanner --source PanLaw --source-output 0 --target LeftLevel --param Value --agent
hise-cli dsp connect --module PerChannelStereoPanner --source PanLaw --source-output 1 --target RightLevel --param Value --agent

hise-cli dsp set --module PerChannelStereoPanner --node ChannelSlices --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module PerChannelStereoPanner --node ChannelSlices --param Comment --value '"multi assigns disjoint channel slices; it does not copy and sum the stereo signal. Child 0 receives left and child 1 receives right."' --agent
hise-cli dsp set --module PerChannelStereoPanner --node PanLaw --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PerChannelStereoPanner --node PanLaw --param Comment --value '"RMS mode generates complementary constant-power coefficients for the two channel-local multipliers."' --agent
hise-cli dsp set --module PerChannelStereoPanner --node LeftChannel --param Comment --value '"First multi child: processes only input channel 0 (left)."' --agent
hise-cli dsp set --module PerChannelStereoPanner --node RightChannel --param Comment --value '"Second multi child: processes only input channel 1 (right)."' --agent
hise-cli dsp set --module PerChannelStereoPanner --node LeftLevel --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PerChannelStereoPanner --node RightLevel --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PerChannelStereoPanner --node per_channel_stereo_panner --param Comment --value '"The bipolar Pan macro is scaled from -1..1 to PanLaw Value 0..1: Left, Centre, Right."' --agent
```

