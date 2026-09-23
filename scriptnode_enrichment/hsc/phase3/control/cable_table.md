# control.cable_table - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/cable_table.md`
- Reference: `scriptnode_enrichment/output/control/cable_table.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Stereo linear-versus-shaped filter comparison verified with external Table slot 0.

## Naming

- Module ID: `ShapedFilterComparison`
- Network ID: `shaped_filter_comparison`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Interface onInit initializes the external Table slot.
  - Duplicated mono source material is used by the two comparison channels.
- Channel/routing setup verified:
  - Required channels: `exactly 2; left is linear reference and right is table-shaped`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `Cutoff` range `[200..8000]` skewed, default `1000`
- `CutoffShape.Value` range `[0..1]`
- `CutoffShape.Table` external data index `0`
- `LinearFilter.Mode` = `LowPass`
- `ShapedFilter.Mode` = `LowPass`
- Both filter `Q` values = `0.7`
- Both filter `Smoothing` values = `0.02`
- Both filter frequency ranges `[200..8000]` skewed

## Verified Connections

- `shaped_filter_comparison.Cutoff` -> `CutoffShape.Value` matched: true
- `shaped_filter_comparison.Cutoff` -> `LinearFilter.Frequency` matched: true
- `CutoffShape.0` -> `ShapedFilter.Frequency` matched: false, runtime scaled mapping

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module ShapedFilterComparison --container shaped_filter_comparison --inject-param shaped_filter_comparison.Cutoff=200 --probe-param CutoffShape.Value --probe-param LinearFilter.Frequency --probe-param ShapedFilter.Frequency --agent`
  - `hise-cli dsp trace --module ShapedFilterComparison --container shaped_filter_comparison --inject-param shaped_filter_comparison.Cutoff=4100 --probe-param CutoffShape.Value --probe-param LinearFilter.Frequency --probe-param ShapedFilter.Frequency --agent`
  - `hise-cli dsp trace --module ShapedFilterComparison --container shaped_filter_comparison --inject-param shaped_filter_comparison.Cutoff=8000 --probe-param CutoffShape.Value --probe-param LinearFilter.Frequency --probe-param ShapedFilter.Frequency --agent`
- Parameter trace evidence:
  - At `Cutoff=200`, both filters read `200 Hz` and the table input is `0`.
  - At `Cutoff=4100`, the linear filter reads `4100 Hz`, while the table-shaped filter reads `955.3337 Hz`; the table input is `0.8123`.
  - At `Cutoff=8000`, both filters read `8000 Hz` and the table input is `1`.
