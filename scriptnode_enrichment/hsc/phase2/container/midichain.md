# container.midichain - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/midichain.md`
- Reference: `scriptnode_enrichment/output/container/midichain.md`

## Naming

- Module ID: `MidiPlayedFxSynth`
- Network ID: `midi_played_fx_synth`

## Graph Plan

```text
midi_played_fx_synth
  MidiEnabledSynth       container.midichain
    SawTone              core.oscillator
    NoteEnvelope         envelope.simple_ar
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Send note-on and note-off events at non-zero offsets within a host block for timing verification.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI explicitly enabled in effect context]

## Public Parameters

- Attack -> `NoteEnvelope.Attack` matched
- Target range before connection: `[1, 250]`
- Macro range: `[1, 250]`
- Default: `20`
- Release -> `NoteEnvelope.Release` matched
- Target range before connection: `[20, 1000]`
- Macro range: `[20, 1000]`
- Default: `250`

## Defaults To Omit

- `SawTone.Frequency` default `220`
- `SawTone.Gain` default `1.0`

## Locked Build Values

- `SawTone.Mode` = `Saw`
- `SawTone.Gate` = `On`
- `NoteEnvelope.AttackCurve` = `0.5`
- Child order = `SawTone`, `NoteEnvelope`
- Verification events must include non-zero in-block timestamps.

## Friction Comments To Weave In

- Before `MidiEnabledSynth`: Script FX children do not normally receive MIDI, so this wrapper enables event delivery and timestamp splitting.
- Before `SawTone.Gate`: MIDI retunes the oscillator but does not toggle its Gate; the envelope supplies articulation.
- Before topology: if frame processing is added later, the frame container must be inside the midichain, never outside it.

## Cosmetic Plan

- Main node: `MidiEnabledSynth`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`SawTone`, `NoteEnvelope`]
- Supporting colour: `0xFF668A73`
- Folded nodes: []
- Nodes that must stay visible: [`MidiEnabledSynth`, `SawTone`, `NoteEnvelope`]

## Open Questions

- None
