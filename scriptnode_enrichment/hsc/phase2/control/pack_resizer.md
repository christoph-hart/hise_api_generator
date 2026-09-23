# control.pack_resizer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack_resizer.md`
- Reference: `scriptnode_enrichment/output/control/pack_resizer.md`

## Naming

- Module ID: `CloneMatchedDrawbarPack`
- Network ID: `clone_matched_drawbar_pack`

## Graph Plan

```text
clone_matched_drawbar_pack
  PackSize               control.pack_resizer
  DrawbarLevels          control.clone_pack
  PartialBank            container.clone
    PartialVoice         container.chain
      PartialOscillator  core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Build one oscillator chain and duplicate it to sixteen configured clones.
  - Initialize shared external SliderPack slot 0, then explicitly set PackSize after data assignment.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- PartialCount -> `PartialBank.NumClones`, `DrawbarLevels.NumClones`, and `PackSize.NumSliders` matched
- Target range before connection: `[1, 16]`, step `1`
- Macro range: `[1, 16]`, step `1`
- Default: `8`
- The resized SliderPack is the public drawbar editor.

## Defaults To Omit

- `PackSize.NumSliders` default `0`
- `DrawbarLevels.Value` default `1.0`

## Locked Build Values

- PartialCount must be the first root macro.
- Configured clone count = `16`; `PartialBank.SplitSignal = Parallel`
- `PackSize.SliderPack` and `DrawbarLevels.SliderPack` external data index = `0`
- Interface `onInit`: `const var packProcessor = Synth.getSliderPackProcessor("CloneMatchedDrawbarPack");`
- Interface `onInit`: `const var packData = packProcessor.getSliderPack(0);`
- Initial pack size = `8`; retained startup values = `[1.0, 0.7, 0.5, 0.35, 0.25, 0.18, 0.12, 0.08]`
- Explicit initial `PackSize.NumSliders` update = `8`
- `PartialOscillator.Mode = Sine`, Gate = `On`, Gain target from clone pack `[0, 0.12]`

## Friction Comments To Weave In

- Before complex data: resizer and clone pack must share external slot 0.
- Before initial size: connecting the resizer does not resize; force one explicit NumSliders update after assignment.
- Before PartialCount: resizing allocates memory and must remain a UI or low-rate operation.
- Before verification: growth preserves entries and adds defaults, while shrink removes trailing entries.

## Cosmetic Plan

- Main node: `PackSize`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`DrawbarLevels`, `PartialBank`, `PartialOscillator`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`PartialVoice`]
- Nodes that must stay visible: [`PackSize`, `DrawbarLevels`, `PartialBank`]

## Open Questions

- None
