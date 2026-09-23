# fx.phase_delay - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/phase_delay.md`
- Reference: `scriptnode_enrichment/output/fx/phase_delay.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a monophonic ScriptFX.

## Naming

- Module ID: `PhaseFXRecreation`
- Network ID: `phase_fx_recreation`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: enabled one ScriptFX extra modulation slot and wrapped the frame network in a MIDI context.
- Channel/routing setup verified: default stereo routing.

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

## Builder Setup Applied

- Host context: Script FX
- Module ID: PhaseFXRecreation
- Network ID: phase_fx_recreation

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id PhaseFXRecreation --agent
hise-cli builder set --module PhaseFXRecreation --network phase_fx_recreation --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Mix --range "0,1" --default 0.75 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Feedback --range "0,1" --default 0.7 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Frequency1 --range "20,20000" --default 400 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Frequency2 --range "20,20000" --default 1600 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id ModDepth --range "0,1" --default 0.5 --externalModulation Combined --agent
hise-cli dsp add --module PhaseFXRecreation --type container.midichain --id MidiContext --agent
hise-cli dsp add --module PhaseFXRecreation --type container.frame2_block --id FramePhaseFX --parent MidiContext --agent
hise-cli dsp add --module PhaseFXRecreation --type core.extra_mod --id PhaseMod --parent FramePhaseFX --agent
hise-cli dsp set --module PhaseFXRecreation --node PhaseMod --param Index --value 0 --agent
hise-cli dsp add --module PhaseFXRecreation --type control.minmax --id SweepRange --parent FramePhaseFX --agent
hise-cli dsp add --module PhaseFXRecreation --type template.dry_wet --id PhaseMix --parent FramePhaseFX --agent
hise-cli dsp add --module PhaseFXRecreation --type template.feedback_delay --id ResonantLoop --parent PhaseMix_wet_path --agent
hise-cli dsp remove --module PhaseFXRecreation --node PhaseMix_dummy --agent
hise-cli dsp remove --module PhaseFXRecreation --node ResonantLoop_delay --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage1 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage2 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage3 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage4 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage5 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage6 --parent ResonantLoop --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_in --index 7 --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop --index 0 --agent
hise-cli dsp set --module PhaseFXRecreation --node PhaseMix --param DryWet --value 0.75 --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_out --param Feedback --range "0,0.99" --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_out --param Feedback --value 0.7 --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Minimum --range "20,20000" --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Maximum --range "20,20000" --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Minimum --value 400 --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Maximum --value 1600 --agent
hise-cli dsp connect --module PhaseFXRecreation --source PhaseMod --target SweepRange --param Value --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage1 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage2 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage3 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage4 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage5 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage6 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Mix --target PhaseMix --param DryWet --matched --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Feedback --target ResonantLoop_fb_out --param Feedback --matched --agent
# Expose DryWet so the root Mix cable is visible on the inner container.
hise-cli dsp set --module PhaseFXRecreation --node PhaseMix --param ShowParameters --value true --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Frequency1 --target SweepRange --param Minimum --matched --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Frequency2 --target SweepRange --param Maximum --matched --agent
```

