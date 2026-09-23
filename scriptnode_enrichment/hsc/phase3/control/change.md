# control.change - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/change.md`
- Reference: `scriptnode_enrichment/output/control/change.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Rebuilt from a fresh network XML after the expression parser fix. The quantiser expression now stores without brackets and compiles successfully.

## Naming

- Module ID: `DuplicateFreeFourStepSweep`
- Network ID: `duplicate_free_four_step_sweep`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Network compilation was enabled automatically when the SNEX quantiser expression was applied.
- Channel/routing setup verified:
  - Required channels: `default stereo; StepControl runs in an isolated mono modchain`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `SourceRamp.PeriodTime` = `1000`
- `FourLevelQuantiser.Code` = `Math.min(Math.floor(input * 4.0), 3.0) / 3.0`
- `SteppedFilter.Frequency` range `[300..6000]` skewed
- `CutoffNormalise.Value` range `[0..1]`
- `SteppedFilter.Mode` = `LowPass`
- `SteppedFilter.Q` = `0.7`
- `SteppedFilter.Smoothing` = `0.01`

## Verified Connections

- `SourceRamp.0` -> `FourLevelQuantiser.Value` matched: false, raw modulation output
- `FourLevelQuantiser.0` -> `DistinctValues.Value` matched: false, raw modulation output
- `DistinctValues.0` -> `CutoffNormalise.Value` matched: false
- `CutoffNormalise.0` -> `SteppedFilter.Frequency` matched: false, runtime scaled mapping

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module DuplicateFreeFourStepSweep --container duplicate_free_four_step_sweep --inject dirac --probe-changed-parameters --agent`
- Parameter trace evidence:
  - `FourLevelQuantiser.Code` is stored without brackets after the fresh rebuild, and the setter reports compilation autofix followed by runtime status OK.
  - `DistinctValues` receives the quantised control path after `FourLevelQuantiser`; exact repeated values are suppressed by its stored-value comparison. `CutoffNormalise` then maps the raw transition value into the full filter range.
- Signal trace commands:
  - `hise-cli dsp trace --module DuplicateFreeFourStepSweep --container duplicate_free_four_step_sweep --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. Recursive trace returned non-silent stereo output and the isolated StepControl context processed SourceRamp, FourLevelQuantiser, and DistinctValues.
- Trace caveats:
  - Recursive signal probes show the audio buffer path, not every modulation output value. The endpoint-safe expression is verified from the stored Code property and fresh compile result.

## Locked Build Values Applied

- `SourceRamp.PeriodTime` = `1000`
- `FourLevelQuantiser.Code` = `Math.min(Math.floor(input * 4.0), 3.0) / 3.0`
- `SteppedFilter.Frequency` range = `[300, 6000]`, skewed
- `CutoffNormalise.Value` range = `[0, 1]`
- `SteppedFilter.Mode` = `LowPass`
- `SteppedFilter.Q` = `0.7`
- `SteppedFilter.Smoothing` = `0.01`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DuplicateFreeFourStepSweep --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module DuplicateFreeFourStepSweep --network duplicate_free_four_step_sweep --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type container.modchain --id StepControl --parent duplicate_free_four_step_sweep --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type core.ramp --id SourceRamp --parent StepControl --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type control.cable_expr --id FourLevelQuantiser --parent StepControl --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type control.change --id DistinctValues --parent StepControl --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type control.normaliser --id CutoffNormalise --parent StepControl --agent
hise-cli dsp add --module DuplicateFreeFourStepSweep --type filters.svf --id SteppedFilter --parent duplicate_free_four_step_sweep --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node FourLevelQuantiser --param Code --value 'Math.min(Math.floor(input * 4.0), 3.0) / 3.0' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param Frequency --range "300,6000" --skewFactor 0.3 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param Mode --value LP --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param Q --value 0.7 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param Smoothing --value 0.01 --agent
hise-cli dsp connect --module DuplicateFreeFourStepSweep --source SourceRamp --target FourLevelQuantiser --param Value --agent
hise-cli dsp connect --module DuplicateFreeFourStepSweep --source FourLevelQuantiser --target DistinctValues --param Value --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node CutoffNormalise --param Value --range "0,1" --agent
hise-cli dsp connect --module DuplicateFreeFourStepSweep --source DistinctValues --target CutoffNormalise --param Value --agent
hise-cli dsp connect --module DuplicateFreeFourStepSweep --source CutoffNormalise --target SteppedFilter --param Frequency --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node DistinctValues --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SourceRamp --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node FourLevelQuantiser --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node CutoffNormalise --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node FourLevelQuantiser --param Comment --value '\"**Endpoint-safe quantiser** - The expression emits exactly 0, 1/3, 2/3, or 1 without creating a fifth level at input 1.0.\"' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node DistinctValues --param Comment --value '\"**Duplicate suppression** - Exact repeated plateau values are not forwarded; the initial stored zero suppresses the first zero.\"' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node StepControl --param Comment --value '\"**Isolated control path** - Continuous ramp motion is quantised before it reaches the audible filter.\"' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node SteppedFilter --param Comment --value '\"**Four-step cutoff** - Receives only distinct quantised transitions through the 300..6000 Hz range.\"' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node CutoffNormalise --param Comment --value '\"**Frequency range bridge** - Converts the raw 0..1 change output into the full 300..6000 Hz filter range.\"' --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node StepControl --param Folded --value false --agent
hise-cli dsp set --module DuplicateFreeFourStepSweep --node StepControl --param IsVertical --value false --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module DuplicateFreeFourStepSweep --agent
hise-cli dsp trace --module DuplicateFreeFourStepSweep --container duplicate_free_four_step_sweep --inject dirac --probe-recursive --agent
hise-cli dsp save --module DuplicateFreeFourStepSweep --agent
hise-cli dsp screenshot --module DuplicateFreeFourStepSweep --scale 200% --output "scriptnode_enrichment/hsc/output/control/change.png" --agent
```

## Comments To Preserve In HSC

- Before `FourLevelQuantiser`: the endpoint-safe formula emits exactly four bit-identical plateau values.
- Before `DistinctValues`: exact duplicate comparison has no tolerance and the initial stored zero suppresses the first incoming zero.
- Before `CutoffNormalise`: the change output is raw 0..1 and must be normalized before the filter frequency mapping.
- Before verification: trace quantiser and change outputs together to distinguish repeated upstream values from forwarded transitions.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - Rebuild stale DSP network XML after an expression parser fix; a previously serialized bracketed Code property can silently fall back to passthrough.
  - Insert a normalization bridge after raw change/control outputs before ranged DSP parameters.
- Local-only findings:
  - Recursive signal traces expose the audio buffer path rather than every modulation output value.

## Cosmetics Applied

- Main node: `DistinctValues` colour `0xFF8E44AD`
- Support nodes: [`SourceRamp`, `FourLevelQuantiser`, `CutoffNormalise`, `SteppedFilter`] colour `0xFF7F6A91`
- Folded nodes: []
- ShowParameters containers: []
- Visible target nodes: [`StepControl`, `SourceRamp`, `FourLevelQuantiser`, `DistinctValues`, `CutoffNormalise`, `SteppedFilter`]

## Defaults Omitted

- `FourLevelQuantiser.Value` default `0.0`
- `DistinctValues.Value` default `0.0`

## Open Issues

- None
