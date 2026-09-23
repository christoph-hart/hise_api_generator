# control.midi - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/midi.md`
- Reference: `scriptnode_enrichment/output/control/midi.md`

## Naming

- Module ID: `VelocityFilterBrightness`
- Network ID: `velocity_filter_brightness`

## Graph Plan

```text
velocity_filter_brightness
  MidiContext            container.midichain
    NoteVelocity         control.midi
    VelocityFilter       filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Send at least three note-on velocities for verification.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [midichain delivers events in effect context]

## Public Parameters

- None

## Defaults To Omit

- None

## Locked Build Values

- `NoteVelocity.Mode` property = `Velocity`
- `NoteVelocity` output -> `VelocityFilter.Frequency` range = `[250, 7000]`, skewed
- `VelocityFilter.Mode` = `LowPass`
- `VelocityFilter.Q` = `0.7`
- `VelocityFilter.Smoothing` = `0.02`

## Friction Comments To Weave In

- Before `MidiContext`: control.midi must sit in an event-processing path and Script FX needs midichain.
- Before `NoteVelocity`: note-on velocity is normalized by 127 and only relevant MIDI events update output.
- Before verification: note-off does not emit a new velocity and this output is not a gate or envelope.

## Cosmetic Plan

- Main node: `NoteVelocity`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`MidiContext`, `VelocityFilter`]
- Supporting colour: `0xFF668A73`
- Folded nodes: []
- Nodes that must stay visible: [`MidiContext`, `NoteVelocity`, `VelocityFilter`]

## Open Questions

- None