- Signal trace commands:
  - `hise-cli dsp trace --module ShapedFilterComparison --container shaped_filter_comparison --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. Recursive trace returned non-silent stereo output with separate mono `LinearChannel` and `ShapedChannel` contexts.
- Trace caveats:
  - The midpoint table value is intentionally nonlinear, so intermediate cutoff values diverge while both endpoints remain equal.

## Locked Build Values Applied

- `CutoffShape.Table` external data index = `0`
- Table startup points preserve `(0, 0)` and `(1, 1)` with midpoint `(0.5, 0.25)`.
- Both filters: `Mode = LowPass`, `Q = 0.7`, `Smoothing = 0.02`, frequency range `[200, 8000]`
- `CutoffShape` output -> `ShapedFilter.Frequency`

## Interface Script Setup Applied

- `const var tableProcessor = Synth.getTableProcessor("ShapedFilterComparison");`
- `const var tableData = tableProcessor.getTable(0);`
- `tableData.reset();`
- `tableData.addTablePoint(0.5, 0.25);`
- `tableData.setTablePoint(2, 1.0, 1.0, 0.2);`
- `script show tree --symbols-only` exposes `tableProcessor` as `TableProcessor` and `tableData` as `Table`.

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ShapedFilterComparison --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module ShapedFilterComparison --network shaped_filter_comparison --agent
hise-cli dsp add --module ShapedFilterComparison --type control.cable_table --id CutoffShape --parent shaped_filter_comparison --agent
hise-cli dsp add --module ShapedFilterComparison --type container.multi --id ChannelComparison --parent shaped_filter_comparison --agent
hise-cli dsp add --module ShapedFilterComparison --type container.chain --id LinearChannel --parent ChannelComparison --agent
hise-cli dsp add --module ShapedFilterComparison --type filters.svf --id LinearFilter --parent LinearChannel --agent
hise-cli dsp add --module ShapedFilterComparison --type container.chain --id ShapedChannel --parent ChannelComparison --agent
hise-cli dsp add --module ShapedFilterComparison --type filters.svf --id ShapedFilter --parent ShapedChannel --agent
hise-cli dsp set-complex-data --module ShapedFilterComparison --node CutoffShape --type Table --index 0 --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param Frequency --range "200,8000" --skewFactor 0.3 --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param Frequency --range "200,8000" --skewFactor 0.3 --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param Mode --value LP --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param Mode --value LP --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param Q --value 0.7 --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param Q --value 0.7 --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param Smoothing --value 0.02 --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param Smoothing --value 0.02 --agent
hise-cli dsp create_parameter --module ShapedFilterComparison --container shaped_filter_comparison --id Cutoff --range "200,8000" --default 1000 --skewFactor 0.3 --agent
hise-cli dsp connect --module ShapedFilterComparison --source shaped_filter_comparison --source-param Cutoff --target CutoffShape --param Value --matched --agent
hise-cli dsp connect --module ShapedFilterComparison --source shaped_filter_comparison --source-param Cutoff --target LinearFilter --param Frequency --matched --agent
hise-cli dsp connect --module ShapedFilterComparison --source CutoffShape --target ShapedFilter --param Frequency --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var tableProcessor = Synth.getTableProcessor("ShapedFilterComparison");
const var tableData = tableProcessor.getTable(0);

tableData.reset();
tableData.addTablePoint(0.5, 0.25);
tableData.setTablePoint(2, 1.0, 1.0, 0.2);
HISESCRIPT
hise-cli dsp set --module ShapedFilterComparison --node CutoffShape --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ShapedFilterComparison --node ChannelComparison --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ShapedFilterComparison --node ChannelComparison --param Comment --value '\"**Stereo comparison** - Multi assigns separate mono channel slices to the linear reference and table-shaped filter paths.\"' --agent
hise-cli dsp set --module ShapedFilterComparison --node CutoffShape --param Comment --value '\"**Interpolated curve** - The external 512-point table preserves endpoints while spending more travel in the low-frequency region.\"' --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearFilter --param Comment --value '\"**Linear reference** - Receives the normalized Cutoff control directly.\"' --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedFilter --param Comment --value '\"**Table-shaped response** - Receives the interpolated table output for comparison.\"' --agent
hise-cli dsp set --module ShapedFilterComparison --node LinearChannel --param Folded --value true --agent
hise-cli dsp set --module ShapedFilterComparison --node ShapedChannel --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module ShapedFilterComparison --agent
hise-cli script show tree --module-id Interface --symbols-only --agent
hise-cli dsp trace --module ShapedFilterComparison --container shaped_filter_comparison --inject dirac --probe-recursive --agent
hise-cli dsp save --module ShapedFilterComparison --agent
hise-cli dsp screenshot --module ShapedFilterComparison --scale 200% --output "scriptnode_enrichment/hsc/output/control/cable_table.png" --agent
```

## Comments To Preserve In HSC

- Before routing setup: multi gives each filter one non-overlapping channel for simultaneous comparison.
- Before complex-data setup: external slot 0 permits deterministic Interface-script initialization.
- Before `CutoffShape`: the 512-point table uses linear interpolation, preserving smooth movement despite nonlinear remapping.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - Complex Table examples require external slot binding plus Interface onInit initialization.
- Local-only findings:
  - A nonlinear midpoint can be verified through parameter traces without relying on audible source differences.

## Cosmetics Applied

- Main node: `CutoffShape` colour `0xFF8E44AD`
- Support nodes: [`ChannelComparison`, `LinearFilter`, `ShapedFilter`] colour `0xFF7F6A91`
- Folded nodes: [`LinearChannel`, `ShapedChannel`]
- ShowParameters containers: []
- Visible target nodes: [`CutoffShape`, `ChannelComparison`, `LinearFilter`, `ShapedFilter`]

## Defaults Omitted

- `CutoffShape.Value` default `0.0`

## Open Issues

- None
