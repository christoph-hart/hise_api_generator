# container.oversample16x - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/oversample16x.md`
- Reference: `scriptnode_enrichment/output/container/oversample16x.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as an upper-bound nested-sine stress test rather than a default production recommendation.

## Naming

- Module ID: `ExtremeFoldbackStressTest`
- Network ID: `extreme_foldback_stress_test`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
extreme_foldback_stress_test
  SixteenRateStress      container.oversample16x
    NestedSineStress     math.expr
  OutputSpectrum         analyse.fft
```

## Verified Parameters

- `SixteenRateStress.FilterType` = default `Polyphase`
- `NestedSineStress.Code` = `Math.sin(Math.sin(input * (1.0f + value * 12.0f)) * 8.0f)`
- `NestedSineStress.Value` = `0.7`
- Root `Stress` range = `0..1`, default `0.7`

## Verified Connections

- Root `Stress` -> `NestedSineStress.Value`, matched

## Trace Validation

- Command: `hise-cli dsp trace --module ExtremeFoldbackStressTest --container extreme_foldback_stress_test --inject dc --gain 0.5 --probe-recursive --probe-param NestedSineStress.Value --trace-compact --agent`
- `SixteenRateStress` reported `768000 Hz`, block size `8192`, stereo, from a `48000 Hz` / `512` host context.
- `NestedSineStress.Value` reported `0.7`; the nested expression generated full-scale nonlinear output on both channels.
- With the container bypassed, its child reported `48000 Hz` / `512` and continued processing the same expression.
- Runtime status passed.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ExtremeFoldbackStressTest --agent
hise-cli builder set --module ExtremeFoldbackStressTest --network extreme_foldback_stress_test --agent
# Only the pathological nonlinear stage receives the sixteenfold CPU multiplier.
hise-cli dsp add --module ExtremeFoldbackStressTest --type container.oversample16x --id SixteenRateStress --agent
hise-cli dsp add --module ExtremeFoldbackStressTest --type math.expr --id NestedSineStress --parent SixteenRateStress --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param Code --value '"Math.sin(Math.sin(input * (1.0f + value * 12.0f)) * 8.0f)"' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param Value --value 0.7 --agent
hise-cli dsp add --module ExtremeFoldbackStressTest --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp create_parameter --module ExtremeFoldbackStressTest --container extreme_foldback_stress_test --id Stress --range "0,1" --default 0.7 --agent
hise-cli dsp connect --module ExtremeFoldbackStressTest --source extreme_foldback_stress_test --source-param Stress --target NestedSineStress --param Value --matched --agent
# Treat 16x as a diagnostic upper bound and compare it against matched 4x and 8x captures.
hise-cli dsp set --module ExtremeFoldbackStressTest --node extreme_foldback_stress_test --param Comment --value '"**16x diagnostic** - Reserve this factor for cases where matched 4x and 8x comparisons still leave audible aliasing."' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node SixteenRateStress --param NodeColour --value 0xFFE74C3C --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node SixteenRateStress --param Comment --value '"**Extreme CPU cost** - Only the nested sine stress stage runs at sixteen times the host rate."' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param NodeColour --value 0xFF965E58 --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node OutputSpectrum --param NodeColour --value 0xFF965E58 --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node OutputSpectrum --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module ExtremeFoldbackStressTest --agent
hise-cli dsp screenshot --module ExtremeFoldbackStressTest --scale 200% --output "scriptnode_enrichment/hsc/output/container/oversample16x.png" --agent
```

## Comments To Preserve In HSC

- Oversample only the pathological nonlinear expression.
- Treat 16x as a diagnostic upper bound.
- Compare matched 4x, 8x, and 16x captures rather than using bypass as the only quality comparison.
- Bypass is the 1x baseline and keeps the expression active.

## Documentation Feedback

- Live parameter names and defaults matched the reference.
- No general documentation change required.

## Open Issues

- Scalar traces verify the 16x processing context but cannot decide whether its spectral improvement over matched 4x and 8x captures is audible enough to justify the CPU cost.
