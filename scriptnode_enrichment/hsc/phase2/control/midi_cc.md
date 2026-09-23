# control.midi_cc - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/midi_cc.md`
- Reference: `scriptnode_enrichment/output/control/midi_cc.md`

## Naming

- Module ID: `ModWheelStereoPosition`
- Network ID: `mod_wheel_stereo_position`

## Graph Plan

```text
mod_wheel_stereo_position
  MidiContext            container.midichain
    ModWheel             control.midi_cc
    StereoPosition       jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Send CC1 values 0, 64, and 127 plus an unrelated CC for verification.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [midichain enables CC delivery in Script FX]

## Public Parameters

- None

## Defaults To Omit

- `ModWheel.CCNumber` default `1`
- `ModWheel.EnableMPE` default `Off`

## Locked Build Values

- `ModWheel.CCNumber` = `1`
- `ModWheel.EnableMPE` = `Off`
- `ModWheel.DefaultValue` = `0.5`
- `ModWheel` output -> `StereoPosition.Pan` range = `[-1, 1]`
- `StereoPosition.Rule` = `ConstantPower`

## Friction Comments To Weave In

- Before `MidiContext`: the control node must receive events through the processing path.
- Before DefaultValue: setting 0.5 immediately publishes a centred fallback before the first CC arrives.
- Before CCNumber: values 128-131 are special event selectors, so this example stays on ordinary CC1.

## Cosmetic Plan

- Main node: `ModWheel`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`MidiContext`, `StereoPosition`]
- Supporting colour: `0xFF668A73`
- Folded nodes: []
- Nodes that must stay visible: [`MidiContext`, `ModWheel`, `StereoPosition`]

## Open Questions

- None
