# container.dynamic_blocksize - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/dynamic_blocksize.md`
- Reference: `scriptnode_enrichment/output/container/dynamic_blocksize.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Final topology was rebuilt, cosmetically configured, saved, and captured. The user explicitly approved wrapping up despite the unresolved temporary trace timeout at BlockSize index 0.

## Naming

- Module ID: `AdjustableModulationStaircase`
- Network ID: `adjustable_modulation_staircase`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Added `BlockInspector` for visible local-spec inspection only.
  - Used a one-second ramp folded around `0.5` to make coarse zipper steps more audible.
  - Monitored the intentionally DC-rich diagnostic output at a safe level.
- Channel/routing setup verified:
  - Required channels: `default stereo; StepControl uses an isolated mono control buffer`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `adjustable_modulation_staircase.BlockSize` = `4` range `0..7` stepSize `1`
- `AdjustableBlocks.BlockSize` = `4` range `0..7` stepSize `1`
- `SourceRamp.PeriodTime` = `1000` range `0.1..1000` stepSize `0.1`
- `CentreRamp.Value` = `0.5` range `0..1` stepSize `0`
- `StaircaseOutput.Value` = `0` range `0..1` stepSize `0`

## Verified Connections

- `adjustable_modulation_staircase.BlockSize` -> `AdjustableBlocks.BlockSize` matched: true
- `ChunkValue.0` -> `StaircaseOutput.Value` matched: false

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module AdjustableModulationStaircase --container adjustable_modulation_staircase --inject silence --inject-param adjustable_modulation_staircase.BlockSize=0 --probe-recursive --probe-param AdjustableBlocks.BlockSize --probe-param StaircaseOutput.Value --trace-compact --agent`
- Parameter trace evidence:
  - The final temporary parameter trace timed out, so no complete index `0..7` parameter trace set is available.
  - An earlier persistent index-0 test confirmed `AdjustableBlocks.BlockSize=0`, child `blockSize=1`, and a changing StaircaseOutput value, but it predates the final folded-ramp topology.
- Signal trace commands:
  - Same recursive command as the parameter trace above.
- Signal trace evidence:
  - No final automated signal evidence because index-0 temporary injection timed out.
  - Runtime status passed on the final topology, and the user approved the live UI behavior and requested that the node be wrapped up without further trace work.
- Trace caveats:
  - Open Issue 11: temporary index-0 trace injection can time out while the dynamic container re-prepares.
  - Runtime size changes may intentionally output one silent host buffer during re-preparation.
  - `BlockInspector` is an uncompileable design-time inspection node and is removed during C++ export.

## Locked Build Values Applied

- Raw BlockSize index table = `[1, 8, 16, 32, 64, 128, 256, 512]`
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `StaircaseOutput.Value` range = `0..1`
- Visual startup BlockSize index = `4` (`64` samples)

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AdjustableModulationStaircase --agent
hise-cli builder set --module AdjustableModulationStaircase --network adjustable_modulation_staircase --agent

hise-cli dsp add --module AdjustableModulationStaircase --type container.dynamic_blocksize --id AdjustableBlocks --agent
# Inspection only: BlockInspector displays local specs and may be omitted without changing behavior.
hise-cli dsp add --module AdjustableModulationStaircase --type analyse.specs --id BlockInspector --parent AdjustableBlocks --agent
hise-cli dsp add --module AdjustableModulationStaircase --type container.modchain --id StepControl --parent AdjustableBlocks --agent
hise-cli dsp add --module AdjustableModulationStaircase --type core.ramp --id SourceRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type math.sub --id CentreRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type math.abs --id FoldRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type core.peak --id ChunkValue --parent StepControl --agent
# This additive stage intentionally turns the held control value into a DC-rich audible staircase.
hise-cli dsp add --module AdjustableModulationStaircase --type math.add --id StaircaseOutput --parent AdjustableBlocks --agent

hise-cli dsp set --module AdjustableModulationStaircase --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param Value --value 0.5 --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StaircaseOutput --param Value --range "0,1" --agent
hise-cli dsp create_parameter --module AdjustableModulationStaircase --container adjustable_modulation_staircase --id BlockSize --range "0,7" --default 4 --stepSize 1 --agent
hise-cli dsp connect --module AdjustableModulationStaircase --source adjustable_modulation_staircase --source-param BlockSize --target AdjustableBlocks --param BlockSize --matched --agent
# Expose BlockSize so the root cable is visible on the inner container.
hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param ShowParameters --value true --agent
hise-cli dsp connect --module AdjustableModulationStaircase --source ChunkValue --target StaircaseOutput --param Value --agent

hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param Comment --value '"**Adjustable modulation staircase** - BlockSize selects child processing chunks from one sample through 512 samples."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node BlockInspector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node BlockInspector --param Comment --value '"Inspection only: displays local processing specifications and does not affect signal flow or block-size behavior."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StepControl --param Comment --value '"The one-second ramp is folded into a slow triangle so coarse block updates become audible zipper steps."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node SourceRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node FoldRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node ChunkValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StaircaseOutput --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param Folded --value true --agent
hise-cli dsp set --module AdjustableModulationStaircase --node FoldRamp --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module AdjustableModulationStaircase --agent
hise-cli dsp screenshot --module AdjustableModulationStaircase --scale 200% --output "scriptnode_enrichment/hsc/output/container/dynamic_blocksize.png" --agent
```

## Comments To Preserve In HSC

- Before BlockSize: The raw value is an index into `[1, 8, 16, 32, 64, 128, 256, 512]`, not a sample count.
- Before `BlockInspector`: This design-time node is for visible inspection only and may be omitted without changing behavior.
- Before `StepControl`: The modulation source and target remain inside the dynamic container so they share its cadence.
- Before `CentreRamp`: Subtract `0.5` and take the absolute value to fold the one-second ramp into an audible triangular staircase.
- Before `StaircaseOutput`: The additive node intentionally emits a unipolar DC-rich diagnostic signal from silence.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/dynamic_blocksize.md`: Added the inspection node and slow folded-ramp rationale.
  - `scriptnode_enrichment/hsc/phase2/container/dynamic_blocksize.md`: Normalized final topology, values, friction comments, and cosmetics.
- General rules promoted:
  - None
- Local-only findings:
  - `BlockInspector` is deliberately optional and design-time only.
  - The `StaircaseOutput` explanation is preserved as an HSC command comment because Issue 12 prevents writing its Comment property.

## Cosmetics Applied

- Main node: `AdjustableBlocks` colour `0xFF2F80ED`
- Support nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`] colour `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]
- ShowParameters containers: [`AdjustableBlocks`]
- Visible target nodes: [`AdjustableBlocks`, `BlockInspector`, `StepControl`, `SourceRamp`, `ChunkValue`, `StaircaseOutput`]

## Defaults Omitted

- `AdjustableBlocks.BlockSize` default `4`
- `FoldRamp.Value` default `0`
- `StaircaseOutput.Value` default `0`

## Open Issues

- Issue 11: Temporary trace injection at BlockSize index 0 times out.
- Issue 12: The CLI cannot write the `math.add` Comment property; user approved preserving the explanation only as an HSC command comment.
