# math.clear - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/clear.md`
- Reference: `scriptnode_enrichment/output/math/clear.md`

## Naming

- Module ID: `BranchLayerReset`
- Network ID: `branch_layer_reset`

## Graph Plan

```text
branch_layer_reset
  LayerSplit            container.split
    DryBranch           container.chain
    ReplacementBranch   container.chain
      BranchReset       math.clear
      ReplacementOsc    core.oscillator
      ReplacementTrim   core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; both split branches stay stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [split-branch topology, intentionally empty dry branch processing]

## Public Parameters

- None

## Defaults To Omit

- `BranchReset.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `LayerSplit`: the lesson is branch initialisation, not end-of-chain muting.
- Before `BranchReset`: clear the inherited split signal before the oscillator adds a replacement layer.

## Cosmetic Plan

- Main node: `BranchReset`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`LayerSplit`, `ReplacementOsc`, `ReplacementTrim`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`DryBranch`]
- Nodes that must stay visible: [`LayerSplit`, `ReplacementBranch`, `BranchReset`, `ReplacementOsc`]

## Open Questions

- None
