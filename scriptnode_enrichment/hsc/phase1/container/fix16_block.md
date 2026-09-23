# container.fix16_block - HSC Scenario

## Node

- Factory path: `container.fix16_block`
- Source page: `scriptnode_enrichment/output/container/fix16_block.md`

## Scenario

- Title: Snappy Filter Envelope
- Project context: A MIDI-triggered saw voice passes through a fast-attack AHDSR envelope and low-pass filter. The same envelope CV sweeps filter cutoff inside a 16-sample container, with filter smoothing disabled so the fixed-block update cadence remains authoritative.
- Teaching goal: Demonstrate why `container.fix16_block` is a practical compromise for fast filter envelopes that need tighter updates than ordinary control-rate processing without paying the iteration cost of 8-sample pitch modulation.

## Support Nodes

- Required: [`core.oscillator`, `envelope.ahdsr`, `filters.svf`, `envelope.voice_manager`]
- Optional: []
- Rationale: The Scriptnode Synthesiser root already supplies the required voice and MIDI context; `core.oscillator` provides a harmonically rich saw source; `envelope.ahdsr` shapes amplitude and exports the fast CV; `filters.svf` exposes a stable modulatable cutoff with smoothing explicitly disabled; and `envelope.voice_manager` uses the envelope Gate output for proper voice cleanup.

## Assumptions

- Channels: default stereo in a polyphonic Scriptnode Synthesiser
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a `Scriptnode Synthesiser` and place the fixed-block voice path directly under the network root. The synth already provides the voice and MIDI context, so an additional `container.midichain` is unnecessary.
- Order the audio nodes `core.oscillator -> envelope.ahdsr -> filters.svf`; connect the AHDSR CV output to filter Frequency and its Gate output to `envelope.voice_manager.Kill Voice`.
- Use a 1 ms attack, 300 ms decay, and 0.5 sustain for a clear fast-onset filter transient with enough decay time to inspect the 16-sample cutoff updates.
- Set `filters.svf.Smoothing` to exactly 0 before verification. Any filter-side smoothing would conceal the 16-sample modulation cadence and undermine the example.
- Use a broad skewed cutoff range and moderate resonance so the envelope movement is clearly audible without unstable peaks.
- Describe 16 samples as a maximum chunk size because a final host-buffer remainder can be shorter. Derive update frequency from the active sample rate rather than treating one nominal rate as universal.
