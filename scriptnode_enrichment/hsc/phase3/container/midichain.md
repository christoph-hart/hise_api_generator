# container.midichain - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/midichain.md`
- Reference: `scriptnode_enrichment/output/container/midichain.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a MIDI-played oscillator inside a Script FX.

## Naming

- Module ID: `MidiPlayedFxSynth`
- Network ID: `midi_played_fx_synth`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
midi_played_fx_synth
  MidiEnabledSynth
    SawTone
    NoteEnvelope
```

## Verified Parameters

- `SawTone.Mode` = `2` (`Saw`)
- `SawTone.Gate` = `On`
- `NoteEnvelope.Attack` = `20` ms, range `1..250`
- `NoteEnvelope.Release` = `250` ms, range `20..1000`
- `NoteEnvelope.AttackCurve` = `0.5`
- Root `Attack` = `20` ms, range `1..250`
- Root `Release` = `250` ms, range `20..1000`

## Verified Connections

- Root `Attack` -> `NoteEnvelope.Attack`, matched
- Root `Release` -> `NoteEnvelope.Release`, matched

## Trace Validation

- Command:
  ```bash
  hise-cli dsp trace --module MidiPlayedFxSynth --container midi_played_fx_synth --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- Evidence:
  - Root Script FX: `processMidi=false`.
  - `MidiEnabledSynth`: `processMidi=true`.
  - The 1 ms nonzero note offset produced articulated output on both channels.
  - Final stereo peak: `0.4928`.
  - `SawTone` generated signal before the envelope.
  - `NoteEnvelope` produced nonzero shaped output.
  - Runtime status passed with API `0.11.0`.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MidiPlayedFxSynth --agent
hise-cli builder set --module MidiPlayedFxSynth --network midi_played_fx_synth --agent

# Script FX children normally do not receive MIDI. midichain enables event delivery and timestamp splitting locally.
hise-cli dsp add --module MidiPlayedFxSynth --type container.midichain --id MidiEnabledSynth --agent
hise-cli dsp add --module MidiPlayedFxSynth --type core.oscillator --id SawTone --parent MidiEnabledSynth --agent
hise-cli dsp add --module MidiPlayedFxSynth --type envelope.simple_ar --id NoteEnvelope --parent MidiEnabledSynth --agent

hise-cli dsp set --module MidiPlayedFxSynth --node SawTone --param Mode --value 2 --agent
# The oscillator remains gated on. MIDI retunes it while the envelope supplies articulation.
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param Attack --range "1,250" --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param Attack --value 20 --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param Release --range "20,1000" --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param Release --value 250 --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param AttackCurve --value 0.5 --agent

hise-cli dsp create_parameter --module MidiPlayedFxSynth --container midi_played_fx_synth --id Attack --range "1,250" --default 20 --agent
hise-cli dsp create_parameter --module MidiPlayedFxSynth --container midi_played_fx_synth --id Release --range "20,1000" --default 250 --agent
hise-cli dsp connect --module MidiPlayedFxSynth --source midi_played_fx_synth --source-param Attack --target NoteEnvelope --param Attack --matched --agent
hise-cli dsp connect --module MidiPlayedFxSynth --source midi_played_fx_synth --source-param Release --target NoteEnvelope --param Release --matched --agent

hise-cli dsp set --module MidiPlayedFxSynth --node MidiEnabledSynth --param NodeColour --value 0xFF27AE60 --agent
hise-cli dsp set --module MidiPlayedFxSynth --node MidiEnabledSynth --param Comment --value '"A Script FX does not normally deliver MIDI to network children. midichain enables event delivery and sample-offset splitting inside this container."' --agent
hise-cli dsp set --module MidiPlayedFxSynth --node SawTone --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiPlayedFxSynth --node SawTone --param Comment --value '"MIDI retunes the oscillator but does not toggle its Gate; NoteEnvelope supplies note articulation."' --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module MidiPlayedFxSynth --node NoteEnvelope --param Comment --value '"The AR envelope responds to note events delivered by the surrounding midichain."' --agent
# Any future frame container must remain inside MidiEnabledSynth to inherit its MIDI-enabled context.
hise-cli dsp set --module MidiPlayedFxSynth --node midi_played_fx_synth --param Comment --value '"If frame processing is added later, put the frame container inside MidiEnabledSynth so it receives the enabled MIDI context."' --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module MidiPlayedFxSynth --agent
hise-cli dsp screenshot --module MidiPlayedFxSynth --scale 200% --output "scriptnode_enrichment/hsc/output/container/midichain.png" --agent
```

## Open Issues

- Issue 17 was fixed and verified after the maintainer rebuild.
