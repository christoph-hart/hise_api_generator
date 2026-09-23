# container.oversample - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/oversample.md`
- Reference: `scriptnode_enrichment/output/container/oversample.md`

## Naming

- Module ID: `SelectableAntiAliasingQuality`
- Network ID: `selectable_anti_aliasing_quality`

## Graph Plan

```text
selectable_anti_aliasing_quality
  QualityResampler       container.oversample
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation because the nonlinear child uses SNEX.
  - Use identical high-frequency source audio and analyser settings for every factor.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic, block-based network
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [monophonic processing context, no parallel dry path]

## Public Parameters

- Quality -> `QualityResampler.Oversampling` matched
- Target range before connection: `[0, 4]`, step `1`
- Macro range: `[0, 4]`, step `1`, labels `None, 2x, 4x, 8x, 16x`
- Default: `2`

## Defaults To Omit

- `QualityResampler.FilterType` default `Polyphase`

## Locked Build Values

- Oversampling index table = `0: None, 1: 2x, 2: 4x, 3: 8x, 4: 16x`
- `QualityResampler.FilterType` = `Polyphase`
- `SineFolder.Code` = `Math.sin(input * (1.0f + value * 12.0f))`
- `SineFolder.Value` = `0.7`
- `OutputSpectrum` must be after the resampling container.

## Friction Comments To Weave In

- Before Quality: the raw value is an exponent index and changing it re-prepares children, so it is a setup control rather than performance modulation.
- Before `QualityResampler`: only the nonlinear stage is oversampled to avoid multiplying unrelated CPU work.
- Before bypass verification: bypass removes resampling but still runs the waveshaper at the base rate.
- Before topology: unreported filter latency rules out an uncompensated parallel dry path.

## Cosmetic Plan

- Main node: `QualityResampler`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`SineFolder`, `OutputSpectrum`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: [`OutputSpectrum`]
- ShowParameters containers: [`QualityResampler`]
- Nodes that must stay visible: [`QualityResampler`, `SineFolder`]

## Open Questions

- None
