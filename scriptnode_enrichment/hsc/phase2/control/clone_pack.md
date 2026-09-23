# control.clone_pack - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/clone_pack.md`
- Reference: `scriptnode_enrichment/output/control/clone_pack.md`

## Naming

- Module ID: `DrawbarHarmonicClones`
- Network ID: `drawbar_harmonic_clones`

## Graph Plan

```text
drawbar_harmonic_clones
  MidiContext            container.midichain
    HarmonicFrequencies  control.clone_cable
    DrawbarLevels        control.clone_pack
    HarmonicBank         container.clone
      PartialVoice       container.chain
        SinePartial      core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Build one oscillator chain and duplicate it to exactly eight clones.
  - Initialize external SliderPack slot 0 from Interface `onInit`.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI context supplies note frequency to harmonic distribution]

## Public Parameters

- MasterLevel -> `DrawbarLevels.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.7`
- The external eight-slider pack is also a public drawbar editor.

## Defaults To Omit

- `DrawbarLevels.Value` default `1.0`

## Locked Build Values

- Clone count and both `NumClones` parameters = `8`
- `HarmonicBank.SplitSignal` = `Parallel`
- `HarmonicFrequencies.Mode` = `Harmonics`
- `SinePartial.Frequency` range = linear `[0, 20000]`
- `SinePartial.Mode` = `Sine`
- `SinePartial.Gate` = `On`
- `DrawbarLevels.SliderPack` external data index = `0`
- Interface `onInit`: `const var drawbarProcessor = Synth.getSliderPackProcessor("DrawbarHarmonicClones");`
- Interface `onInit`: `const var drawbarData = drawbarProcessor.getSliderPack(0);`
- SliderPack size = `8`; startup values = `[1.0, 0.7, 0.5, 0.35, 0.25, 0.18, 0.12, 0.08]`

## Friction Comments To Weave In

- Before complex-data setup: external slot 0 permits deterministic scripted drawbar values.
- Before `DrawbarLevels`: slider index maps directly to clone index and MasterLevel multiplies every current entry.
- Before topology: fixed clone and pack sizes avoid an unnecessary pack_resizer.

## Cosmetic Plan

- Main node: `DrawbarLevels`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`HarmonicFrequencies`, `HarmonicBank`, `SinePartial`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`MidiContext`, `PartialVoice`]
- Nodes that must stay visible: [`DrawbarLevels`, `HarmonicFrequencies`, `HarmonicBank`, `SinePartial`]

## Open Questions

- None
