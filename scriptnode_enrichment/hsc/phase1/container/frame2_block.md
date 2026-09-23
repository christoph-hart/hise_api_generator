# container.frame2_block - HSC Scenario

## Node

- Factory path: `container.frame2_block`
- Source page: `scriptnode_enrichment/output/container/frame2_block.md`

## Scenario

- Title: MIDI-Tuned Pseudo-Stereo Karplus Resonator
- Project context: Each MIDI note triggers a very short enveloped noise burst that excites a stereo feedback delay whose period follows the same note frequency. `container.frame2_block` reduces the feedback-routing latency to one sample, while slightly different left and right delay multipliers spread the resonant decay into pseudo stereo.
- Teaching goal: Demonstrate a practical stereo frame-processing use case: a minimal Karplus-Strong-style resonator requiring per-sample feedback and MIDI-tuned sub-millisecond delay control.

## Support Nodes

- Required: [`container.midichain`, `core.oscillator`, `envelope.ahdsr`, `control.midi`, `control.pma_unscaled`, `control.converter`, `template.feedback_delay`, `container.multi`, `jdsp.jdelay_cubic`, `filters.one_pole`]
- Optional: []
- Rationale: `container.midichain` delivers note events in a Script FX; a Noise-mode `core.oscillator` and short `envelope.ahdsr` create the excitation burst; `control.midi` extracts normalized note frequency; PMA scales it to raw Hz; `control.converter` converts frequency to period milliseconds; two further PMAs apply subtle stereo delay ratios; the feedback template supplies receive/send routing; `container.multi` gives each channel an independent delay; cubic interpolation supports fractional tuned periods; and a one-pole low-pass damps the feedback decay.

## Assumptions

- Channels: default stereo
- Public control needed: yes; Feedback and Damping controls
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Inside `container.midichain`, group the Noise oscillator and short AHDSR in a compact `container.chain` named `Exciter`, followed by the stereo frame resonator. The same note event triggers the burst and updates delay tuning before the resonator processes it.
- Convert `control.midi` Frequency output from normalized frequency/20000 to raw Hz with `control.pma_unscaled`, then use `control.converter` in Freq2Ms mode.
- Feed the period into two unscaled PMAs. Multiply the left period by 0.998 and the right by 1.002 for a subtle reciprocal-like stereo pitch spread around the played note.
- Start with `template.feedback_delay`, remove its generated `core.fix_delay`, and insert a two-child `container.multi` containing independent left and right cubic delays. Keep the feedback send after both stereo delays and the damping filter.
- The feedback template's internal fixed-block wrapper becomes a no-op inside frame mode, so the send/receive loop contributes one sample of feedback latency.
- Set Feedback below 1 and add a low-pass damping stage to guarantee decay. Warn that this is a simple educational Karplus model; exact pitch also depends on the one-sample loop latency, interpolation, and filter phase.
- Use a 0 ms attack, 1 ms hold, 8 ms decay, zero sustain, and 5 ms release for a self-contained excitation burst. A MIDI note now both tunes and excites the resonator.
- Warn that interpreted frame processing is expensive and practical use should compile the network to a C++ node.
