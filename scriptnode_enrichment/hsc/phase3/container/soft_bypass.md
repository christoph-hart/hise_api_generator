# container.soft_bypass - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/soft_bypass.md`
- Reference: `scriptnode_enrichment/output/container/soft_bypass.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `ClickFreeVocalStrip`
- Network ID: `click_free_vocal_strip`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
click_free_vocal_strip
  VocalStrip
    HighPass
    VocalCompressor
    SaturationDrive
    SoftSaturation
```

## Verified Configuration

- Root `StripEnable`: `0..1`, step `1`, default `1`
- Root `StripEnable` -> `VocalStrip.Bypass`
- `0` bypasses; `1` activates processing
- `VocalStrip.SmoothingTime` = `40 ms`
- `VocalStrip.ShowParameters` = `false`
- `HighPass.Mode` = `HighPass`
- `HighPass.Frequency` = `90 Hz`
- `HighPass.Smoothing` = `0.02 s`
- `VocalCompressor.Threshhold` = `-18 dB`
- `VocalCompressor.Ratio` = `3`
- `VocalCompressor.Attack` = `15 ms`
- `VocalCompressor.Release` = `120 ms`
- `SaturationDrive.Value` = `1.5`

## Trace Validation

Using identical seeded noise at the two persistent switch states:

- `StripEnable=0`: dry peak approximately `0.0999`
- `StripEnable=1`: processed peak approximately `0.1556`

The bypass cable terminates at the always-visible container power button. `ShowParameters` is intentionally disabled because no parameter row is needed to display this connection.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ClickFreeVocalStrip --agent
hise-cli builder set --module ClickFreeVocalStrip --network click_free_vocal_strip --agent

# Use one wrapper around the complete serial strip. Series-chained soft bypass containers can click.
hise-cli dsp add --module ClickFreeVocalStrip --type container.soft_bypass --id VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type filters.one_pole --id HighPass --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type dynamics.comp --id VocalCompressor --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type math.mul --id SaturationDrive --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type math.tanh --id SoftSaturation --parent VocalStrip --agent

hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param SmoothingTime --value 40 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Mode --value 1 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Frequency --value 90 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Smoothing --value 0.02 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Threshhold --value -18 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Ratio --value 3 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Attack --value 15 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Release --value 120 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Value --range "0,2" --stepSize 0 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Value --value 1.5 --agent

hise-cli dsp create_parameter --module ClickFreeVocalStrip --container click_free_vocal_strip --id StripEnable --range "0,1" --default 1 --stepSize 1 --agent
# Bypass is a special power-button target, so matched range metadata is intentionally ignored.
hise-cli dsp connect --module ClickFreeVocalStrip --source click_free_vocal_strip --source-param StripEnable --target VocalStrip --param Bypass --matched --agent
# Do not enable ShowParameters: the bypass cable is already visible at the power button.

hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param NodeColour --value 0xFF27AE60 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param Comment --value '"One smoothed wrapper crossfades the complete serial strip over 40 ms; do not series-chain soft bypass containers."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SoftSaturation --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SoftSaturation --param Comment --value '"The active strip applies high-pass filtering, compression, 1.5x drive, and soft saturation."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param Comment --value '"StripEnable 0 bypasses and 1 activates processing. Audio crossfades over SmoothingTime, but child modulation outputs stop immediately on bypass."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp status --module ClickFreeVocalStrip --agent
hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param StripEnable --value 0 --agent
hise-cli dsp trace --module ClickFreeVocalStrip --container click_free_vocal_strip --inject noise --gain 0.1 --seed 1234 --probe-recursive --trace-compact --agent
hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param StripEnable --value 1 --agent
hise-cli dsp trace --module ClickFreeVocalStrip --container click_free_vocal_strip --inject noise --gain 0.1 --seed 1234 --probe-recursive --trace-compact --agent
hise-cli dsp save --module ClickFreeVocalStrip --agent
hise-cli dsp screenshot --module ClickFreeVocalStrip --scale 200% --output "scriptnode_enrichment/hsc/output/container/soft_bypass.png" --agent
```

## Open Issues

- Issue 20 was fixed and verified after the maintainer rebuild.
