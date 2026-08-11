# fx.phase_delay - Phase 3 Live Build Notes

## Result

Built and verified a PhaseFX-style six-stage allpass network in a monophonic `ScriptFX` named `PhaseFXRecreation` with network ID `phase_fx_recreation`.

## Verified Topology

```text
phase_fx_recreation
  MidiContext          container.midichain
    FramePhaseFX       container.frame2_block
      PhaseMod         core.extra_mod
      SweepRange       control.minmax
      PhaseMix         template.dry_wet -> container.split
        PhaseMix_dry_path
          PhaseMix_dry_wet_mixer
          PhaseMix_dry_gain
        PhaseMix_wet_path
          ResonantLoop template.feedback_delay -> container.fix32_block
            ResonantLoop_fb_out  routing.receive
            Stage1               fx.phase_delay
            Stage2               fx.phase_delay
            Stage3               fx.phase_delay
            Stage4               fx.phase_delay
            Stage5               fx.phase_delay
            Stage6               fx.phase_delay
            ResonantLoop_fb_in   routing.send
          PhaseMix_wet_gain
```

## Source-Derived Parent Rule

`core.extra_mod` processes HISE events, so in a monophonic `ScriptFX` it needs a MIDI/event-processing context. The valid nesting is `container.midichain -> container.frame2_block -> core.extra_mod`.

The reverse order is invalid: `container.midichain` rejects frame-mode prepare specs (`blockSize == 1`), so it cannot live inside `container.frame2_block`.

## Template Expansion

`template.dry_wet` expands to:

- `PhaseMix_dry_path`
- `PhaseMix_dry_wet_mixer`
- `PhaseMix_dry_gain`
- `PhaseMix_wet_path`
- `PhaseMix_dummy`
- `PhaseMix_wet_gain`

`PhaseMix_dummy` was removed after adding the wet processor path.

`template.feedback_delay` expands to:

- `ResonantLoop_fb_out` (`routing.receive`) with `Feedback`
- `ResonantLoop_delay` (`core.fix_delay`)
- `ResonantLoop_fb_in` (`routing.send`)

`ResonantLoop_delay` was removed so the feedback path uses only the frame context's one-sample feedback latency.

## Important Reordering

- `ResonantLoop` was moved before `PhaseMix_wet_gain` so dry/wet gain scales the processed wet output.
- `ResonantLoop_fb_in` was moved after `Stage6` so the feedback send captures the six-stage allpass cascade output.

## Connections

```text
PhaseMod.0 -> SweepRange.Value
SweepRange.0 -> Stage1.Frequency
SweepRange.0 -> Stage2.Frequency
SweepRange.0 -> Stage3.Frequency
SweepRange.0 -> Stage4.Frequency
SweepRange.0 -> Stage5.Frequency
SweepRange.0 -> Stage6.Frequency
PhaseMix_dry_wet_mixer.0 -> PhaseMix_dry_gain.Gain
PhaseMix_dry_wet_mixer.1 -> PhaseMix_wet_gain.Gain
ResonantLoop_fb_in.routing -> ResonantLoop_fb_out
PhaseMix.DryWet -> PhaseMix_dry_wet_mixer.Value
phase_fx_recreation.Mix -> PhaseMix.DryWet
phase_fx_recreation.Feedback -> ResonantLoop_fb_out.Feedback
phase_fx_recreation.Frequency1 -> SweepRange.Minimum
phase_fx_recreation.Frequency2 -> SweepRange.Maximum
```

## Public Controls

- `Mix`: range `0..1`, default `0.75`, matched to `PhaseMix.DryWet`
- `Feedback`: range `0..1`, default `0.7`, matched to `ResonantLoop_fb_out.Feedback`; target range was capped at `0..0.99`
- `Frequency1`: range `20..20000`, default `400`, matched to `SweepRange.Minimum`
- `Frequency2`: range `20..20000`, default `1600`, matched to `SweepRange.Maximum`

## Verification

- `hise-cli dsp status --module PhaseFXRecreation --agent` returned `ok=true`.
- Parameter trace verified `Frequency1=800` and `Frequency2=2400` propagate to `SweepRange.Minimum`, `SweepRange.Maximum`, and `Stage1.Frequency`.
- Recursive signal trace with active feedback timed out, so Phase 4 validation should rely on runtime status, parameter propagation, HSC execution, and publish screenshot generation.
