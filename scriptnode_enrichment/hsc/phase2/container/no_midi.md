# container.no_midi - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/no_midi.md`
- Reference: `scriptnode_enrichment/output/container/no_midi.md`

## Naming

- Module ID: `MidiIsolatedTremoloLfo`
- Network ID: `midi_isolated_tremolo_lfo`

## Graph Plan

```text
midi_isolated_tremolo_lfo [polyphonic]
  TremoloControl         container.modchain
    MidiIsolation       container.no_midi
      TremoloOscillator core.oscillator
      Normalise         math.sig2mod
      TremoloDepth      math.mul
      TremoloPeak       core.peak
  SawTone                core.oscillator
  NoteEnvelope           envelope.simple_ar
  VoiceLifecycle         envelope.voice_manager
```

## Builder Setup

- Host context: `Script Synth`
- Additional builder steps:
  - Create a Scriptnode Synthesiser module (`ScriptSynth` internally); its host context creates the network as polyphonic and delivers MIDI to each voice.
  - Play overlapping notes at widely separated pitches to verify independent per-voice LFOs.
- Channel/routing setup:
  - Required channels: default stereo in a polyphonic voice context; each voice's LFO runs in an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [polyphonic synthesiser host required, all MIDI blocked only inside each voice's LFO subtree]

## Public Parameters

- Rate -> `TremoloOscillator.Frequency` matched
- Target range before connection: `[0.5, 8]`
- Macro range: `[0.5, 8]`
- Default: `4`
- Depth -> `TremoloDepth.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.6`

## Defaults To Omit

- `Normalise.Value` default `0.0`
- `TremoloDepth.Value` default `1.0`
- `VoiceLifecycle.Kill Voice` default `1.0`
- `SawTone.Gain` default `1.0`

## Locked Build Values

- Network polyphony = inherited from the `Scriptnode Synthesiser` host
- `TremoloOscillator.Mode` = `Sine`
- `TremoloOscillator.Frequency` range = `[0.5, 8]`
- `TremoloOscillator.Gate` = `On`
- `SawTone.Mode` = `Saw`
- `SawTone.Gate` = `On`
- `TremoloDepth.Value` range = `[0, 1]`
- `TremoloPeak` modulation output -> `SawTone.Gain` range = `[0.35, 1.0]`, step size `0`
- `NoteEnvelope.Attack` = `10`
- `NoteEnvelope.Release` = `200`
- `NoteEnvelope` Gate output -> `VoiceLifecycle.Kill Voice`

## Friction Comments To Weave In

- Before builder setup: use a Scriptnode Synthesiser so every active voice owns an independent LFO and audio path.
- Before `MidiIsolation`: all event types are blocked for this subtree so notes cannot retune the fixed-rate LFO.
- Before `SawTone`: the audible oscillator and envelope remain outside no_midi so they continue responding to notes.
- Before `TremoloControl`: the modchain prevents the LFO's generated signal from leaking into audio.

## Cosmetic Plan

- Main node: `MidiIsolation`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`TremoloOscillator`, `TremoloDepth`, `TremoloPeak`, `SawTone`, `NoteEnvelope`, `VoiceLifecycle`]
- Supporting colour: `0xFF668A73`
- Folded nodes: [`Normalise`]
- Nodes that must stay visible: [`TremoloControl`, `MidiIsolation`, `TremoloOscillator`, `TremoloDepth`, `SawTone`, `NoteEnvelope`]

## Open Questions

- None
