# control.bipolar - HSC Scenario

## Node

- Factory path: `control.bipolar`
- Source page: `scriptnode_enrichment/output/control/bipolar.md`

## Scenario

- Title: Centre-Preserving Vibrato Depth
- Project context: A fixed-rate triangle LFO is converted to a normalised signal and passed through `control.bipolar`. Its Scale parameter controls how far a MIDI-pitched saw oscillator moves above and below the neutral frequency ratio, allowing vibrato depth to reach zero without shifting the centre pitch.
- Teaching goal: Demonstrate that `control.bipolar` scales modulation symmetrically around 0.5 and can invert direction without changing the centre value.

## Support Nodes

- Required: [`container.modchain`, `container.no_midi`, `core.oscillator`, `math.sig2mod`, `core.peak`]
- Optional: []
- Rationale: `container.modchain` isolates control generation; `container.no_midi` keeps the triangle LFO at a fixed sub-audio frequency; one `core.oscillator` generates that triangle and another generates the audible MIDI-pitched saw; `math.sig2mod` converts the LFO from -1..1 to 0..1; and `core.peak` exports it to `control.bipolar.Value`.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Inside the modchain, build `container.no_midi -> triangle core.oscillator -> math.sig2mod -> core.peak`, then route the peak output into `control.bipolar.Value` and its output to the audible oscillator's `Freq Ratio`.
- Override the LFO Frequency range to include a fixed sub-audio rate and override the target ratio to the continuous musically meaningful span `[0.988514, 1.011619]`, representing -20 to +20 cents around midpoint `1.0`. Verify fractional ratio modulation in HISE.
- Expose `control.bipolar.Scale` as Vibrato Depth. At zero, output must remain 0.5 and map to ratio 1.0; at one, it must traverse the full symmetric ratio range.
- Lock Gamma to 1.0 for the canonical linear response. A negative Scale may be tested to show inversion, but should not alter perceived vibrato depth or centre pitch.
- Keep the audible oscillator outside `container.no_midi` so note-on events still establish its base pitch.
