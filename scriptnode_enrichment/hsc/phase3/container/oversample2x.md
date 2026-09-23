# container.oversample2x - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/oversample2x.md`
- Reference: `scriptnode_enrichment/output/container/oversample2x.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a lightweight fixed-rate soft-saturation insert.

## Naming

- Module ID: `LightweightSoftSaturation`
- Network ID: `lightweight_soft_saturation`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
lightweight_soft_saturation
  DoubleRateSaturation   container.oversample2x
    PreGain              math.mul
    SoftClip             math.tanh
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

## Verified Parameters

- `DoubleRateSaturation.FilterType` = default `Polyphase`
- `PreGain.Value` range = `1..6`, value `3`
- `SoftClip.Value` = default `1`
- `OutputTrim.Value` = `0.4`
- Root `Drive` range = `1..6`, default `3`

## Verified Connections

- Root `Drive` -> `PreGain.Value`, matched

## Trace Validation

- Command: `hise-cli dsp trace --module LightweightSoftSaturation --container lightweight_soft_saturation --inject dc --gain 0.5 --probe-recursive --probe-param PreGain.Value --trace-compact --agent`
- `DoubleRateSaturation` reported `96000 Hz`, block size `1024`, stereo, from a `48000 Hz` / `512` host context.
- The trace showed pre-gain above unity, bounded tanh output, and the final `0.4` trim.
- `PreGain.Value` reported `3` through the public Drive mapping.
- Runtime status passed.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id LightweightSoftSaturation --agent
hise-cli builder set --module LightweightSoftSaturation --network lightweight_soft_saturation --agent
# Keep gain staging and saturation together so all three stages share the doubled context.
hise-cli dsp add --module LightweightSoftSaturation --type container.oversample2x --id DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.mul --id PreGain --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.tanh --id SoftClip --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.mul --id OutputTrim --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type analyse.fft --id OutputSpectrum --agent
# math.mul permits drive values above unity, unlike the tanh node's 0..1 Value range.
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param Value --range "1,6" --agent
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param Value --value 3 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputTrim --param Value --value 0.4 --agent
hise-cli dsp create_parameter --module LightweightSoftSaturation --container lightweight_soft_saturation --id Drive --range "1,6" --default 3 --agent
hise-cli dsp connect --module LightweightSoftSaturation --source lightweight_soft_saturation --source-param Drive --target PreGain --param Value --matched --agent
# Bypass removes resampling but still runs this complete saturator at the host rate.
hise-cli dsp set --module LightweightSoftSaturation --node lightweight_soft_saturation --param Comment --value '"**Serial topology** - Resampler latency is not reported, so this example has no uncompensated dry branch."' --agent
hise-cli dsp set --module LightweightSoftSaturation --node DoubleRateSaturation --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module LightweightSoftSaturation --node DoubleRateSaturation --param Comment --value '"**Complete gain stage** - Pre-gain, soft clipping, and output trim all share the doubled processing context."' --agent
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node SoftClip --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputTrim --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputSpectrum --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module LightweightSoftSaturation --agent
hise-cli dsp screenshot --module LightweightSoftSaturation --scale 200% --output "scriptnode_enrichment/hsc/output/container/oversample2x.png" --agent
```

## Comments To Preserve In HSC

- Keep all gain stages inside the oversampled context.
- Use `math.mul` for pre-gain above unity.
- Bypass keeps the saturator active at the host rate.
- Avoid an uncompensated dry branch.

## Documentation Feedback

- Live inspection confirmed `SoftClip.Value` defaults to `1`, not `0`; Phase 2 was corrected.

## Open Issues

- None.
