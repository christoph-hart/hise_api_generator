# analyse.fft - HSC Scenario

## Node

- Factory path: `analyse.fft`
- Source page: `scriptnode_enrichment/output/analyse/fft.md`

## Scenario

- Title: Oscillator spectrum comparison
- Project context: A Script FX splits a test signal into sine, saw, and noise branches, with an FFT analyser on each branch so their harmonic content can be compared side by side.
- Teaching goal: Demonstrate how analyse.fft visualises distinct spectra and why analyser placement matters in a branched graph.

## Support Nodes

- Required: [`container.split`, `container.chain`, `math.clear`, `core.oscillator`, `core.gain`]
- Optional: []
- Rationale: `container.split` creates the three parallel comparisons, while one `container.chain` per branch keeps each oscillator and FFT analyser in sequence. `math.clear` removes the incoming Script FX audio before each additive oscillator, and `core.gain` compensates the three branches before the split sums them.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - Resolved: clear the summed test signal after analysis instead of sending the oscillator mixture to the Script FX output.

## Notes For Phase 2

- Keep each oscillator and its analyser in a separate chain under the split container. Match analyser settings so the displayed spectra are directly comparable.
- Clear the incoming signal before each oscillator because `core.oscillator` adds its waveform to its input.
- Apply branch gain compensation before summing, then clear the final output so the network acts as an analysis fixture rather than an audible signal generator.
- Persist identical FFT display settings through `DisplayBuffer.setRingBufferProperties()`; popup edits alone do not survive reloads.
