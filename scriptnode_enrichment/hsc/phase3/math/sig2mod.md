# math.sig2mod - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/sig2mod.md`
- Reference: `scriptnode_enrichment/output/math/sig2mod.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with adjacent before/after peak displays.

## Naming

- Module ID: `AudioToModulation`
- Network ID: `audio_to_modulation`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowOscillator.Mode` = `4`
- `SlowOscillator.Frequency` = `20` (minimum supported by `core.oscillator`)
- `SlowOscillator.Range` = `LFO`

## Verified Connections

- None; the converter is demonstrated as a fixed signal transform.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AudioToModulation --agent
hise-cli builder set --module AudioToModulation --network audio_to_modulation --agent
hise-cli dsp add --module AudioToModulation --type core.oscillator --id SlowOscillator --agent
hise-cli dsp set --module AudioToModulation --node SlowOscillator --param Mode --value 4 --agent
hise-cli dsp set --module AudioToModulation --node SlowOscillator --param Frequency --value 20 --agent
hise-cli dsp add --module AudioToModulation --type core.peak --id SourcePeak --agent
hise-cli dsp add --module AudioToModulation --type math.sig2mod --id RangeConverter --agent
hise-cli dsp add --module AudioToModulation --type core.peak --id ConvertedPeak --agent
hise-cli dsp add --module AudioToModulation --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Keep the source and converted peak displays adjacent.
- The LFO-style source is slow enough for the range conversion to be visible.

## Cosmetics

- Main node: `RangeConverter`, colour `0xFF2F80ED`
- Supporting nodes: `SourcePeak`, `ConvertedPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowOscillator`, `SourcePeak`, `RangeConverter`, `ConvertedPeak`
