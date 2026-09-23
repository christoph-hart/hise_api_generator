# container.repitch - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/repitch.md`
- Reference: `scriptnode_enrichment/output/container/repitch.md`

## Naming

- Module ID: `RepitchedReverbSpace`
- Network ID: `repitched_reverb_space`

## Graph Plan

```text
repitched_reverb_space
  ReverbMix              template.dry_wet
    ReverbMix_wet_path
      ReverbResampler    container.repitch
        WetReverb        fx.reverb
      ReverbMix_wet_gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Replace the dry/wet template dummy and preserve its wet gain as the final wet child.
- Channel/routing setup:
  - Required channels: default stereo; repitch supports no more than two channels
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [mono or stereo only, additional channels would pass unchanged]

## Public Parameters

- RepitchFactor -> `ReverbResampler.RepitchFactor` matched
- Target range before connection: `[0.5, 2]`, logarithmic centre `1`
- Macro range: `[0.5, 2]`, logarithmic centre `1`
- Default: `1`
- Mix -> `ReverbMix.DryWet` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.4`

## Defaults To Omit

- `ReverbResampler.RepitchFactor` default `1.0`
- `ReverbResampler.Interpolation` default `Cubic`
- `WetReverb.Damping` default `0.5`
- `WetReverb.Width` default `0.5`
- `WetReverb.Size` default `0.5`

## Locked Build Values

- `ReverbResampler.Interpolation` = `Cubic`
- `WetReverb.Size` = `0.7`
- `WetReverb.Damping` = `0.45`
- `WetReverb.Width` = `0.8`
- Wet-path order = `ReverbResampler`, `ReverbMix_wet_gain`
- Dry/wet crossfade law = `linear`

## Friction Comments To Weave In

- Before `ReverbResampler`: repitch changes the effective sample rate seen by the reverb, not the pitch of the final dry/wet mix.
- Before factor verification: an effects-only child can make the apparent direction seem inverted, so verify both endpoints by ear.
- Before wet-path construction: retain the template wet gain after the resampled reverb.

## Cosmetic Plan

- Main node: `ReverbResampler`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`ReverbMix`, `WetReverb`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`ReverbMix_wet_gain`]
- ShowParameters containers: [`ReverbMix`, `ReverbResampler`]
- Nodes that must stay visible: [`ReverbMix`, `ReverbResampler`, `WetReverb`]

## Open Questions

- None
