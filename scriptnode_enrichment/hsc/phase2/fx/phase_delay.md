# fx.phase_delay - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/phase_delay.md`
- Reference: `scriptnode_enrichment/output/fx/phase_delay.md`

## Naming

- Module ID: `PhaseFXRecreation`
- Network ID: `phase_fx_recreation`

## Graph Plan

```text
phase_fx_recreation
  MidiContext           container.midichain
    FramePhaseFX        container.frame2_block
      PhaseMod          core.extra_mod
      SweepRange        control.minmax
      PhaseMix          template.dry_wet
        PhaseMix_wet_path
          ResonantLoop  template.feedback_delay
            ResonantLoop_fx
              Stage1    fx.phase_delay
              Stage2    fx.phase_delay
              Stage3    fx.phase_delay
              Stage4    fx.phase_delay
              Stage5    fx.phase_delay
              Stage6    fx.phase_delay
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable one extra modulation slot for the parent Script FX module before relying on `core.extra_mod`: `HISE_NUM_SCRIPTNODE_FX_MODS >= 1`.
  - Put `MidiContext` outside `FramePhaseFX`. `core.extra_mod` needs MIDI/event context in a monophonic ScriptFX, but `container.midichain` cannot live inside a frame container.
  - Put `PhaseMod`, `SweepRange`, `PhaseMix`, and `ResonantLoop` inside `FramePhaseFX` so modulation, dry/wet mixing, feedback, and allpass processing share the same sample-by-sample context.
  - Template child IDs for `template.feedback_delay` must be inspected before inserting the six-stage allpass cascade into the feedback path.
  - Remove the feedback template's delay node after expansion; PhaseFX feedback should use only the one-sample frame feedback state, not a separate delay line.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Mix -> `PhaseMix.DryWet` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.75`
- Feedback -> internal feedback gain parameter of `ResonantLoop` matched
- Target range before connection: `[0, 0.99]`
- Macro range: `[0, 1]`
- Default: `0.7`
- Frequency1 -> `SweepRange.Minimum` matched
- Target range before connection: `[20, 20000]`
- Macro range: `[20, 20000]`
- Default: `400`
- Frequency2 -> `SweepRange.Maximum` matched
- Target range before connection: `[20, 20000]`
- Macro range: `[20, 20000]`
- Default: `1600`

## Defaults To Omit

- `Stage1.Frequency` default `400`
- `Stage2.Frequency` default `400`
- `Stage3.Frequency` default `400`
- `Stage4.Frequency` default `400`
- `Stage5.Frequency` default `400`
- `Stage6.Frequency` default `400`

## Locked Build Values

- `PhaseMod.Index` = `0`
- `PhaseMod.ProcessSignal` = default disabled
- `SweepRange.Value` receives `PhaseMod` output
- `SweepRange.Minimum` = `400`
- `SweepRange.Maximum` = `1600`
- `SweepRange.Minimum.range` = `[20, 20000]`
- `SweepRange.Maximum.range` = `[20, 20000]`
- `SweepRange.Skew` = `1`
- `SweepRange.Step` = `0`
- All `Stage*.Frequency.range` = `[20, 20000]`
- All six stage frequencies receive the same unscaled output from `SweepRange`
- `MidiContext` must contain `FramePhaseFX`; `FramePhaseFX` must contain `PhaseMod`, `SweepRange`, `PhaseMix`, `ResonantLoop`, and all six `Stage*` nodes.
- Remove the `template.feedback_delay` internal delay node so the feedback path has the frame container's one-sample latency only.
- Feedback defaults to `0.7`; if the feedback template target uses raw gain, cap its target range at `0.99` to match PhaseFX safety scaling.
- The topology is intended as a 1:1 PhaseFX recreation: external phase modulation selects a normalised sweep position, `control.minmax` maps it between Frequency1 and Frequency2, feedback is applied before the six allpass stages, the allpass cascade output is mixed with dry signal through `PhaseMix`, and the feedback loop has only one-sample frame latency.

## Friction Comments To Weave In

- Before `MidiContext`: `core.extra_mod` needs a MIDI/event-processing context in a monophonic ScriptFX, so wrap the frame container in `container.midichain`.
- Before `FramePhaseFX`: keep `PhaseMod` and `SweepRange` inside the frame container. If the external modulation pickup or range mapping sits outside this context, the allpass frequency updates at block/control rate while the feedback loop runs sample-by-sample, creating modulation latency and zippering that the original PhaseFX topology avoids. `container.midichain` must stay outside the frame container because it rejects frame-mode prepare specs.
- Before `core.extra_mod`: HISE PhaseFX has no internal LFO; its Phase Modulation chain supplies the sweep position, so this scriptnode version reads slot `0` with `core.extra_mod`.
- Before `control.minmax`: Frequency1 and Frequency2 are not two separate allpass stages; they are the lower and upper bounds for the shared sweep frequency.
- Before `template.feedback_delay`: PhaseFX is not just a dry/wet allpass chain; feedback around the cascade creates the resonant phaser notches. Remove the template's delay node so the feedback is frame feedback rather than an echo delay.
- Before stage frequency connections: HISE PhaseFX sweeps all six allpass stages together.
- Before Feedback macro: feedback must remain below unity because the original module applies safety scaling internally.

## Cosmetic Plan

- Main node: `Stage1`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`MidiContext`, `FramePhaseFX`, `Stage2`, `Stage3`, `Stage4`, `Stage5`, `Stage6`, `ResonantLoop`, `PhaseMix`, `PhaseMod`, `SweepRange`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`MidiContext`, `FramePhaseFX`, `PhaseMix`, `ResonantLoop`, `Stage1`, `Stage2`, `Stage3`, `Stage4`, `Stage5`, `Stage6`, `PhaseMod`, `SweepRange`]

## Open Questions

- Phase 3 must verify recursive trace specs showing `MidiContext` contains `FramePhaseFX`, and `PhaseMod`, `SweepRange`, `PhaseMix`, `ResonantLoop`, and all six stages are inside `FramePhaseFX` with frame processing.
- Phase 3 must verify that the internal delay node from `template.feedback_delay` was removed and that feedback behaviour uses only the frame context's one-sample feedback latency.
- Phase 3 must verify the exact CLI/HISE setup needed to expose one ScriptFX extra modulation slot for `core.extra_mod.Index = 0`.
