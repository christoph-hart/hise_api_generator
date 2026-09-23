# container.multi - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/multi.md`
- Reference: `scriptnode_enrichment/output/container/multi.md`

## Naming

- Module ID: `PerChannelStereoPanner`
- Network ID: `per_channel_stereo_panner`

## Graph Plan

```text
per_channel_stereo_panner
  PanLaw                 control.xfader
  ChannelSlices          container.multi
    LeftChannel          container.chain
      LeftLevel          math.mul
    RightChannel         container.chain
      RightLevel         math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: exactly 2; each multi child receives one non-overlapping channel
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [child 0 is left, child 1 is right]

## Public Parameters

- Pan -> `PanLaw.Value` scaled
- Target range before connection: `[0, 1]`
- Macro range: `[-1, 1]`, labels `Left, Centre, Right`
- Default: `0`

## Defaults To Omit

- `PanLaw.Value` default `0.5`
- `LeftLevel.Value` default `1.0`
- `RightLevel.Value` default `1.0`

## Locked Build Values

- `PanLaw.Mode` = `RMS`
- `PanLaw` output 0 -> `LeftLevel.Value` range = `[0, 1]`
- `PanLaw` output 1 -> `RightLevel.Value` range = `[0, 1]`
- `ChannelSlices` child count = `2`
- Child 0 channel range = left channel only
- Child 1 channel range = right channel only

## Friction Comments To Weave In

- Before `ChannelSlices`: multi assigns disjoint channel slices; it does not copy and sum the stereo signal.
- Before `PanLaw`: RMS mode supplies complementary constant-power coefficients for the two channel-local multipliers.
- Before public mapping: the user-facing bipolar Pan range maps to the xfader's normalised 0..1 input.

## Cosmetic Plan

- Main node: `ChannelSlices`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`PanLaw`, `LeftLevel`, `RightLevel`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`PanLaw`, `ChannelSlices`, `LeftLevel`, `RightLevel`]

## Open Questions

- None
