# container.oversample - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/oversample.md`
- Reference: `scriptnode_enrichment/output/container/oversample.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a selectable sine-folding quality example covering 1x through 16x.

## Naming

- Module ID: `SelectableAntiAliasingQuality`
- Network ID: `selectable_anti_aliasing_quality`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
selectable_anti_aliasing_quality
  QualityResampler       container.oversample
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

## Verified Parameters

- `QualityResampler.Oversampling` range = `0..4`, step `1`, value `2` (`4x`)
- `QualityResampler.FilterType` = default `Polyphase`
- `SineFolder.Code` = `Math.sin(input * (1.0f + value * 12.0f))`
- `SineFolder.Value` = `0.7`
- Root `Quality` range = `0..4`, step `1`, default `2`

## Verified Connections

- Root `Quality` -> `QualityResampler.Oversampling`, matched

## Trace Validation

- Command: `hise-cli dsp trace --module SelectableAntiAliasingQuality --container selectable_anti_aliasing_quality --inject dc --gain 0.5 --probe-recursive --probe-param SineFolder.Value --trace-compact --agent`
- `QualityResampler` reported `192000 Hz`, block size `2048`, stereo, from a `48000 Hz` / `512` host context.
- `SineFolder.Value` reported `0.7`; its signal reached approximately `-1.0` on both channels.
- With `QualityResampler` bypassed, its child reported the host `48000 Hz` / `512` context and still processed the expression.
- Runtime status passed before and after trace validation.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SelectableAntiAliasingQuality --agent
hise-cli builder set --module SelectableAntiAliasingQuality --network selectable_anti_aliasing_quality --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type container.oversample --id QualityResampler --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type math.expr --id SineFolder --parent QualityResampler --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param Code --value '"Math.sin(input * (1.0f + value * 12.0f))"' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param Value --value 0.7 --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Oversampling --range "0,4" --stepSize 1 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Oversampling --value 2 --agent
# Quality is an exponent index: None, 2x, 4x, 8x, 16x. Changing it re-prepares the child chain.
hise-cli dsp create_parameter --module SelectableAntiAliasingQuality --container selectable_anti_aliasing_quality --id Quality --range "0,4" --default 2 --stepSize 1 --agent
hise-cli dsp connect --module SelectableAntiAliasingQuality --source selectable_anti_aliasing_quality --source-param Quality --target QualityResampler --param Oversampling --matched --agent
# Expose Oversampling so the root Quality cable is visible on the inner container.
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param ShowParameters --value true --agent
# Keep only the nonlinear stage oversampled. Unreported latency makes an uncompensated dry branch unsuitable.
hise-cli dsp set --module SelectableAntiAliasingQuality --node selectable_anti_aliasing_quality --param Comment --value '"**Serial topology** - Unreported resampler latency makes an uncompensated parallel dry path unsuitable."' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Comment --value '"**Setup control** - Quality is an exponent index; changing it re-prepares only the nonlinear child chain."' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node OutputSpectrum --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module SelectableAntiAliasingQuality --agent
hise-cli dsp screenshot --module SelectableAntiAliasingQuality --scale 200% --output "scriptnode_enrichment/hsc/output/container/oversample.png" --agent
```

## Comments To Preserve In HSC

- Quality is a setup-time exponent index rather than a modulation target.
- Only the nonlinear child is oversampled.
- Bypass removes resampling but continues child processing at the host rate.
- Do not add an uncompensated parallel dry path because resampler latency is not reported.

## Documentation Feedback

- Live parameter names and defaults matched the reference.
- No general documentation change required.

## Open Issues

- The labels `None, 2x, 4x, 8x, 16x` are semantic values of the integer index; the CLI macro metadata does not expose custom labels.
