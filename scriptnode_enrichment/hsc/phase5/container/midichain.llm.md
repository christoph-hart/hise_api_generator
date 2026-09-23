---
id: container.midichain.midi-played-synth-inside-script-fx
node: container.midichain
domain: scriptnode
category: dsp-network
title: "MIDI-Played Synth Inside Script FX"
summary: "A serial container that enables sample-accurate MIDI event processing for its children."
useCase: "Demonstrate that `container.midichain` enables MIDI in an effect context and splits audio processing at event timestamps before dispatching events to its serial children."
difficulty: intermediate
networkName: midi_played_fx_synth
moduleType: ScriptFX
moduleId: MidiPlayedFxSynth
tags:
  - container
  - midichain
  - midi
  - event-processing
aliases:
  - midi-played synth inside script fx
  - midichain container
relatedNodes:
  - container.midichain
  - core.oscillator
  - envelope.simple_ar
parameters:
  Attack: "Attack -> NoteEnvelope.Attack matched"
  Target: "Target range before connection: [1, 250]"
  Macro: "Macro range: [1, 250]"
  Default:: "Default: 20"
  Release: "Release -> NoteEnvelope.Release matched"
  Target: "Target range before connection: [20, 1000]"
  Macro: "Macro range: [20, 1000]"
  Default:: "Default: 250"
---

scriptnode example: container.midichain

MIDI-Played Synth Inside Script FX.

Demonstrate that `container.midichain` enables MIDI in an effect context and splits audio processing at event timestamps before dispatching events to its serial children.

Graph:
```text
midi_played_fx_synth
  MidiEnabledSynth       container.midichain
    SawTone              core.oscillator
    NoteEnvelope         envelope.simple_ar
```

Host:
  Module: MidiPlayedFxSynth
  Network: midi_played_fx_synth
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "MidiPlayedFxSynth"`, then set its network to `midi_played_fx_synth`.

Support nodes:
  Required: core.oscillator, envelope.simple_ar
  `core.oscillator` responds to incoming note-on events by setting pitch and generates the saw signal; `envelope.simple_ar` responds to note-on and note-off, multiplies that signal by an attack-release contour, and makes event-aligned articulation audible.

Key rules:

Public controls:
  - Attack -> NoteEnvelope.Attack matched
  - Target range before connection: [1, 250]
  - Macro range: [1, 250]
  - Default: 20
  - Release -> NoteEnvelope.Release matched
  - Target range before connection: [20, 1000]
  - Macro range: [20, 1000]
  - Default: 250

HISE CLI build commands:
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

