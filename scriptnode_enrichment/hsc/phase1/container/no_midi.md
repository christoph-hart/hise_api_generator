# container.no_midi - HSC Scenario

## Node

- Factory path: `container.no_midi`
- Source page: `scriptnode_enrichment/output/container/no_midi.md`

## Scenario

- Title: MIDI-Isolated Tremolo LFO
- Project context: A Scriptnode Synthesiser runs one saw voice and one hardwired sine LFO per active voice. The LFO sits inside `container.no_midi`, so played notes retune the audible oscillator and trigger its envelope without changing each voice's fixed sub-audio LFO frequency.
- Teaching goal: Demonstrate that `container.no_midi` preserves serial audio processing while preventing every incoming event from reaching a MIDI-reactive subtree.

## Support Nodes

- Required: [`container.modchain`, `core.oscillator`, `math.sig2mod`, `math.mul`, `core.peak`, `envelope.simple_ar`, `envelope.voice_manager`]
- Optional: []
- Rationale: `container.modchain` isolates LFO generation from the audio signal; a sine `core.oscillator` inside the no-MIDI subtree generates fixed-rate bipolar motion; `math.sig2mod`, `math.mul`, and `core.peak` convert, scale, and export it as normalised modulation; a second saw `core.oscillator` remains outside the wrapper so MIDI retunes the audible tone; `envelope.simple_ar` articulates that tone; and `envelope.voice_manager` ends released voices.

## Assumptions

- Host context: Scriptnode Synthesiser
- Channels: default stereo in a polyphonic voice context
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build the network in a Scriptnode Synthesiser (`ScriptSynth` internally), not a Script FX. The synthesiser host creates the polyphonic voice context needed to demonstrate one isolated LFO per voice.
- In the main serial path, place the modulation chain before the MIDI-responsive saw oscillator and its `envelope.simple_ar` amplitude stage.
- Inside `container.modchain`, nest `container.no_midi` around `core.oscillator -> math.sig2mod -> math.mul -> core.peak`; connect Depth to the multiplier and connect the peak output to the audible oscillator's Gain over a restrained non-zero tremolo range.
- Override the LFO oscillator Frequency range to include a fixed sub-audio rate and verify that HISE accepts the range. Its Gate remains on and it must not receive note-on pitch changes.
- Keep the audible oscillator outside `container.no_midi` so incoming note-on events still set pitch, and keep the envelope and voice manager outside so note-on and note-off still articulate and terminate the voice.
- Expose LFO Rate and tremolo Depth, but do not add selective event controls: `container.no_midi` blocks note, CC, pitch-wheel, aftertouch, and all other event types indiscriminately.
- Verify by playing widely separated MIDI notes while measuring an unchanged tremolo period. The modchain prevents the LFO oscillator's generated signal from leaking into the parent audio.
