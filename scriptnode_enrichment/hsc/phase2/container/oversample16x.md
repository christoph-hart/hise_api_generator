# container.oversample16x - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/oversample16x.md`
- Reference: `scriptnode_enrichment/output/container/oversample16x.md`

## Naming

- Module ID: `ExtremeFoldbackStressTest`
- Network ID: `extreme_foldback_stress_test`

## Graph Plan

```text
extreme_foldback_stress_test
  SixteenRateStress      container.oversample16x
    NestedSineStress     math.expr
  OutputSpectrum         analyse.fft
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation because the stress waveshaper uses SNEX.
  - Use high-frequency source material at a low base sample rate and record matched 4x, 8x, and 16x comparison captures.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic, block-based network
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [no nested resampler or uncompensated dry path]

## Public Parameters

- Stress -> `NestedSineStress.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.7`

## Defaults To Omit

- `SixteenRateStress.FilterType` default `Polyphase`
- `NestedSineStress.Value` default `0.0`

## Locked Build Values

- Oversampling factor = `16x`
- `SixteenRateStress.FilterType` = `Polyphase`
- `NestedSineStress.Code` = `Math.sin(Math.sin(input * (1.0f + value * 12.0f)) * 8.0f)`
- `OutputSpectrum` must be after the oversampling container.
- Comparison factors = `4x`, `8x`, `16x` with matched source, level, filter, and analyser settings.

## Friction Comments To Weave In

- Before `SixteenRateStress`: only the pathological nonlinear stage is oversampled because all child CPU is multiplied by sixteen.
- Before verification: this is an upper-bound diagnostic and must show when lower factors are sufficient.
- Before bypass verification: bypass is a 1x comparison, not a substitute for temporary 4x or 8x comparison builds.

## Cosmetic Plan

- Main node: `SixteenRateStress`
- Accent colour: `0xFFE74C3C`
- Supporting relevant nodes: [`NestedSineStress`, `OutputSpectrum`]
- Supporting colour: `0xFF965E58`
- Folded nodes: [`OutputSpectrum`]
- Nodes that must stay visible: [`SixteenRateStress`, `NestedSineStress`]

## Open Questions

- None
