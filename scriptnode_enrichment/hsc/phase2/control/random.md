# control.random - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/random.md`
- Reference: `scriptnode_enrichment/output/control/random.md`

## Naming

- Module ID: `MidiTriggeredRandomPan`
- Network ID: `midi_triggered_random_pan`

## Graph Plan

```text
midi_triggered_random_pan [polyphonic]
  VoiceGate              control.midi
  RandomPosition         control.random
  VoicePanner            jdsp.jpanner
```

## Builder Setup

- Host context: `Polyphonic Script FX`
- Additional builder steps:
  - Create a Polyphonic Script FX module in a synthesiser voice effect chain; its host context creates the network as polyphonic.
  - Play overlapping notes and include note-off transitions during verification.
- Channel/routing setup:
  - Required channels: default stereo in a polyphonic context
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [polyphonic host required for independent voice target state]

## Public Parameters

- None

## Defaults To Omit

- `RandomPosition.Value` default `0.0`

## Locked Build Values

- Network polyphony = inherited from the `Polyphonic Script FX` host
- `VoiceGate.Mode` property = `Gate`
- `VoiceGate` output -> `RandomPosition.Value` matched over `[0, 1]`
- `RandomPosition` output -> `VoicePanner.Pan` range = `[-1, 1]`
- `VoicePanner.Rule` = `ConstantPower`
- Both gate transitions `0 -> 1` and `1 -> 0` trigger a new random value.

## Friction Comments To Weave In

- Before builder setup: use Polyphonic Script FX so MIDI-derived updates are applied in the current voice context.
- Before `RandomPosition`: Value magnitude is ignored; each actual gate change triggers a new uniform random value.
- Before verification: Gate mode also changes on note-off, so this topology randomises on both edges rather than note-on only.
- Before expectations: repeated identical values do not retrigger, and random sequences are not deterministic.

## Cosmetic Plan

- Main node: `RandomPosition`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`VoiceGate`, `VoicePanner`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`VoiceGate`, `RandomPosition`, `VoicePanner`]

## Open Questions

- None
