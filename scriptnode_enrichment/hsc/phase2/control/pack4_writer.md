# control.pack4_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack4_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack4_writer.md`

## Naming

- Module ID: `FourLayerStereoPlacement`
- Network ID: `four_layer_stereo_placement`

## Graph Plan

```text
four_layer_stereo_placement
  PanWriter              control.pack4_writer
  LayerPans              control.clone_pack
  ToneLayers             container.clone
    ToneVoice            container.chain
      LayerOscillator    core.oscillator
      LayerPanner        jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Duplicate one complete oscillator-panner chain to four clones and initialize external SliderPack slot 0.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Pan1..Pan4 -> `PanWriter.Value1..Value4` with bipolar macro range `[-1, 1]` mapped to target `[0, 1]`
- Defaults: `-0.75, -0.25, 0.25, 0.75`

## Defaults To Omit

- `PanWriter.Value1..Value4` defaults `0.0`

## Locked Build Values

- Clone and clone-pack counts = `4`; clone mode = `Parallel`
- `PanWriter.SliderPack` and `LayerPans.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("FourLayerStereoPlacement").getSliderPack(0)`
- Writer resizes pack to `4`; Value1..Value4 map to indices `0..3`.
- `LayerPans` target = `LayerPanner.Pan`, range `[-1, 1]`
- `LayerPanner.Rule = ConstantPower`; `LayerOscillator.Mode = Saw`, Frequency = `220`, Gain = `0.12`, Gate = `On`

## Friction Comments To Weave In

- Before public mapping: bipolar pan controls are normalized to the writer's 0..1 values.
- Before writer connection: pack indices map directly to matching clone panners.
- Before topology: arbitrary positions require pack data rather than formula-based clone spread.

## Cosmetic Plan

- Main node: `PanWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`LayerPans`, `ToneLayers`, `LayerPanner`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`ToneVoice`]
- Nodes that must stay visible: [`PanWriter`, `LayerPans`, `ToneLayers`, `LayerPanner`]

## Open Questions

- None
