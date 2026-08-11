# math.expr - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/expr.md`
- Reference: `scriptnode_enrichment/output/math/expr.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the expression compile autofix and matched public parameter.

## Naming

- Module ID: `ProgrammableScalarTransform`
- Network ID: `programmable_scalar_transform`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.5`
- `ShapeExpr.Value` = `0.4`, range `0.2..0.8`
- `ShapeExpr.Code` = `input > value ? value : (input < -1.0f * value ? -1.0f * value : input)`
- `ClipWidth` = `0.4`, range `0.2..0.8`

## Verified Connections

- `ClipWidth` -> `ShapeExpr.Value`, matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module ProgrammableScalarTransform --container programmable_scalar_transform --inject-param programmable_scalar_transform.ClipWidth=0.65 --probe-param ShapeExpr.Value --agent`
- Parameter trace evidence:
  - Injecting `ClipWidth=0.65` probed `ShapeExpr.Value=0.65`, range `0.2..0.8`, `outOfRange=false`.
- Signal trace commands:
  - `hise-cli dsp trace --module ProgrammableScalarTransform --container programmable_scalar_transform --inject dc --gain 0.9 --inject-before ShapeExpr --probe-after ShapeExpr --agent`
- Signal trace evidence:
  - DC `0.9` injected directly before `ShapeExpr` produced `0.4` on both channels, proving the ternary expression clamps to the current `Value` parameter.
- Trace caveats:
  - Trace requires the HISE audio engine to be running; otherwise probes can time out before processing executes.

## Locked Build Values Applied

- `SeedValue.Value` = `0.5`
- `ShapeExpr.Code` = `input > value ? value : (input < -1.0f * value ? -1.0f * value : input)`
- `ShapeExpr` required the scriptnode compile flag; `dsp status --autofix` / Code-write autofix produced runtime status OK.

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ProgrammableScalarTransform --agent
hise-cli builder set --module ProgrammableScalarTransform --network programmable_scalar_transform --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.add --id SeedValue --agent
hise-cli dsp set --module ProgrammableScalarTransform --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module ProgrammableScalarTransform --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.expr --id ShapeExpr --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Value --range "0.2,0.8" --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Value --value 0.4 --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Code --value "input > value ? value : (input < -1.0f * value ? -1.0f * value : input)" --agent
hise-cli dsp add --module ProgrammableScalarTransform --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ProgrammableScalarTransform --container programmable_scalar_transform --id ClipWidth --range "0.2,0.8" --default 0.4 --agent
hise-cli dsp connect --module ProgrammableScalarTransform --source programmable_scalar_transform --source-param ClipWidth --target ShapeExpr --param Value --matched --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module ProgrammableScalarTransform --agent
hise-cli dsp screenshot --module ProgrammableScalarTransform --scale 200% --output "scriptnode_enrichment/hsc/output/math/expr.png" --agent
```

## Comments To Preserve In HSC

- Before `set Code`: use a tiny one-line SNEX clip formula so the node teaches programmability without extra graph clutter.
- Before `set Code`: use explicit float literals with the `f` suffix to avoid SNEX type mismatch warnings.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - None
- Local-only findings:
  - The `math.expr` example uses a ternary clip formula that compiles cleanly in the CLI workflow.
  - Trace requires the HISE audio engine to be running.

## Cosmetics Applied

- Main node: `ShapeExpr` colour `0xFF2F80ED`
- Support nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`] colour `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Visible target nodes: [`SeedValue`, `InputSpecs`, `ShapeExpr`, `OutputSpecs`]

## Defaults Omitted

- `SignalClear.Value` default `0.0`

## Open Issues

- None
