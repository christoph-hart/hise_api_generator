# control.converter - HSC Scenario

## Node

- Factory path: `control.converter`
- Source page: `scriptnode_enrichment/output/control/converter.md`

## Scenario

- Title: Tempo Duration To Sample Hold Count
- Project context: A tempo-sync source calculates a musical interval in milliseconds, but a sample-and-hold effect expects its hold duration as a number of samples. `control.converter` uses Ms2Samples so the decimation period remains locked to the selected note value across sample-rate and tempo changes.
- Teaching goal: Demonstrate explicit conversion between millisecond and sample domains using the current processing sample rate.

## Support Nodes

- Required: [`control.tempo_sync`, `fx.sampleandhold`]
- Optional: []
- Rationale: `control.tempo_sync` supplies the raw musical duration in milliseconds, and `fx.sampleandhold` provides the sample-count target whose domain mismatch makes the converter necessary and audible.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set converter Mode to Ms2Samples, connect tempo-sync output to converter Value, and route the raw converted output directly to `fx.sampleandhold.Counter`.
- Override Counter's initial 1 to 64 parameter range to cover the sample counts produced by the supported tempo divisions, BPM values, and sample rates. Verify the node accepts and processes these larger integer counts in HISE.
- Enable tempo sync explicitly and expose Tempo and Multiplier. Counter must remain at least 1 and use integer stepping.
- At 44.1 kHz, verify that a 500 ms duration produces approximately 22050 samples, then change sample rate and confirm the converted count updates automatically while musical duration stays constant.
- This intentionally produces extreme low-rate sample holding for ordinary note lengths. Use safe source material and explain that the stock Counter range was overridden for the domain-conversion demonstration.
- Ensure all maximum generated values remain within the implementation's usable integer and buffer-count limits.
