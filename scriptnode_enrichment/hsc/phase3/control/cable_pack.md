# control.cable_pack - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/cable_pack.md`
- Reference: `scriptnode_enrichment/output/control/cable_pack.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: External eight-step SliderPack initialized from Interface onInit and connected to a one-bar synced filter sequence.

## Naming

- Module ID: `TempoSyncedFilterSteps`
- Network ID: `tempo_synced_filter_steps`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Interface onInit initializes external SliderPack slot 0.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `BarPlayhead.Tempo` = `1/1` (index `0`, one bar)
- `BarPlayhead.Multiplier` = `1`
- `BarPlayhead.UpdateMode` = `Synced`
- `BarPlayhead.AddToSignal` = `Off`
- `BarPlayhead.Inactive` = `Zero`
- `StepLookup.Value` range `[0..1]`
- `StepLookup.SliderPack` external data index `0`
- SliderPack size `8`
- `SequencedFilter.Frequency` range `[200..8000]` skewed
- `SequencedFilter.Mode` = `LowPass`
- `SequencedFilter.Smoothing` = `0.01`

## Verified Connections

- `BarPlayhead.0` -> `StepLookup.Value` matched: false (modulation output)
- `StepLookup.0` -> `SequencedFilter.Frequency` matched: false, runtime scaled mapping

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module TempoSyncedFilterSteps --container tempo_synced_filter_steps --inject dc --gain 0.15 --inject-before StepLookup --probe-after StepLookup --agent`
- Parameter trace evidence:
  - External SliderPack binding is confirmed by `dsp show`: `dataType=SliderPack`, `slotIndex=0`, `dataIndex=0`.
  - Interface symbols expose `stepProcessor` as `SliderPackProcessor` and `stepData` as `SliderPackData`.
  - Interface onInit writes eight values: `[0.15, 0.75, 0.35, 0.9, 0.25, 0.6, 0.45, 1.0]`.
- Signal trace commands:
  - `hise-cli dsp trace --module TempoSyncedFilterSteps --container tempo_synced_filter_steps --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. The network processes stereo signal through the sequenced lowpass filter without adding the clock ramp to the audio path.
- Trace caveats:
  - Transport-dependent clock phase is not deterministic without a running DAW transport. The external slot binding and eight-value initialization are verified structurally and through Interface symbols.

## Locked Build Values Applied

- `StepLookup.SliderPack` external data index = `0`
- SliderPack size = `8`
- Startup values = `[0.15, 0.75, 0.35, 0.9, 0.25, 0.6, 0.45, 1.0]`
- `BarPlayhead.Tempo` = `1/1`
- `BarPlayhead.Mode` = `Synced`
- `BarPlayhead.AddToSignal` = `Off`
- `BarPlayhead.Multiplier` = `1`
- `BarPlayhead.Inactive` = `0`
- `SequencedFilter.Frequency` range = `[200, 8000]`, skewed
- `SequencedFilter.Mode` = `LowPass`
- `SequencedFilter.Smoothing` = `0.01`

## Interface Script Setup Applied

- `const var stepProcessor = Synth.getSliderPackProcessor("TempoSyncedFilterSteps");`
- `const var stepData = stepProcessor.getSliderPack(0);`
- `stepData.setNumSliders(8);`
- `stepData.setAllValues([0.15, 0.75, 0.35, 0.9, 0.25, 0.6, 0.45, 1.0]);`
- `script show tree --symbols-only` exposes `stepProcessor` as `SliderPackProcessor` and `stepData` as `SliderPackData`.

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id TempoSyncedFilterSteps --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module TempoSyncedFilterSteps --network tempo_synced_filter_steps --agent
hise-cli dsp add --module TempoSyncedFilterSteps --type core.clock_ramp --id BarPlayhead --parent tempo_synced_filter_steps --agent
hise-cli dsp add --module TempoSyncedFilterSteps --type control.cable_pack --id StepLookup --parent tempo_synced_filter_steps --agent
hise-cli dsp add --module TempoSyncedFilterSteps --type filters.svf --id SequencedFilter --parent tempo_synced_filter_steps --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param Tempo --value 0 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param AddToSignal --value 0 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param UpdateMode --value 1 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param Inactive --value 0 --agent
hise-cli dsp set-complex-data --module TempoSyncedFilterSteps --node StepLookup --type SliderPack --slot 0 --index 0 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node SequencedFilter --param Frequency --range "200,8000" --skewFactor 0.3 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node SequencedFilter --param Mode --value LP --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node SequencedFilter --param Smoothing --value 0.01 --agent
hise-cli dsp connect --module TempoSyncedFilterSteps --source BarPlayhead --target StepLookup --param Value --agent
hise-cli dsp connect --module TempoSyncedFilterSteps --source StepLookup --target SequencedFilter --param Frequency --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var stepProcessor = Synth.getSliderPackProcessor("TempoSyncedFilterSteps");
const var stepData = stepProcessor.getSliderPack(0);

stepData.setNumSliders(8);
stepData.setAllValues([0.15, 0.75, 0.35, 0.9, 0.25, 0.6, 0.45, 1.0]);
HISESCRIPT
hise-cli dsp set --module TempoSyncedFilterSteps --node StepLookup --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node SequencedFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node BarPlayhead --param Comment --value '\"**One-bar playhead** - Synced mode scans the external eight-step pack once per bar without adding the ramp to audio.\"' --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node StepLookup --param Comment --value '\"**Nearest-neighbour step lookup** - The normalized playhead selects one of eight values without interpolation.\"' --agent
hise-cli dsp set --module TempoSyncedFilterSteps --node SequencedFilter --param Comment --value '\"**Sequenced cutoff** - The selected SliderPack value maps to a 200..8000 Hz lowpass cutoff.\"' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module TempoSyncedFilterSteps --agent
hise-cli script show tree --module-id Interface --symbols-only --agent
hise-cli dsp trace --module TempoSyncedFilterSteps --container tempo_synced_filter_steps --inject dirac --probe-recursive --agent
hise-cli dsp save --module TempoSyncedFilterSteps --agent
hise-cli dsp screenshot --module TempoSyncedFilterSteps --scale 200% --output "scriptnode_enrichment/hsc/output/control/cable_pack.png" --agent
```

## Comments To Preserve In HSC

- Before complex-data setup: use external slot 0 because Interface script cannot write embedded pack data.
- Before `StepLookup`: nearest-neighbour lookup creates eight held zones without interpolation.
- Before endpoint verification: the normalized endpoint must resolve to the final slider without indexing beyond the eight-entry pack.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - Complex SliderPack examples require external slot binding plus Interface onInit initialization.
- Local-only findings:
  - Transport-dependent clock phase requires a running host transport for deterministic endpoint timing.

## Cosmetics Applied

- Main node: `StepLookup` colour `0xFF8E44AD`
- Support nodes: [`BarPlayhead`, `SequencedFilter`] colour `0xFF7F6A91`
- Folded nodes: []
- ShowParameters containers: []
- Visible target nodes: [`BarPlayhead`, `StepLookup`, `SequencedFilter`]

## Defaults Omitted

- `StepLookup.Value` default `0.0`

## Open Issues

- None
