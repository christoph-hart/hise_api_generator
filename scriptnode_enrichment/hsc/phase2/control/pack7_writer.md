# control.pack7_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack7_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack7_writer.md`

## Naming

- Module ID: `SevenDegreePitchPattern`
- Network ID: `seven_degree_pitch_pattern`

## Graph Plan

```text
seven_degree_pitch_pattern
  MidiContext            container.midichain
    DegreeWriter         control.pack7_writer
    PatternClock         core.clock_ramp
    DegreeReader         control.cable_pack
    PatternOscillator    core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Initialize shared external SliderPack slot 0 before applying writer values and send a MIDI note.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [midichain lets MIDI establish oscillator base pitch]

## Public Parameters

- Degree1..Degree7 -> `DegreeWriter.Value1..Value7`, macro range `[1, 2]` mapped to writer `[0, 1]`
- Defaults: `1.0, 1.122462, 1.259921, 1.334840, 1.498307, 1.681793, 1.887749`

## Defaults To Omit

- `DegreeWriter.Value1..Value7` defaults `0.0`

## Locked Build Values

- `DegreeWriter.SliderPack` and `DegreeReader.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("SevenDegreePitchPattern").getSliderPack(0)`
- Writer resizes pack to `7`; Value1..Value7 map to indices `0..6`.
- `PatternClock.Mode = Synced`, Multiplier = `1 Bar`, AddToSignal = `Off`, Inactive = `0`
- `DegreeReader` output -> `PatternOscillator.Freq Ratio` range `[1, 2]`
- `PatternOscillator.Mode = Saw`, Gain = `0.2`, Gate = `On`

## Friction Comments To Weave In

- Before data setup: use external slot 0 for script-initialized scale ratios.
- Before ratio target: widen Freq Ratio to a continuous fractional octave range.
- Before clock: nearest-neighbour seven-zone lookup prevents glides and intentionally creates a polymetric cycle.

## Cosmetic Plan

- Main node: `DegreeWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`PatternClock`, `DegreeReader`, `PatternOscillator`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`MidiContext`]
- Nodes that must stay visible: [`DegreeWriter`, `DegreeReader`, `PatternOscillator`]

## Open Questions

- None
