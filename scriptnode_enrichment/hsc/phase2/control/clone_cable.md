# control.clone_cable - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/clone_cable.md`
- Reference: `scriptnode_enrichment/output/control/clone_cable.md`

## Naming

- Module ID: `MidiHarmonicOscillatorBank`
- Network ID: `midi_harmonic_oscillator_bank`

## Graph Plan

```text
midi_harmonic_oscillator_bank
  MidiContext            container.midichain
    HarmonicFrequencies  control.clone_cable
    HarmonicBank         container.clone
      PartialVoice       container.chain
        SinePartial      core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Build one oscillator chain, duplicate to sixteen configured clones, and send MIDI notes for verification.
  - Keep `HarmonicBank.ShowClones` disabled so the editor displays one representative clone.
  - Leave the representative `PartialVoice` child unfolded for inspection.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [midichain enables MIDI-reactive harmonic distribution in Script FX]

## Public Parameters

- NumHarmonics -> `HarmonicBank.NumClones` and `HarmonicFrequencies.NumClones` matched
- Target range before connection: `[1, 16]`, step `1`
- Macro range: `[1, 16]`, step `1`
- Default: `8`

## Defaults To Omit

- `HarmonicBank.NumClones` default `1`
- `HarmonicFrequencies.NumClones` default `1`

## Locked Build Values

- NumHarmonics must be the first root macro.
- Configured clone count = `16`
- `HarmonicBank.SplitSignal` = `Parallel`
- `HarmonicFrequencies.Mode` = `Harmonics`
- `SinePartial.Mode` = `Sine`
- `SinePartial.Frequency` range = linear `[0, 20000]`
- `SinePartial.Gain` = `0.05`
- `SinePartial.Gate` = `On`
- Gamma is ignored and remains unexposed.

## Friction Comments To Weave In

- Before `MidiContext`: Harmonics mode derives its base frequency from incoming note-on events.
- Before NumHarmonics: clone count is the first macro and must use identical ranges on container and clone cable.
- Before frequency target: MIDI-reactive output requires an unskewed linear 0..20 kHz target range.

## Cosmetic Plan

- Main node: `HarmonicFrequencies`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`HarmonicBank`, `SinePartial`, `MidiContext`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`MidiContext`, `HarmonicFrequencies`, `HarmonicBank`, `PartialVoice`, `SinePartial`]
- `HarmonicBank.ShowClones` = `false`

## Open Questions

- None
