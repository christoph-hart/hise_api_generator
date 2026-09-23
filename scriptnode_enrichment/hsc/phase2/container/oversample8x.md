# container.oversample8x - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/oversample8x.md`
- Reference: `scriptnode_enrichment/output/container/oversample8x.md`

## Naming

- Module ID: `AggressiveSineFoldDistortion`
- Network ID: `aggressive_sine_fold_distortion`

## Graph Plan

```text
aggressive_sine_fold_distortion
  EightRateFolder        container.oversample8x
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation because the waveshaper uses SNEX.
  - Verify child preparation at eight times the base sample rate and block size.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic, block-based network
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [no nested resampler or uncompensated dry path]

## Public Parameters

- Fold -> `SineFolder.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.65`

## Defaults To Omit

- `EightRateFolder.FilterType` default `Polyphase`
- `SineFolder.Value` default `0.0`

## Locked Build Values

- Oversampling factor = `8x`
- `EightRateFolder.FilterType` = `Polyphase`
- `SineFolder.Code` = `Math.sin(input * (1.0f + value * 14.0f))`
- `OutputSpectrum` must be after the oversampling container.

## Friction Comments To Weave In

- Before `EightRateFolder`: only the severe nonlinear stage is multiplied by the 8x CPU factor.
- Before verification: compare spectrum and CPU against whether 4x is already sufficient.
- Before bypass verification: bypass runs the same expression at 1x and re-prepares it.

## Cosmetic Plan

- Main node: `EightRateFolder`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`SineFolder`, `OutputSpectrum`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: [`OutputSpectrum`]
- Nodes that must stay visible: [`EightRateFolder`, `SineFolder`]

## Open Questions

- None
