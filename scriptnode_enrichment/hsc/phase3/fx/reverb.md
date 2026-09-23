# fx.reverb - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/reverb.md`
- Reference: `scriptnode_enrichment/output/fx/reverb.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with `fx.reverb` inside an expanded dry/wet template using direct `RoomMix.DryWet` defaults and normal wet-path reordering.

## Naming

- Module ID: `WetReverbWrapper`
- Network ID: `wet_reverb_wrapper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: replaced `RoomMix_dummy` with `RoomVerb` in `RoomMix_wet_path`; moved `RoomVerb` to index `0` and `RoomMix_wet_gain` to index `1`
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `wet_reverb_wrapper.Mix` = `0.35`, range `[0, 1]`
- `wet_reverb_wrapper.Size` = `0.65`, range `[0.1, 0.9]`
- `wet_reverb_wrapper.Damping` = `0.45`, range `[0, 1]`
- `RoomVerb.Size` = `0.65`, range `[0.1, 0.9]`
- `RoomVerb.Damping` = `0.45`, range `[0, 1]`
- `RoomVerb.Width` left at default `0.5` and intentionally not exposed
- `RoomMix.DryWet` = `0.35`

## Verified Connections

- `RoomMix_dry_wet_mixer.0 -> RoomMix_dry_gain.Gain`
- `RoomMix_dry_wet_mixer.1 -> RoomMix_wet_gain.Gain`
- `RoomMix.DryWet -> RoomMix_dry_wet_mixer.Value`
- `wet_reverb_wrapper.Mix -> RoomMix.DryWet`
- `wet_reverb_wrapper.Size -> RoomVerb.Size`
- `wet_reverb_wrapper.Damping -> RoomVerb.Damping`

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module WetReverbWrapper --container wet_reverb_wrapper --inject-param wet_reverb_wrapper.Mix=0.8 --inject-param wet_reverb_wrapper.Size=0.75 --inject-param wet_reverb_wrapper.Damping=0.25 --probe-param RoomMix.DryWet --probe-param RoomMix_dry_wet_mixer.Value --probe-param RoomVerb.Size --probe-param RoomVerb.Damping --agent`
- Parameter trace evidence:
  - `RoomMix.DryWet` = `0.8`
  - `RoomMix_dry_wet_mixer.Value` = `0.8`
  - `RoomVerb.Size` = `0.75`
  - `RoomVerb.Damping` = `0.25`
- Signal trace commands:
  - `hise-cli dsp trace --module WetReverbWrapper --container wet_reverb_wrapper --inject noise --gain 0.25 --seed 1234 --delay-ms 200 --probe-recursive --trace-compact --agent`
- Signal trace evidence:
  - Delayed noise trace showed wet path signal after `RoomVerb` around `[0.0277, -0.0318]` and post-wet-gain output around `[0.0037, -0.0042]`, proving the reverb path is audible through the template dry/wet mixer.
- Trace caveats:
  - Reverb output is delayed/diffuse; a first-block dirac or noise trace can show the wet path as silent. Use delayed trace for the tail.

## Locked Build Values Applied

- `RoomVerb.Size.range` = `[0.1, 0.9]`
- `RoomVerb.Size` = `0.65`
- `RoomVerb.Damping` = `0.45`
- `RoomMix.DryWet` = `0.35`
- `RoomMix_dry_wet_mixer.1 -> RoomMix_wet_gain.Gain` remains present after wet-path reordering.
- `RoomVerb.Width` is not exposed because exploration found the current setter writes damping instead of width.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WetReverbWrapper --agent
hise-cli builder set --module WetReverbWrapper --network wet_reverb_wrapper --agent
hise-cli dsp add --module WetReverbWrapper --type template.dry_wet --id RoomMix --agent
hise-cli dsp add --module WetReverbWrapper --type fx.reverb --id RoomVerb --parent RoomMix_wet_path --agent
hise-cli dsp remove --module WetReverbWrapper --node RoomMix_dummy --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --index 0 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_wet_gain --index 1 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix --param DryWet --value 0.35 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Size --range "0.1,0.9" --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Size --value 0.65 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Damping --value 0.45 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Mix --range "0,1" --default 0.35 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Size --range "0.1,0.9" --default 0.65 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Damping --range "0,1" --default 0.45 --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Mix --target RoomMix --param DryWet --matched --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Size --target RoomVerb --param Size --matched --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Damping --target RoomVerb --param Damping --matched --agent
# Expose DryWet so the root Mix cable is visible on the inner container.
hise-cli dsp set --module WetReverbWrapper --node RoomMix --param ShowParameters --value true --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_dry_wet_mixer --param Folded --value true --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_dry_gain --param Folded --value true --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_wet_gain --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module WetReverbWrapper --agent
hise-cli dsp screenshot --module WetReverbWrapper --scale 200% --output "scriptnode_enrichment/hsc/output/fx/reverb.png" --agent
```

## Comments To Preserve In HSC

- Before `template.dry_wet`: `fx.reverb` outputs wet signal only, so a practical insert needs an external dry/wet mixer.
- Before reordering the wet path: keep `RoomVerb` before `RoomMix_wet_gain`, because the template's wet gain must remain the final wet-path stage.
- Before public parameters: expose the reliable room controls and omit `Width` until the setter bug is fixed.

## Documentation Feedback

- Docs updated:
- `scriptnode_enrichment/hsc/issues.md` marks the two dry/wet CLI issues as fixed and verified.
- General rules promoted:
  - None
- Local-only findings:
  - Reverb tail verification needs delayed trace; immediate dirac/noise traces can miss the wet output.

## Cosmetics Applied

- Main node: `RoomVerb` colour `0xFF2F80ED`
- Support nodes: [`RoomMix`] colour `0xFF6F8FAF`
- Folded nodes: [`RoomMix_dry_wet_mixer`, `RoomMix_dry_gain`, `RoomMix_wet_gain`]
- Visible target nodes: [`RoomMix`, `RoomVerb`]

## Defaults Omitted

- `RoomVerb.Width` default `0.5`
- `RoomMix_dry_wet_mixer.Value` default `0`
- `RoomMix_dry_gain.Gain` default `0`
- `RoomMix_wet_gain.Gain` default `0`

## Open Issues

- None
