# container.clone - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/clone.md`
- Reference: `scriptnode_enrichment/output/container/clone.md`

## Naming

- Module ID: `DynamicSawUnison`
- Network ID: `dynamic_saw_unison`

## Graph Plan

```text
dynamic_saw_unison
  CloneControls          container.offline
    PitchSpread          control.clone_cable
    PanSpread            control.clone_cable
    GainCompensation     control.clone_cable
  UnisonLayers           container.clone
    UnisonVoice          container.chain
      SawLayer           core.oscillator
      LayerPan           jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Build the generated first clone chain completely and rename it to `UnisonVoice`.
  - Set `UnisonLayers.NumClones` range to `[1, 8]`, then set its value to `8`. This special CLI value mutation silently rebuilds the clone container to eight physical child chains; no separate duplication command is required.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [parallel clones generate from silence and sum into stereo]

## Public Parameters

- NumClones -> `UnisonLayers.NumClones` matched and every clone cable `NumClones` matched
- Target range before connection: `[1, 8]`, step `1`
- Macro range: `[1, 8]`, step `1`
- Default: `4`
- Spread -> `PitchSpread.Value` and `PanSpread.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.5`

## Defaults To Omit

- `PitchSpread.Mode` default `Spread`
- `PanSpread.Mode` default `Spread`
- `SawLayer.Frequency` default `220`
- `SawLayer.Gate` default `On`
- `UnisonLayers.SplitSignal` default `Copy`

## Locked Build Values

- `NumClones` must be the first root parameter.
- `UnisonLayers.NumClones` range = `[1, 8]`
- `UnisonLayers.NumClones` = `8` to create eight physical child chains
- Configured clone count = `8`
- `UnisonLayers.SplitSignal` = `Parallel`
- `PitchSpread.Mode` = `Spread`
- `CloneControls.IsVertical` = `false`
- `PitchSpread` target = `SawLayer.Freq Ratio`, range `[0.5, 2]`, middle position `1`
- `PanSpread.Mode` = `Spread`
- `PanSpread` target = `LayerPan.Pan`, range `[-1, 1]`
- `GainCompensation.Mode` = `Ducker`
- `GainCompensation` target = `SawLayer.Gain`, range `[0, 1]`
- `SawLayer.Mode` = `Saw`
- `SawLayer.Frequency` startup value = `220`
- `SawLayer.Gate` = `On`
- `LayerPan.Rule` = `Sine3dB` (constant power)

## Friction Comments To Weave In

- Before setting `UnisonLayers.NumClones` to `8`: this special CLI value mutation silently rebuilds the clone container to eight physical child chains, so apply it only after the first clone chain is complete.
- Before public parameters: NumClones must be the first macro and use the same range on the container and all clone cables.
- Before `UnisonLayers`: Parallel mode gives each clone silence so oscillator layers are added without multiplying input audio.
- Before `CloneControls`: the offline container keeps the three control-only nodes in a horizontal strip without processing the audio buffer.
- Before clone cables: ordinary clone parameters are synchronised; clone-aware cables provide per-layer frequency ratio, pan, and gain values.

## Cosmetic Plan

- Main node: `UnisonLayers`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`CloneControls`, `PitchSpread`, `PanSpread`, `GainCompensation`]
- Supporting colour: `0xFF7F6A91`
- Clone-child nodes: [`SawLayer`, `LayerPan`]
- Clone-child colour: `0xFF5F7894`
- Folded nodes: []
- ShowParameters containers: [`UnisonLayers`]
- Nodes that must stay visible: [`CloneControls`, `PitchSpread`, `PanSpread`, `GainCompensation`, `UnisonLayers`, `UnisonVoice`, `SawLayer`, `LayerPan`]

## Open Questions

- None
