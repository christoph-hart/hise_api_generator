# control.clone_forward - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/clone_forward.md`
- Reference: `scriptnode_enrichment/output/control/clone_forward.md`

## Naming

- Module ID: `SharedCloneResonance`
- Network ID: `shared_clone_resonance`

## Graph Plan

```text
shared_clone_resonance
  CutoffDistribution     control.clone_cable
  SharedResonance        control.clone_forward
  FilterBank             container.clone
    FilterVoice          container.chain
      BandpassFilter     filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Build one filter chain and duplicate it to eight configured clones.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [parallel filtered copies sum without retaining a separate dry path]

## Public Parameters

- NumFilters -> `FilterBank.NumClones`, `CutoffDistribution.NumClones`, and `SharedResonance.NumClones` matched
- Target range before connection: `[1, 8]`, step `1`
- Macro range: `[1, 8]`, step `1`
- Default: `4`
- Resonance -> `SharedResonance.Value` matched
- Target range before connection: `[0.3, 9.9]`
- Macro range: `[0.3, 9.9]`
- Default: `1.0`

## Defaults To Omit

- `FilterBank.NumClones` default `1`
- `SharedResonance.Value` default `0.0`

## Locked Build Values

- NumFilters must be the first root macro.
- Configured clone count = `8`
- `FilterBank.SplitSignal` = `Copy`
- `CutoffDistribution.Mode` = `Spread`
- `CutoffDistribution.Value` = `1.0`
- `CutoffDistribution` target = `BandpassFilter.Frequency`, range `[300, 6000]`
- `SharedResonance` connects to the first clone's `BandpassFilter.Q` and propagates to siblings.
- `BandpassFilter.Mode` = `BandPass`
- `BandpassFilter.Q` range = `[0.3, 9.9]`

## Friction Comments To Weave In

- Before `SharedResonance`: clone_forward writes one raw value identically to every clone and bypasses target range conversion.
- Before connection: connect one clone-forward instance to the first clone target only; clone propagation handles siblings.
- Before `CutoffDistribution`: frequency remains clone-specific while Q is shared.

## Cosmetic Plan

- Main node: `SharedResonance`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`CutoffDistribution`, `FilterBank`, `BandpassFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`FilterVoice`]
- Nodes that must stay visible: [`SharedResonance`, `CutoffDistribution`, `FilterBank`, `BandpassFilter`]

## Open Questions

- None
