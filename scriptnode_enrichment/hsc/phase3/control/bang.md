# control.bang - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/bang.md`
- Reference: `scriptnode_enrichment/output/control/bang.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Rebuilt successfully after the Mode serialization fix. Added `control.normaliser` because `control.bang` emits raw 0..1 values.

## Naming

- Module ID: `DesynchronisedSampleHold`
- Network ID: `desynchronised_sample_hold`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - HISE development use only; do not present this timer-based example as export-safe.
- Channel/routing setup verified:
  - Required channels: `default stereo; SampleControl runs as isolated mono control context`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `SourceRamp.PeriodTime` = `700` range `[200..2000]` stepSize `0.1`
- `TriggerTimer.Interval` = `230` range `[50..500]` stepSize `0.1`
- `TriggerTimer.Mode` = `Ping`
- `SteppedFilter.Frequency` = `1000` range `[200..8000]` skewed
- `SteppedFilter.Mode` = `LP`
- `SteppedFilter.Smoothing` = `0.02` range `[0..1]`
- `CutoffNormaliser.Value` range `[0..1]`

## Verified Connections

- `SourceRamp.0` -> `HeldValue.Value` matched: false (the source is a modulation output, so `--matched` is ignored)
- `TriggerTimer.0` -> `HeldValue.Bang` matched: false (the source is a modulation output, so `--matched` is ignored)
- `HeldValue.0` -> `CutoffNormaliser.Value` matched: false
- `CutoffNormaliser.0` -> `SteppedFilter.Frequency` matched: false
- `desynchronised_sample_hold.RampPeriod` -> `SourceRamp.PeriodTime` matched: true
- `desynchronised_sample_hold.TriggerInterval` -> `TriggerTimer.Interval` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module DesynchronisedSampleHold --container desynchronised_sample_hold --inject-param desynchronised_sample_hold.RampPeriod=1000 --inject-param desynchronised_sample_hold.TriggerInterval=300 --probe-param SourceRamp.PeriodTime --probe-param TriggerTimer.Interval --probe-param HeldValue.Value --probe-param CutoffNormaliser.Value --probe-param SteppedFilter.Frequency --agent`
- Parameter trace evidence:
  - `RampPeriod=1000` reached `SourceRamp.PeriodTime=1000`; `TriggerInterval=300` reached `TriggerTimer.Interval=300`; the held value reached `CutoffNormaliser.Value=0.8374` and `SteppedFilter.Frequency=4516.8953` with `outOfRange=false`.
