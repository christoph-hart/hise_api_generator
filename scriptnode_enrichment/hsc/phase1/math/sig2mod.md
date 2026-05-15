# math.sig2mod - HSC Scenario

## Node

- Factory path: `math.sig2mod`
- Source page: `scriptnode_enrichment/output/math/sig2mod.md`

## Scenario

- Title: Audio-to-modulation converter
- Project context: A very slow oscillator drives one peak display directly and a second peak display after `math.sig2mod`. The first view shows the folded absolute-value style behavior that peak-style modulation consumers see from a bipolar signal, while the second shows the proper 0..1 modulation curve.
- Teaching goal: Demonstrate how `math.sig2mod` converts a bipolar signal into the unipolar range expected by modulation-oriented nodes and displays.

## Support Nodes

- Required: [`core.oscillator`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: A very slow oscillator provides a clearly visible bipolar source, and two peak displays make the before and after range conversion easy to compare.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put the oscillator in an LFO-style range and use about `0.8 Hz` so the peak displays show the curve shape clearly.
- The first and second peak displays should stay adjacent so the benefit of the conversion is immediately visible.
- End the artificial signal safely if the oscillator remains audible in the host chain.
