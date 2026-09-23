# analyse.oscilloscope - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/analyse/oscilloscope.md`
- Reference: `scriptnode_enrichment/output/analyse/oscilloscope.md`

## Naming

- Module ID: `MidiCycleScope`
- Network ID: `midi_cycle_scope`

## Graph Plan

```text
midi_cycle_scope
  MidiScopeContext      container.midichain
    InputClear            math.clear
    ScopeOscillator       core.oscillator
    ScopeLevel            core.gain
    WaveformScope         analyse.oscilloscope
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Create a Script FX and initialise `midi_cycle_scope`.
  - Keep both `ScopeOscillator` and `WaveformScope` below `MidiScopeContext`; the oscillator must receive the same note-on that triggers the oscilloscope's one-cycle buffer resize.
  - Register the oscilloscope display buffer as an external `DisplayBufferSource` only if the waveform will also be rendered on the scripted interface.
- Channel/routing setup:
  - Required channels: default stereo; `ScopeOscillator` writes the same waveform to both channels and the oscilloscope starts with one displayed channel
  - Module routing: default stereo
  - Master routing: default
  - Channel-specific comments needed: [MIDI note-on processing, not channel routing, is responsible for the dynamic display length]

## Public Parameters

- Waveform -> `ScopeOscillator.Mode` matched
- Target range before connection: `[Sine, Saw, Triangle, Square]`
- Macro range: `[0, 3]`
- Default: `Sine`
- Level -> `ScopeOscillator.Gain` matched
- Target range before connection: `[0.0, 0.25]`
- Macro range: `[0.0, 0.25]`
- Default: `0.15`

## Defaults To Omit

- `ScopeOscillator.Frequency` default `220`; incoming note-on events retune it.
- `ScopeOscillator.Gate` default `On`
- `ScopeOscillator.Phase` default `0`
- `WaveformScope.BufferLength` starts at its default and is resized by MIDI note-on.

## Locked Build Values

- `WaveformScope.NumChannels` = `1`
- `ScopeLevel.Gain` = `0 dB`

## Friction Comments To Weave In

- Before `MidiScopeContext`: a Script FX does not provide MIDI processing to ordinary children, so the oscilloscope cannot synchronise unless it is inside `container.midichain`.
- Before `InputClear`: `core.oscillator` adds to its input. Clear the host audio so the display contains only the generated waveform.
- Before `ScopeOscillator`: do not isolate this oscillator with `container.no_midi`; MIDI retuning is required for the displayed cycle to match the played note.
- Before `WaveformScope`: each note-on computes `sampleRate / noteFrequency` internally and resizes the ring buffer to one cycle. A manual BufferLength macro would be overwritten by the next note.
- Before final verification: play low and high notes and confirm that the displayed period remains one complete cycle while the underlying sample count changes.

## Cosmetic Plan

- Main node: `WaveformScope`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`MidiScopeContext`, `ScopeOscillator`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`InputClear`, `ScopeLevel`]
- Nodes that must stay visible: [`MidiScopeContext`, `ScopeOscillator`, `WaveformScope`]

## Open Questions

- None. Automatic MIDI cycle synchronisation is the selected teaching focus.
