# container.oversample4x - HSC Scenario

## Node

- Factory path: `container.oversample4x`
- Source page: `scriptnode_enrichment/output/container/oversample4x.md`

## Scenario

- Title: Production Hard Clipper
- Project context: A monophonic distortion insert boosts incoming audio into a low-threshold hard clipper, then trims the result, with all three stages running at a fixed 4x rate. The example presents 4x as a practical production balance for a processor whose sharp corners create more aliasing than gentle saturation.
- Teaching goal: Demonstrate the quality-versus-CPU middle ground of fixed 4x oversampling around conventional block-based distortion.

## Support Nodes

- Required: [`math.mul`, `math.clip`]
- Optional: [`analyse.fft`]
- Rationale: A pre-gain `math.mul` forces the signal beyond the `math.clip` threshold, the clipper generates the strong harmonics that justify 4x processing, and a second multiplier controls output level; an optional FFT verifies reduced foldback relative to the bypassed 1x case.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Order the child chain as pre-gain, `math.clip`, then output trim, all inside `container.oversample4x`. Override the pre-gain multiplier range above unity and expose Drive while keeping the clipping threshold low enough to create obvious harmonics.
- Keep this in block processing. `math.clip` has a documented single-sample implementation discrepancy inside frame containers, so a frame wrapper would change the algorithm rather than merely its update precision.
- Verify that a 44.1 kHz base session prepares children at 176.4 kHz and four times the base block size.
- Use Polyphase filtering as the canonical startup mode. Any FIR comparison must keep source, drive, threshold, output level, and analyser settings unchanged.
- The network must be monophonic, must not nest oversampling containers, and must avoid an uncompensated parallel dry path because filter latency is unreported.
- Compare active and bypassed spectra at matched level. Bypass removes resampling but continues to process the complete distortion chain at the original rate.
