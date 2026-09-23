# container.oversample2x - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/oversample2x.md`
- Reference: `scriptnode_enrichment/output/container/oversample2x.md`

## Naming

- Module ID: `LightweightSoftSaturation`
- Network ID: `lightweight_soft_saturation`

## Graph Plan

```text
lightweight_soft_saturation
  DoubleRateSaturation   container.oversample2x
    PreGain              math.mul
    SoftClip             math.tanh
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Verify child preparation at twice the base sample rate and block size.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic, block-based network
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [no nested resampler or uncompensated dry path]

## Public Parameters

- Drive -> `PreGain.Value` matched
- Target range before connection: `[1, 6]`
- Macro range: `[1, 6]`
- Default: `3`

## Defaults To Omit

- `DoubleRateSaturation.FilterType` default `Polyphase`
- `SoftClip.Value` default `1.0`

## Locked Build Values

- Oversampling factor = `2x`
- `DoubleRateSaturation.FilterType` = `Polyphase`
- `PreGain.Value` range = `[1, 6]`
- `OutputTrim.Value` = `0.4`
- Child order = `PreGain`, `SoftClip`, `OutputTrim`
- `OutputSpectrum` must be after the oversampling container.

## Friction Comments To Weave In

- Before `DoubleRateSaturation`: keep gain staging and the nonlinear stage together under the doubled preparation context.
- Before Drive: `math.mul` is used because its range can extend above unity.
- Before bypass verification: bypass removes resampling but continues running all children at the base rate.

## Cosmetic Plan

- Main node: `DoubleRateSaturation`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`PreGain`, `SoftClip`, `OutputTrim`, `OutputSpectrum`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: [`OutputSpectrum`]
- Nodes that must stay visible: [`DoubleRateSaturation`, `PreGain`, `SoftClip`, `OutputTrim`]

## Open Questions

- None
