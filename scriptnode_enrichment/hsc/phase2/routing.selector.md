# routing.selector - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/routing.selector.md`
- Reference: `scriptnode_enrichment/output/routing/selector.md`

## Naming

- Module ID: `CabMicSelector`
- Network ID: `cab_mic_selector`

## Graph Plan

```text
cab_mic_selector
  MicPairSelector        routing.selector
  PairSplit             container.multi
    SelectedPair        container.chain
      CabToneEQ         filters.svf_eq
      CabGlueComp       jdsp.jcompressor
      CabMakeupGain     core.gain
    UnusedPair          container.chain
```

## Channel Plan

- Required channels: four internal channels, representing two stereo mic pairs
- Module routing: `CabMicSelector.routing [0, 1, 2, 3]`
- Master routing: `"Master Chain".routing [0, 1, 0, 1]`
- Channel-specific comments needed:
  - The ScriptFX receives four internal channels.
  - The Master Chain folds four internal channels back to HISE's stereo output.
  - `container.multi` is required so downstream FX only process the selected pair on channels 0-1.

## Public Parameters

- `MicPosition` -> `MicPairSelector.ChannelIndex` matched
- Target range before connection: `[0, 2]`
- Macro range: `[0, 2]`
- Default: `2`

## Defaults To Omit

- `MicPairSelector.SelectOutput` default `0`
- `MicPairSelector.ClearOtherChannels` default `1`

## Friction Comments To Weave In

- Before Master/ScriptFX routing: four internal source channels are folded back to stereo output.
- Before `PairSplit`: split the post-selector buffer into stereo slices so only channels 0-1 hit the FX chain.
- Before `create_parameter`: root macro values use raw channel offsets: `0` selects channels 0-1, `2` selects channels 2-3.

## Cosmetic Plan

- Main node: `MicPairSelector`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`CabToneEQ`, `CabGlueComp`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`UnusedPair`, `CabToneEQ`, `CabGlueComp`, `CabMakeupGain`]
- Nodes that must stay visible: [`MicPairSelector`, `PairSplit`, `SelectedPair`]

## Open Questions

- None
