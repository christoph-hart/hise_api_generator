# container.repitch - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/repitch.md`
- Reference: `scriptnode_enrichment/output/container/repitch.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `RepitchedReverbSpace`
- Network ID: `repitched_reverb_space`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
repitched_reverb_space
  ReverbMix
    ReverbMix_dry_path
      ReverbMix_dry_wet_mixer
      ReverbMix_dry_gain
    ReverbMix_wet_path
      ReverbResampler
        WetReverb
      ReverbMix_wet_gain
```

## Verified Configuration

- Root `RepitchFactor`: `0.5..2`, default `1`
- Root `Mix`: `0..1`, default `0.4`
- `ReverbResampler.RepitchFactor`: `0.5..2`, step size `0`
- `ReverbResampler.Interpolation` = `Cubic`
- `WetReverb.Size` = `0.7`
- `WetReverb.Damping` = `0.45`
- `WetReverb.Width` = `0.8`
- Root `RepitchFactor` -> `ReverbResampler.RepitchFactor`, matched
- Root `Mix` -> `ReverbMix.DryWet`, matched
- Wet-path order: `ReverbResampler`, `ReverbMix_wet_gain`
- `ReverbMix.ShowParameters` = `true`
- `ReverbResampler.ShowParameters` = `true`

## Trace Validation

- Repitch factors `0.5`, `1`, and `2` propagated correctly.
- Delayed Dirac traces produced nonzero stereo reverb tails at all factors.
- A 100 ms delayed trace completed without the former negative timing metadata.
- Runtime status passed with API `0.11.0`.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RepitchedReverbSpace --agent
hise-cli builder set --module RepitchedReverbSpace --network repitched_reverb_space --agent

hise-cli dsp add --module RepitchedReverbSpace --type template.dry_wet --id ReverbMix --agent
# Only the wet reverb is placed in the changed sample-rate context.
hise-cli dsp add --module RepitchedReverbSpace --type container.repitch --id ReverbResampler --parent ReverbMix_wet_path --agent
hise-cli dsp add --module RepitchedReverbSpace --type fx.reverb --id WetReverb --parent ReverbResampler --agent
hise-cli dsp remove --module RepitchedReverbSpace --node ReverbMix_dummy --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --index 0 --agent
# Preserve the generated wet gain as the last wet-path node.
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_gain --index 1 --agent

hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param RepitchFactor --range "0.5,2" --stepSize 0 --middlePosition 1 --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param RepitchFactor --value 1 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Size --value 0.7 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Damping --value 0.45 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Width --value 0.8 --agent

hise-cli dsp create_parameter --module RepitchedReverbSpace --container repitched_reverb_space --id RepitchFactor --range "0.5,2" --default 1 --middlePosition 1 --agent
hise-cli dsp create_parameter --module RepitchedReverbSpace --container repitched_reverb_space --id Mix --range "0,1" --default 0.4 --agent
hise-cli dsp connect --module RepitchedReverbSpace --source repitched_reverb_space --source-param RepitchFactor --target ReverbResampler --param RepitchFactor --matched --agent
hise-cli dsp connect --module RepitchedReverbSpace --source repitched_reverb_space --source-param Mix --target ReverbMix --param DryWet --matched --agent

# Expose both inner container targets so their root cables are visible.
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param ShowParameters --value true --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param ShowParameters --value true --agent

hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param Comment --value '"Changes the effective sample rate seen by WetReverb. Effects-only pitch direction can seem inverted, so verify both factor endpoints by ear."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param Comment --value '"Only the wet reverb is repitched. The dry signal remains at the host sample rate."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Comment --value '"This 100 percent wet reverb runs at the effective sample rate supplied by ReverbResampler."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_path --param Comment --value '"Keep ReverbMix_wet_gain last after the resampled reverb."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node repitched_reverb_space --param Comment --value '"repitch supports mono or stereo only. Additional channels pass unchanged, and unreported resampling latency rules out an uncompensated parallel path."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_gain --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp trace --module RepitchedReverbSpace --container repitched_reverb_space --inject dirac --gain 0.2 --inject-param repitched_reverb_space.RepitchFactor=0.5 --delay-ms 100 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp save --module RepitchedReverbSpace --agent
hise-cli dsp screenshot --module RepitchedReverbSpace --scale 200% --output "scriptnode_enrichment/hsc/output/container/repitch.png" --agent
```

## Open Issues

- Issue 19 was fixed and verified after the maintainer rebuild.
