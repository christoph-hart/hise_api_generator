# container.no_midi - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/no_midi.md`
- Reference: `scriptnode_enrichment/output/container/no_midi.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `MidiIsolatedTremoloLfo`
- Network ID: `midi_isolated_tremolo_lfo`

## Builder Setup Applied

- Host context: `Script Synth`

## Final Topology

```text
midi_isolated_tremolo_lfo
  TremoloControl
    MidiIsolation
      TremoloOscillator
      Normalise
      TremoloDepth
      TremoloPeak
  SawTone
  NoteEnvelope
  VoiceLifecycle
```

## Verified Parameters And Connections

- Root `Rate`: `0.5..8 Hz`, default `4`
- Root `Depth`: `0..1`, default `0.6`
- `TremoloOscillator.Frequency`: `0.5..8 Hz`, default `4`
- `TremoloDepth.Value`: `0..1`, default `0.6`
- `SawTone.Mode` = `Saw`
- `SawTone.Gain`: continuous range `0.35..1.0`
- `NoteEnvelope.Attack` = `10 ms`
- `NoteEnvelope.Release` = `200 ms`
- Root `Rate` -> `TremoloOscillator.Frequency`, matched
- Root `Depth` -> `TremoloDepth.Value`, matched
- `TremoloPeak.0` -> `SawTone.Gain`, scaled
- `NoteEnvelope.1` -> `VoiceLifecycle.Kill Voice`

## Trace Validation

- Notes 60 and 72 were triggered independently at a nonzero 1 ms offset.
- Root synth: polyphonic, stereo, MIDI enabled.
- `TremoloControl`: polyphonic, mono control buffer, MIDI enabled.
- `MidiIsolation`: polyphonic, mono control buffer, `processMidi=false`.
- `TremoloOscillator.Frequency` remained exactly `4 Hz` for both notes.
- Both notes produced identical LFO values from the same reset phase.
- The audible saw and envelope produced nonzero stereo output.
- The tremolo edge changed `SawTone.Gain` inside `0.35..1.0`.

Validation commands:

```bash
hise-cli dsp trace --module MidiIsolatedTremoloLfo --container midi_isolated_tremolo_lfo --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-param TremoloOscillator.Frequency --trace-compact --agent
hise-cli dsp trace --module MidiIsolatedTremoloLfo --container midi_isolated_tremolo_lfo --trigger-note 72 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-param TremoloOscillator.Frequency --trace-compact --agent
hise-cli dsp trace --module MidiIsolatedTremoloLfo --container midi_isolated_tremolo_lfo --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
```

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptSynth --id MidiIsolatedTremoloLfo --agent
hise-cli builder set --module MidiIsolatedTremoloLfo --network midi_isolated_tremolo_lfo --agent

# modchain keeps the generated LFO signal out of the audible path.
hise-cli dsp add --module MidiIsolatedTremoloLfo --type container.modchain --id TremoloControl --agent
# no_midi blocks every event type only within this LFO subtree.
hise-cli dsp add --module MidiIsolatedTremoloLfo --type container.no_midi --id MidiIsolation --parent TremoloControl --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type core.oscillator --id TremoloOscillator --parent MidiIsolation --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type math.sig2mod --id Normalise --parent MidiIsolation --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type math.mul --id TremoloDepth --parent MidiIsolation --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type core.peak --id TremoloPeak --parent MidiIsolation --agent

# These nodes remain outside no_midi and continue responding to notes.
hise-cli dsp add --module MidiIsolatedTremoloLfo --type core.oscillator --id SawTone --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type envelope.simple_ar --id NoteEnvelope --agent
hise-cli dsp add --module MidiIsolatedTremoloLfo --type envelope.voice_manager --id VoiceLifecycle --agent

hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloOscillator --param Frequency --range "0.5,8" --stepSize 0 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloOscillator --param Frequency --value 4 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloDepth --param Value --range "0,1" --stepSize 0 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloDepth --param Value --value 0.6 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node SawTone --param Mode --value 2 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node SawTone --param Gain --range "0.35,1" --stepSize 0 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node NoteEnvelope --param Attack --value 10 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node NoteEnvelope --param Release --value 200 --agent

hise-cli dsp create_parameter --module MidiIsolatedTremoloLfo --container midi_isolated_tremolo_lfo --id Rate --range "0.5,8" --default 4 --agent
hise-cli dsp create_parameter --module MidiIsolatedTremoloLfo --container midi_isolated_tremolo_lfo --id Depth --range "0,1" --default 0.6 --agent
hise-cli dsp connect --module MidiIsolatedTremoloLfo --source midi_isolated_tremolo_lfo --source-param Rate --target TremoloOscillator --param Frequency --matched --agent
hise-cli dsp connect --module MidiIsolatedTremoloLfo --source midi_isolated_tremolo_lfo --source-param Depth --target TremoloDepth --param Value --matched --agent
hise-cli dsp connect --module MidiIsolatedTremoloLfo --source TremoloPeak --target SawTone --param Gain --agent
hise-cli dsp connect --module MidiIsolatedTremoloLfo --source NoteEnvelope --source-output 1 --target VoiceLifecycle --param 'Kill Voice' --agent

hise-cli dsp set --module MidiIsolatedTremoloLfo --node MidiIsolation --param NodeColour --value 0xFF27AE60 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node MidiIsolation --param Comment --value '"Blocks every MIDI event type for this subtree, so each voice keeps a fixed 4 Hz LFO instead of tracking note pitch."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloControl --param Comment --value '"The mono modulation chain prevents the generated LFO signal from leaking into the audible stereo path."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloOscillator --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloOscillator --param Comment --value '"One independent fixed-rate sine LFO is created for every active polyphonic voice."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloDepth --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloDepth --param Comment --value '"Depth scales the normalized LFO before its peak value is exported to SawTone Gain."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node TremoloPeak --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node SawTone --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node SawTone --param Comment --value '"This oscillator stays outside no_midi, so incoming notes continue to set the audible pitch."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node NoteEnvelope --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node NoteEnvelope --param Comment --value '"The envelope remains MIDI-enabled and articulates each synth voice independently."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node VoiceLifecycle --param Comment --value '"Ends each polyphonic voice after the envelope release reaches silence."' --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node Normalise --param Folded --value true --agent
hise-cli dsp set --module MidiIsolatedTremoloLfo --node VoiceLifecycle --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module MidiIsolatedTremoloLfo --agent
hise-cli dsp screenshot --module MidiIsolatedTremoloLfo --scale 200% --output "scriptnode_enrichment/hsc/output/container/no_midi.png" --agent
```

## Open Issues

- None.
