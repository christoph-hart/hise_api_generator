---
id: container.no_midi.midi-isolated-tremolo-lfo
node: container.no_midi
domain: scriptnode
category: dsp-network
title: "MIDI-Isolated Tremolo LFO"
summary: "A serial container that blocks all MIDI events from reaching its children."
useCase: "Demonstrate that `container.no_midi` preserves serial audio processing while preventing every incoming event from reaching a MIDI-reactive subtree."
difficulty: beginner
networkName: midi_isolated_tremolo_lfo
moduleType: ScriptSynth
moduleId: MidiIsolatedTremoloLfo
tags:
  - container
  - no
  - midi
  - event-processing
aliases:
  - midi-isolated tremolo lfo
  - no midi container
relatedNodes:
  - container.no_midi
  - container.modchain
  - core.oscillator
  - math.sig2mod
  - math.mul
  - core.peak
  - envelope.simple_ar
  - envelope.voice_manager
parameters:
  Rate: "Rate -> TremoloOscillator.Frequency matched"
  Target: "Target range before connection: [0.5, 8]"
  Macro: "Macro range: [0.5, 8]"
  Default:: "Default: 4"
  Depth: "Depth -> TremoloDepth.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.6"
---

scriptnode example: container.no_midi

MIDI-Isolated Tremolo LFO.

Demonstrate that `container.no_midi` preserves serial audio processing while preventing every incoming event from reaching a MIDI-reactive subtree.

Graph:
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

Host:
  Module: MidiIsolatedTremoloLfo
  Network: midi_isolated_tremolo_lfo
  Type: `ScriptSynth`
  Builder setup: `add ScriptSynth as "MidiIsolatedTremoloLfo"`, then set its network to `midi_isolated_tremolo_lfo`.

Support nodes:
  Required: container.modchain, core.oscillator, math.sig2mod, math.mul, core.peak, envelope.simple_ar, envelope.voice_manager
  `container.modchain` isolates LFO generation from the audio signal; a sine `core.oscillator` inside the no-MIDI subtree generates fixed-rate bipolar motion; `math.sig2mod`, `math.mul`, and `core.peak` convert, scale, and export it as normalised modulation; a second saw `core.oscillator` remains outside the wrapper so MIDI retunes the audible tone; `envelope.simple_ar` articulates that tone; and `envelope.voice_manager` ends released voices.

Key rules:

Public controls:
  - Rate -> TremoloOscillator.Frequency matched
  - Target range before connection: [0.5, 8]
  - Macro range: [0.5, 8]
  - Default: 4
  - Depth -> TremoloDepth.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.6

HISE CLI build commands:
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

