# control.sliderbank - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/sliderbank.md`
- Reference: `scriptnode_enrichment/output/control/sliderbank.md`

## Naming

- Module ID: `WeightedThreeTargetMacro`
- Network ID: `weighted_three_target_macro`

## Graph Plan

```text
weighted_three_target_macro
  CharacterWeights       control.sliderbank
  CharacterFilter        filters.svf
  CharacterSaturation    math.tanh
  CharacterPan           jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Initialize external SliderPack slot 0 with three weights in Interface `onInit`.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Character -> `CharacterWeights.Value` matched; target and macro range `[0, 1]`; default `0.5`

## Defaults To Omit

- `CharacterWeights.Value` default `0.0`

## Locked Build Values

- `CharacterWeights.NumParameters` property = `3`
- `CharacterWeights.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("WeightedThreeTargetMacro").getSliderPack(0)`
- Startup weights = `[1.0, 0.65, 0.4]`
- Output order: 0 -> Filter Frequency `[250, 7000]`; 1 -> tanh Value `[0, 1]`; 2 -> panner Pan `[0, 1]`
- `CharacterFilter.Mode = LowPass`, Q = `0.7`, Smoothing = `0.02`; `CharacterPan.Rule = ConstantPower`

## Friction Comments To Weave In

- Before data setup: external pack data permits deterministic scripted weights and is resized to NumParameters.
- Before outputs: each slot is permanently ordered and uses its own target range.
- Before verification: changing one slider updates only its corresponding destination; output count must remain at or below eight.

## Cosmetic Plan

- Main node: `CharacterWeights`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`CharacterFilter`, `CharacterSaturation`, `CharacterPan`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`CharacterWeights`, `CharacterFilter`, `CharacterSaturation`, `CharacterPan`]

## Open Questions

- None
