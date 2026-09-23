# container.oversample8x - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/oversample8x.md`
- Reference: `scriptnode_enrichment/output/container/oversample8x.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as an aggressive sine-folding example where 8x must be justified against 4x.

## Naming

- Module ID: `AggressiveSineFoldDistortion`
- Network ID: `aggressive_sine_fold_distortion`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
aggressive_sine_fold_distortion
  EightRateFolder        container.oversample8x
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

## Verified Parameters

- `EightRateFolder.FilterType` = default `Polyphase`
- `SineFolder.Code` = `Math.sin(input * (1.0f + value * 14.0f))`
- `SineFolder.Value` = `0.65`
- Root `Fold` range = `0..1`, default `0.65`

## Verified Connections

- Root `Fold` -> `SineFolder.Value`, matched

## Trace Validation

- Command: `hise-cli dsp trace --module AggressiveSineFoldDistortion --container aggressive_sine_fold_distortion --inject dc --gain 0.5 --probe-recursive --probe-param SineFolder.Value --trace-compact --agent`
- `EightRateFolder` reported `384000 Hz`, block size `4096`, stereo, from a `48000 Hz` / `512` host context.
- `SineFolder.Value` reported `0.65`; the expression generated full-scale folded output on both channels.
- With the container bypassed, its child reported `48000 Hz` / `512` and continued processing the same expression.
- Runtime status passed.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AggressiveSineFoldDistortion --agent
hise-cli builder set --module AggressiveSineFoldDistortion --network aggressive_sine_fold_distortion --agent
# Only the severe nonlinear stage receives the eightfold CPU multiplier.
hise-cli dsp add --module AggressiveSineFoldDistortion --type container.oversample8x --id EightRateFolder --agent
hise-cli dsp add --module AggressiveSineFoldDistortion --type math.expr --id SineFolder --parent EightRateFolder --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param Code --value '"Math.sin(input * (1.0f + value * 14.0f))"' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param Value --value 0.65 --agent
hise-cli dsp add --module AggressiveSineFoldDistortion --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp create_parameter --module AggressiveSineFoldDistortion --container aggressive_sine_fold_distortion --id Fold --range "0,1" --default 0.65 --agent
hise-cli dsp connect --module AggressiveSineFoldDistortion --source aggressive_sine_fold_distortion --source-param Fold --target SineFolder --param Value --matched --agent
# Compare its spectrum and CPU against 4x before selecting this fixed factor.
hise-cli dsp set --module AggressiveSineFoldDistortion --node aggressive_sine_fold_distortion --param Comment --value '"**Quality check** - Compare against 4x before accepting the eightfold child CPU cost."' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node EightRateFolder --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node EightRateFolder --param Comment --value '"**Severe nonlinearity only** - The sine folder is oversampled while spectrum analysis stays at the host rate."' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node OutputSpectrum --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module AggressiveSineFoldDistortion --agent
hise-cli dsp screenshot --module AggressiveSineFoldDistortion --scale 200% --output "scriptnode_enrichment/hsc/output/container/oversample8x.png" --agent
```

## Comments To Preserve In HSC

- Oversample only the nonlinear expression.
- Compare 8x against 4x before accepting the CPU cost.
- Bypass is a 1x processing comparison, not silence.
- Avoid an uncompensated parallel dry branch.

## Documentation Feedback

- Live parameter names and defaults matched the reference.
- No general documentation change required.

## Open Issues

- A meaningful 4x versus 8x aliasing decision requires matched source audio and listening or FFT inspection; scalar trace metrics only verify processing context and signal flow.
