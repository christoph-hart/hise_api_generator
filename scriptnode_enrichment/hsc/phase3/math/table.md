# math.table - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/table.md`
- Reference: `scriptnode_enrichment/output/math/table.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with external Table slot initialization from Interface `onInit`.

## Naming

- Module ID: `DrawnTransferShaper`
- Network ID: `drawn_transfer_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `TableLookup.Table` complex data = `Table`, slot `0`, data index `0`
- `tableData.getTableValueNormalised(0.5)` = approximately `0.3`

## Verified Connections

- None

## Trace Validation

- Parameter trace commands:
  - None
- Parameter trace evidence:
  - Interface REPL verified the seeded table value: `Math.abs(tableData.getTableValueNormalised(0.5) - 0.3) < 0.01` returned `true`.
- Signal trace commands:
  - `hise-cli dsp trace --module DrawnTransferShaper --container drawn_transfer_shaper --inject dc --gain 0.5 --inject-before TableLookup --probe-after TableLookup --agent`
- Signal trace evidence:
  - DC `0.5` injected directly before `TableLookup` produced `0.3004` on both channels, proving the external table slot is read by `math.table`.
- Trace caveats:
  - Trace requires the HISE audio engine to be running; otherwise probes can time out before processing executes.

## Locked Build Values Applied

- `SlowRamp.PeriodTime` = `1000`
- `TableLookup.Table` external data index = `0`
- Interface `onInit` creates `tableProcessor` with `Synth.getTableProcessor("DrawnTransferShaper")`
- Interface `onInit` creates `tableData` with `tableProcessor.getTable(0)`
- Table startup points after reset: midpoint `(0.5, 0.3)` and right edge `(1.0, 1.0, 0.2)`

## Interface Script Setup Applied

- `tableData.reset()` clears the external Table slot before deterministic point writes.
- `tableData.addTablePoint(0.5, 0.3)` creates the visible nonlinear midpoint.
- `tableData.setTablePoint(2, 1.0, 1.0, 0.2)` adjusts the right edge curve.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DrawnTransferShaper --agent
hise-cli builder set --module DrawnTransferShaper --network drawn_transfer_shaper --agent
hise-cli dsp add --module DrawnTransferShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module DrawnTransferShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module DrawnTransferShaper --type math.table --id TableLookup --agent
hise-cli dsp set-complex-data --module DrawnTransferShaper --node TableLookup --type Table --index 0 --agent
hise-cli dsp add --module DrawnTransferShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module DrawnTransferShaper --type math.clear --id SignalClear --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var tableProcessor = Synth.getTableProcessor("DrawnTransferShaper");
const var tableData = tableProcessor.getTable(0);

tableData.reset();
tableData.addTablePoint(0.5, 0.3);
tableData.setTablePoint(2, 1.0, 1.0, 0.2);
HISESCRIPT
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module DrawnTransferShaper --agent
hise-cli dsp screenshot --module DrawnTransferShaper --scale 200% --output "scriptnode_enrichment/hsc/output/math/table.png" --agent
```

## Comments To Preserve In HSC

- Before `set-complex-data`: this node has no automatable parameters, so the public interaction is the drawn table itself rather than a matched root macro.
- Before `set-complex-data`: use an external slot because embedded complex data cannot be initialized from Interface script.
- Before `TableLookup`: keep the input in 0..1 because the node clamps its lookup domain.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - Complex-data examples that need programmatic startup data must use external Table or SliderPack slots plus Interface `onInit` initialization.
- Local-only findings:
  - Trace requires the HISE audio engine to be running.

## Cosmetics Applied

- Main node: `TableLookup` colour `0xFF2F80ED`
- Support nodes: [`SlowRamp`, `OutputPeak`] colour `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Visible target nodes: [`SlowRamp`, `TableLookup`, `OutputPeak`]

## Defaults Omitted

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Open Issues

- None
