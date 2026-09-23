# container.fix32_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix32_block.md`
- Reference: `scriptnode_enrichment/output/container/fix32_block.md`

## Naming

- Module ID: `SidechainDynamicMidCut`
- Network ID: `sidechain_dynamic_mid_cut`

## Graph Plan

```text
sidechain_dynamic_mid_cut
  ThirtyTwoSampleDucker  container.fix32_block
    InternalSidechain    container.sidechain
      ChannelSlices      container.multi
        MainAudio        container.chain
        KeyDetector      container.no_midi
          KeyOscillator  core.oscillator
          KeyFollower    dynamics.envelope_follower
          CutDepthPMA    control.pma_unscaled
      DynamicMidEQ       filters.svf_eq
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Feed noise or a harmonically rich stereo signal into the Script FX.
  - Verify silence, low-level, and full-level MaxCut behavior while the internal key oscillator runs.
- Channel/routing setup:
  - Required channels: default stereo externally; four channels inside `InternalSidechain`
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [channels 0-1 main input; channels 2-3 generated key; auxiliary pair discarded on exit]

## Public Parameters

- MaxCut -> `CutDepthPMA.Value` raw unscaled connection
- Macro range: `[-18, 0]` dB
- Default: `-9` dB

## Defaults To Omit

- `MainAudio` is intentionally empty
- `KeyOscillator.Mode` default `Sine`
- `KeyOscillator.Gate` default `On`
- `KeyFollower.ProcessSignal` default `Off`
- `CutDepthPMA.Add` default `0`
- `DynamicMidEQ.Enabled` default `On`

## Locked Build Values

- Maximum child chunk size = `32` samples
- `ChannelSlices` has exactly two stereo children
- `KeyOscillator.Frequency` range = `[0.5, 8]`
- `KeyOscillator.Frequency` = `2`
- `KeyFollower.Attack` = `10` ms
- `KeyFollower.Release` = `150` ms
- `KeyFollower.ProcessSignal` = `Off`
- `CutDepthPMA.Multiply` range = `[0, 1]`
- `CutDepthPMA.Add` = `0`
- `KeyFollower` output -> `CutDepthPMA.Multiply`
- `CutDepthPMA` output -> `DynamicMidEQ.Gain` range = `[0, -18]` dB
- `DynamicMidEQ.Mode` = `Peak`
- `DynamicMidEQ.Frequency` = `1800` Hz
- `DynamicMidEQ.Q` = `2.0`
- `DynamicMidEQ.Smoothing` = `0`

## Friction Comments To Weave In

- Before `ThirtyTwoSampleDucker`: 32 samples is the maximum chunk size and a practical general-purpose envelope-follower cadence.
- Before `InternalSidechain`: auxiliary channels are generated internally and discarded on exit; this is not an external DAW sidechain input.
- Before `MainAudio`: the branch is intentionally empty so channels 0-1 pass unchanged into the EQ.
- Before `DynamicMidEQ`: keep the EQ after `ChannelSlices` so key analysis completes before each chunk reaches the gain target.
- Before `CutDepthPMA`: Multiply is normalised, but Value carries raw negative dB from MaxCut.
- Before verification: EQ Smoothing must remain zero so the follower and fixed-block cadence remain authoritative.

## Cosmetic Plan

- Main node: `ThirtyTwoSampleDucker`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`InternalSidechain`, `ChannelSlices`, `KeyDetector`, `KeyOscillator`, `KeyFollower`, `CutDepthPMA`, `DynamicMidEQ`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`MainAudio`]
- Nodes that must stay visible: [`ThirtyTwoSampleDucker`, `InternalSidechain`, `ChannelSlices`, `KeyDetector`, `KeyOscillator`, `KeyFollower`, `CutDepthPMA`, `DynamicMidEQ`]

## Open Questions

- None
