# control.input_toggle - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/input_toggle.md`
- Reference: `scriptnode_enrichment/output/control/input_toggle.md`

## Naming

- Module ID: `KeyTrackOrManualCutoff`
- Network ID: `key_track_or_manual_cutoff`

## Graph Plan

```text
key_track_or_manual_cutoff
  MidiContext            container.midichain
    NoteFrequency        control.midi
    CutoffSource         control.input_toggle
    SelectedFilter       filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Use midichain so the MIDI source receives events in the effect context.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI explicitly enabled in Script FX]

## Public Parameters

- KeyTrack -> `CutoffSource.Input` matched
- Target range before connection: `[0, 1]`, step `1`
- Macro range: `[0, 1]`, step `1`, labels `MIDI, Manual`
- Default: `0`
- ManualCutoff -> `CutoffSource.Value2` through normalisation
- Target range before connection: `[0, 1]`
- Macro range: `[200, 8000]`, skewed
- Default: `1000`

## Defaults To Omit

- `CutoffSource.Input` default `0`
- `CutoffSource.Value1` default `0.0`
- `CutoffSource.Value2` default `0.0`

## Locked Build Values

- `NoteFrequency.Mode` = `Frequency`
- `NoteFrequency` output -> `CutoffSource.Value1` matched over `[0, 1]`
- `CutoffSource` output -> `SelectedFilter.Frequency` range = linear `[0, 20000]`
- `SelectedFilter.Mode` = `LowPass`
- `SelectedFilter.Q` = `0.7`
- `SelectedFilter.Smoothing` = `0.02`

## Friction Comments To Weave In

- Before `MidiContext`: the effect host needs explicit MIDI event processing.
- Before `CutoffSource`: inactive input changes are stored but not forwarded until that input is selected.
- Before filter range: MIDI Frequency mode requires the internal linear 0..20 kHz domain even though ManualCutoff is narrowed for users.

## Cosmetic Plan

- Main node: `CutoffSource`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`NoteFrequency`, `SelectedFilter`, `MidiContext`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`MidiContext`, `NoteFrequency`, `CutoffSource`, `SelectedFilter`]

## Open Questions

- None
