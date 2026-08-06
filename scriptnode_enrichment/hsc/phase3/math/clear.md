# math.clear - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/clear.md`
- Reference: `scriptnode_enrichment/output/math/clear.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully; the replacement branch clears inherited signal before its oscillator.

## Naming

- Module ID: `BranchLayerReset`
- Network ID: `branch_layer_reset`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo split branches

## Verified Parameters

- `ReplacementOsc.Frequency` = `220`
- `ReplacementTrim.Gain` = `-12`
- `BranchReset.Value` remains at default `0.0`

## Verified Connections

- `LayerSplit` -> `DryBranch` and `ReplacementBranch`
- `ReplacementBranch` -> `BranchReset` -> `ReplacementOsc` -> `ReplacementTrim`

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id BranchLayerReset --agent
hise-cli builder set --module BranchLayerReset --network branch_layer_reset --agent
hise-cli dsp add --module BranchLayerReset --type container.split --id LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type container.chain --id DryBranch --parent LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type container.chain --id ReplacementBranch --parent LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type math.clear --id BranchReset --parent ReplacementBranch --agent
hise-cli dsp add --module BranchLayerReset --type core.oscillator --id ReplacementOsc --parent ReplacementBranch --agent
hise-cli dsp set --module BranchLayerReset --node ReplacementOsc --param Frequency --value 220 --agent
hise-cli dsp add --module BranchLayerReset --type core.gain --id ReplacementTrim --parent ReplacementBranch --agent
hise-cli dsp set --module BranchLayerReset --node ReplacementTrim --param Gain --value -12 --agent
```

## Comments To Preserve In HSC

- The lesson is branch initialization, not end-of-chain muting.
- Clear the inherited split signal before the replacement oscillator adds its layer.
- The dry branch remains visible as the contrast case.

## Cosmetics

- Main node: `BranchReset`, colour `0xFF2F80ED`
- Supporting nodes: `LayerSplit`, `ReplacementOsc`, `ReplacementTrim`, colour `0xFF6F8FAF`
- Folded nodes: `DryBranch`
- Visible nodes: `LayerSplit`, `ReplacementBranch`, `BranchReset`, `ReplacementOsc`