- Signal trace commands:
  - `hise-cli dsp trace --module DesynchronisedSampleHold --container desynchronised_sample_hold --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. Recursive trace returned non-silent stereo output from `SteppedFilter`, with peak `0.0273` at index `26`. `SampleControl` used a mono control context at 6000 Hz, 64-sample blocks; the parent remained stereo at 48000 Hz and 512-sample blocks.
- Trace caveats:
  - `control.timer` is documented as HISE-development-only because of crash risk in exported plugins and standalone apps.

## Locked Build Values Applied

- `TriggerTimer.Mode` = `Ping`
- `SourceRamp.PeriodTime` = `700`
- `TriggerTimer.Interval` = `230`
- `SteppedFilter.Frequency` range = `[200, 8000]`, skewed
- `SteppedFilter.Mode` = `LP`
- `SteppedFilter.Smoothing` = `0.02`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DesynchronisedSampleHold --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module DesynchronisedSampleHold --network desynchronised_sample_hold --agent
hise-cli dsp add --module DesynchronisedSampleHold --type container.modchain --id SampleControl --parent desynchronised_sample_hold --agent
hise-cli dsp add --module DesynchronisedSampleHold --type core.ramp --id SourceRamp --parent SampleControl --agent
hise-cli dsp add --module DesynchronisedSampleHold --type control.timer --id TriggerTimer --parent SampleControl --agent
hise-cli dsp add --module DesynchronisedSampleHold --type control.bang --id HeldValue --parent SampleControl --agent
hise-cli dsp add --module DesynchronisedSampleHold --type control.normaliser --id CutoffNormaliser --parent desynchronised_sample_hold --agent
hise-cli dsp add --module DesynchronisedSampleHold --type filters.svf --id SteppedFilter --parent desynchronised_sample_hold --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SourceRamp --param PeriodTime --value 700 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SourceRamp --param PeriodTime --range "200,2000" --agent
hise-cli dsp set --module DesynchronisedSampleHold --node TriggerTimer --param Interval --value 230 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node TriggerTimer --param Interval --range "50,500" --agent
hise-cli dsp set --module DesynchronisedSampleHold --node TriggerTimer --param Mode --value Ping --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SteppedFilter --param Frequency --range "200,8000" --skewFactor 0.3 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SteppedFilter --param Mode --value LP --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SteppedFilter --param Smoothing --value 0.02 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node CutoffNormaliser --param Value --range "0,1" --agent
hise-cli dsp create_parameter --module DesynchronisedSampleHold --container desynchronised_sample_hold --id RampPeriod --range "200,2000" --default 700 --agent
hise-cli dsp create_parameter --module DesynchronisedSampleHold --container desynchronised_sample_hold --id TriggerInterval --range "50,500" --default 230 --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source SourceRamp --target HeldValue --param Value --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source TriggerTimer --target HeldValue --param Bang --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source HeldValue --target CutoffNormaliser --param Value --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source CutoffNormaliser --target SteppedFilter --param Frequency --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source desynchronised_sample_hold --source-param RampPeriod --target SourceRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module DesynchronisedSampleHold --source desynchronised_sample_hold --source-param TriggerInterval --target TriggerTimer --param Interval --matched --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SampleControl --param ShowParameters --value true --agent
hise-cli dsp set --module DesynchronisedSampleHold --node HeldValue --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SourceRamp --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node TriggerTimer --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node CutoffNormaliser --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SteppedFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DesynchronisedSampleHold --node HeldValue --param Comment --value '\"**Sample-and-hold trigger** - Value updates stored state; output changes only when Bang receives a value above 0.5.\"' --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SourceRamp --param Comment --value '\"**Desynchronised source** - The non-integer period ratio samples a different ramp phase on successive timer pings.\"' --agent
hise-cli dsp set --module DesynchronisedSampleHold --node SampleControl --param Comment --value '\"**Hidden control path** - Isolates the ramp and timer from the audible filter signal.\"' --agent
hise-cli dsp set --module DesynchronisedSampleHold --node CutoffNormaliser --param Comment --value '\"**Range bridge** - Converts the held 0..1 output into normalized input for the 200..8000 Hz cutoff range.\"' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module DesynchronisedSampleHold --agent
hise-cli dsp trace --module DesynchronisedSampleHold --container desynchronised_sample_hold --inject dirac --probe-recursive --agent
hise-cli dsp save --module DesynchronisedSampleHold --agent
hise-cli dsp screenshot --module DesynchronisedSampleHold --scale 200% --output "scriptnode_enrichment/hsc/output/control/bang.png" --agent
```

## Comments To Preserve In HSC

- Before builder setup: `control.timer` has a documented crash risk outside HISE development use.
- Before `HeldValue`: Value only updates stored state; output changes only when Bang receives a value above 0.5.
- Before period settings: the non-integer period ratio samples a different ramp phase on successive timer pings.
- Before `CutoffNormaliser`: `control.bang` outputs raw 0..1 values, so the normaliser is required to map them into the filter cutoff range.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/control/bang.md`: added the normaliser support node and corrected the canonical topology.
  - `scriptnode_enrichment/hsc/phase2/control/bang.md`: added the normaliser and the required visible container setting.
- General rules promoted:
  - Raw control-node outputs require an explicit normalization bridge before targeting a ranged parameter.
- Local-only findings:
  - `control.timer` remains a HISE-development-only constraint for this example.

## Cosmetics Applied

- Main node: `HeldValue` colour `0xFF8E44AD`
- Support nodes: [`SourceRamp`, `TriggerTimer`, `CutoffNormaliser`, `SteppedFilter`] colour `0xFF7F6A91`
- Folded nodes: []
- ShowParameters containers: [`SampleControl`]
- Visible target nodes: [`SampleControl`, `SourceRamp`, `TriggerTimer`, `HeldValue`, `CutoffNormaliser`, `SteppedFilter`]

## Defaults Omitted

- `HeldValue.Value` default `0.0`
- `HeldValue.Bang` default `Off`

## Open Issues

- `control.timer` has a known crash risk outside HISE development use; the example is restricted to HISE development.
