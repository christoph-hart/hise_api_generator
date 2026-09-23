# container.oversample4x - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/oversample4x.md`
- Reference: `scriptnode_enrichment/output/container/oversample4x.md`

## Naming

- Module ID: `ProductionHardClipper`
- Network ID: `production_hard_clipper`

## Graph Plan

```text
production_hard_clipper
  QuadRateClipper        container.oversample4x
    PreGain              math.mul
    HardClip             math.clip
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Verify child preparation at four times the base sample rate and block size.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic, block-based network
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [no frame wrapper, nested resampler, or uncompensated dry path]

## Public Parameters

- Drive -> `PreGain.Value` matched
- Target range before connection: `[1, 8]`
- Macro range: `[1, 8]`
- Default: `4`

## Defaults To Omit

- `QuadRateClipper.FilterType` default `Polyphase`

## Locked Build Values

- Oversampling factor = `4x`
- `QuadRateClipper.FilterType` = `Polyphase`
- `PreGain.Value` range = `[1, 8]`
- `HardClip.Value` = `0.35`
- `OutputTrim.Value` = `0.5`
- Child order = `PreGain`, `HardClip`, `OutputTrim`
- `OutputSpectrum` must be after the oversampling container.

## Friction Comments To Weave In

- Before `QuadRateClipper`: all distortion stages share the 4x context while unrelated analysis stays outside.
- Before topology: do not use a frame wrapper because `math.clip` has a different single-sample implementation.
- Before bypass verification: bypass keeps the distortion active at 1x and only removes resampling.

## Cosmetic Plan

- Main node: `QuadRateClipper`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`PreGain`, `HardClip`, `OutputTrim`, `OutputSpectrum`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: [`OutputSpectrum`]
- Nodes that must stay visible: [`QuadRateClipper`, `PreGain`, `HardClip`, `OutputTrim`]

## Open Questions

- None
