# control.cable_expr - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/cable_expr.md`
- Reference: `scriptnode_enrichment/output/control/cable_expr.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Threshold expression compiled successfully and drives a click-free soft-bypass transition.

## Naming

- Module ID: `ThresholdedEffectActivation`
- Network ID: `thresholded_effect_activation`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Network compilation was enabled automatically when the expression code was applied.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `ActivationGate.Value` range `[0..1]`
- `ActivationGate.Code` = `input > 0.5 ? 1.0 : 0.0`
- `ActivationGate.Debug` = `Off`
- `FilteredPath.SmoothingTime` = `40 ms`
- `ActiveFilter.Mode` = `LowPass`
- `ActiveFilter.Frequency` = `1200 Hz`
- `ActiveFilter.Smoothing` = `0.02`
- `Amount` range `[0..1]` default `0`

## Verified Connections

- `thresholded_effect_activation.Amount` -> `ActivationGate.Value` matched: true
- `ActivationGate.0` -> `FilteredPath.Bypassed` matched: false (modulation output)

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject-param thresholded_effect_activation.Amount=0.49 --probe-changed-parameters --agent`
  - `hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject-param thresholded_effect_activation.Amount=0.5 --probe-changed-parameters --agent`
  - `hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject-param thresholded_effect_activation.Amount=0.51 --probe-changed-parameters --agent`
- Parameter trace evidence:
  - Amount values `0.49`, `0.5`, and `0.51` reached `ActivationGate.Value` exactly. The expression code is present and the network is compile-enabled.
- Signal trace commands:
  - `hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject dirac --inject-param thresholded_effect_activation.Amount=0.49 --probe-recursive --agent`
  - `hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject dirac --inject-param thresholded_effect_activation.Amount=0.51 --probe-recursive --agent`
- Signal trace evidence:
  - At `0.49`, `ActiveFilter` passed the Dirac signal, confirming the expression returned bypass state `0`.
  - At `0.51`, `ActiveFilter` was silent while the soft-bypass path remained valid, confirming the expression returned bypass state `1`.
  - The exact midpoint `0.5` is covered by the strict greater-than expression and returns `0`.
- Trace caveats:
  - Soft-bypass smoothing can make a transition block-dependent; endpoint traces validate the steady-state decision.

## Locked Build Values Applied

- `ActivationGate.Code` = `input > 0.5 ? 1.0 : 0.0`
- `ActivationGate.Debug` = `Off`
- `FilteredPath.SmoothingTime` = `40 ms`
- `ActiveFilter.Mode` = `LowPass`
- `ActiveFilter.Frequency` = `1200 Hz`
- `ActiveFilter.Smoothing` = `0.02`
- Network compilation enabled for the SNEX expression.

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ThresholdedEffectActivation --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module ThresholdedEffectActivation --network thresholded_effect_activation --agent
hise-cli dsp add --module ThresholdedEffectActivation --type control.cable_expr --id ActivationGate --parent thresholded_effect_activation --agent
hise-cli dsp add --module ThresholdedEffectActivation --type container.soft_bypass --id FilteredPath --parent thresholded_effect_activation --agent
hise-cli dsp add --module ThresholdedEffectActivation --type filters.svf --id ActiveFilter --parent FilteredPath --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActivationGate --param Code --value 'input > 0.5 ? 1.0 : 0.0' --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActivationGate --param Debug --value false --agent
hise-cli dsp set --module ThresholdedEffectActivation --node FilteredPath --param SmoothingTime --value 40 --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActiveFilter --param Mode --value LP --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActiveFilter --param Frequency --value 1200 --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActiveFilter --param Smoothing --value 0.02 --agent
hise-cli dsp create_parameter --module ThresholdedEffectActivation --container thresholded_effect_activation --id Amount --range "0,1" --default 0 --agent
hise-cli dsp connect --module ThresholdedEffectActivation --source thresholded_effect_activation --source-param Amount --target ActivationGate --param Value --matched --agent
hise-cli dsp connect --module ThresholdedEffectActivation --source ActivationGate --target FilteredPath --param Bypass --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActivationGate --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ThresholdedEffectActivation --node FilteredPath --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActiveFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActivationGate --param Comment --value '\"**Threshold gate** - The expression returns exact zero at and below 0.5, and one above 0.5.\"' --agent
hise-cli dsp set --module ThresholdedEffectActivation --node FilteredPath --param Comment --value '\"**Click-free activation** - Soft bypass smooths the binary expression decision over 40 ms.\"' --agent
hise-cli dsp set --module ThresholdedEffectActivation --node ActiveFilter --param Comment --value '\"**Audible active state** - Lowpass filtering makes the bypass transition observable.\"' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module ThresholdedEffectActivation --agent
hise-cli dsp trace --module ThresholdedEffectActivation --container thresholded_effect_activation --inject dirac --probe-recursive --agent
hise-cli dsp save --module ThresholdedEffectActivation --agent
hise-cli dsp screenshot --module ThresholdedEffectActivation --scale 200% --output "scriptnode_enrichment/hsc/output/control/cable_expr.png" --agent
```

## Comments To Preserve In HSC

- Before compilation: exported plugins require the network compiled to C++ because the SNEX JIT is unavailable.
- Before `ActivationGate`: output is unscaled but this formula deliberately returns exact zero or one.
- Before `FilteredPath`: the soft wrapper converts the binary decision into a click-free audio transition.
- Before verification: expression compile failure falls back to passthrough and must not be mistaken for threshold behaviour.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - SNEX expression nodes require compilation before export; verify the compile status before tracing behavior.
- Local-only findings:
  - The bypass target is reported as `FilteredPath.Bypassed` by the live connection table even when addressed as `Bypass` in the command.

## Cosmetics Applied

- Main node: `ActivationGate` colour `0xFF8E44AD`
- Support nodes: [`FilteredPath`, `ActiveFilter`] colour `0xFF7F6A91`
- Folded nodes: []
- ShowParameters containers: []
- Visible target nodes: [`ActivationGate`, `FilteredPath`, `ActiveFilter`]

## Defaults Omitted

- `ActivationGate.Value` default `0.0`
- `ActivationGate.Code` default `input`

## Open Issues

- None
