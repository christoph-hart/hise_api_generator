# math.sin - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/sin.md`
- Reference: `scriptnode_enrichment/output/math/sin.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully through the bipolar-to-unipolar display conversion.

## Naming

- Module ID: `RampToSineConverter`
- Network ID: `ramp_to_sine_converter`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `RadianScale.Value` remains at default `2.0`
- `DisplayRange.Value` remains at default `0.0`

## Verified Connections

- None; all transform nodes use fixed demonstration values.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RampToSineConverter --agent
hise-cli builder set --module RampToSineConverter --network ramp_to_sine_converter --agent
hise-cli dsp add --module RampToSineConverter --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module RampToSineConverter --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module RampToSineConverter --type math.pi --id RadianScale --agent
hise-cli dsp add --module RampToSineConverter --type math.sin --id SineShape --agent
hise-cli dsp add --module RampToSineConverter --type math.sig2mod --id DisplayRange --agent
hise-cli dsp add --module RampToSineConverter --type core.peak --id OutputPeak --agent
hise-cli dsp add --module RampToSineConverter --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Keep the pi stage at its full-cycle setting so one ramp cycle becomes one sine cycle.
- Convert the bipolar sine output to a 0..1 display signal before the peak node.

## Cosmetics

- Main node: `SineShape`, colour `0xFF2F80ED`
- Supporting nodes: `RadianScale`, `DisplayRange`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `RadianScale`, `SineShape`, `DisplayRange`, `OutputPeak`
