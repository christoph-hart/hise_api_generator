# container.fix64_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix64_block.md`
- Reference: `scriptnode_enrichment/output/container/fix64_block.md`

## Naming

- Module ID: `SlowlyEvolvingFilterTone`
- Network ID: `slowly_evolving_filter_tone`

## Graph Plan

```text
slowly_evolving_filter_tone
  SixtyFourSampleMotion  container.fix64_block
    ToneSmoother         control.smoothed_parameter
    EvolvingLowPass      filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Feed deterministic noise into the Script FX.
  - Jump Tone between 0 and 1 and verify that cutoff moves gradually rather than immediately.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [harmonically rich input required for audible cutoff movement]

## Public Parameters

- Tone -> `ToneSmoother.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.25`

## Defaults To Omit

- `ToneSmoother.Value` default `0`
- `ToneSmoother.Enabled` default `On`
- `EvolvingLowPass.Mode` default `LowPass`
- `EvolvingLowPass.Gain` default `0`
- `EvolvingLowPass.Enabled` default `On`

## Locked Build Values

- Maximum child chunk size = `64` samples
- `ToneSmoother.Mode` property = `Linear Ramp`
- `ToneSmoother.SmoothingTime` = `1000` ms
- `ToneSmoother.Enabled` = `On`
- `ToneSmoother` output -> `EvolvingLowPass.Frequency` range = `[200, 8000]`, middle position `1000`
- `EvolvingLowPass.Q` = `0.7`
- `EvolvingLowPass.Smoothing` = `0`

## Friction Comments To Weave In

- Before `SixtyFourSampleMotion`: 64 is the default starting size for adjustable block containers and is sufficient for slowly evolving modulation.
- Before `ToneSmoother`: Linear Ramp reaches the target in exactly 1000 ms; the root parameter may jump, but the output does not.
- Before the frequency connection: configure the skewed 200 to 8000 Hz target range first.
- Before verification: filter Smoothing must remain zero so only ToneSmoother defines the transition.
- Before signal tracing: use noise or another rich source; silence cannot reveal filtering.

## Cosmetic Plan

- Main node: `SixtyFourSampleMotion`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`ToneSmoother`, `EvolvingLowPass`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`SixtyFourSampleMotion`, `ToneSmoother`, `EvolvingLowPass`]

## Open Questions

- None
