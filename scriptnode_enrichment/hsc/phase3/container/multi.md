# container.multi - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/multi.md`
- Reference: `scriptnode_enrichment/output/container/multi.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `PerChannelStereoPanner`
- Network ID: `per_channel_stereo_panner`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
per_channel_stereo_panner
  PanLaw
  ChannelSlices
    LeftChannel
      LeftLevel
    RightChannel
      RightLevel
```

## Verified Parameters And Connections

- Root `Pan`: range `-1..1`, default `0`
- Root `Pan` -> `PanLaw.Value`, scaled to `0..1`
- `PanLaw.Mode` = `RMS`
- `PanLaw.0` -> `LeftLevel.Value`
- `PanLaw.1` -> `RightLevel.Value`
- `ChannelSlices` has exactly two children.
- Each child receives one non-overlapping channel.

## Trace Validation

Commands used the same DC input with three temporary Pan values:

```bash
hise-cli dsp trace --module PerChannelStereoPanner --container per_channel_stereo_panner --inject dc --gain 0.25 --inject-param per_channel_stereo_panner.Pan=-1 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp trace --module PerChannelStereoPanner --container per_channel_stereo_panner --inject dc --gain 0.25 --inject-param per_channel_stereo_panner.Pan=0 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp trace --module PerChannelStereoPanner --container per_channel_stereo_panner --inject dc --gain 0.25 --inject-param per_channel_stereo_panner.Pan=1 --probe-recursive --probe-changed-parameters --trace-compact --agent
```

Verified output:

- Pan `-1`: `[0.25, 0]`
- Pan `0`: `[0.1768, 0.1768]`
- Pan `1`: `[0, 0.25]`
- `ChannelSlices`, `LeftChannel`, and `RightChannel` each reported one-channel processing where applicable.
- The center coefficient is approximately `sqrt(0.5)`, confirming constant-power panning.

## Optimized Public Shell Commands

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

## Pipeline-Only Commands

```bash
hise-cli dsp save --module PerChannelStereoPanner --agent
hise-cli dsp screenshot --module PerChannelStereoPanner --scale 200% --output "scriptnode_enrichment/hsc/output/container/multi.png" --agent
```

## Open Issues

- Issue 18 (`ParameterInjector::poll()` crash) was fixed and verified after the maintainer rebuild.
