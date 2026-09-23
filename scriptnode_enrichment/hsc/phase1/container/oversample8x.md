# container.oversample8x - HSC Scenario

## Node

- Factory path: `container.oversample8x`
- Source page: `scriptnode_enrichment/output/container/oversample8x.md`

## Scenario

- Title: Aggressive Sine-Fold Distortion
- Project context: Incoming audio is driven through a programmable sine-folding transfer function that repeatedly reverses waveform direction and generates dense upper harmonics. Fixed 8x processing strongly suppresses audible foldback while making its substantial CPU multiplier visible.
- Teaching goal: Demonstrate when the stronger alias reduction of `container.oversample8x` is justified over the more typical 4x factor.

## Support Nodes

- Required: [`math.expr`]
- Optional: [`analyse.fft`]
- Rationale: `math.expr` implements the repeated sine-folding curve responsible for severe alias generation, while an optional post-container FFT makes spectral foldback and the benefit of 8x processing directly comparable.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place one `math.expr` inside `container.oversample8x` and use a compile-enabled network. Its Code must be a single-line SNEX sine-folding formula using only `input`, `value`, and correctly suffixed float literals.
- Expose a bounded Fold control through `math.expr.Value` and choose a startup value that creates multiple folds without excessive output level.
- Use Polyphase filtering initially and verify that a 44.1 kHz base session prepares the child at 352.8 kHz with an eight-times-larger block.
- Compare the enabled and bypassed spectra with identical input, expression value, output gain, and analyser settings. Bypass retains the expression processing at 1x and re-prepares the child.
- Record CPU alongside the spectral result and explicitly compare against whether 4x would be sufficient; the child's processing cost is multiplied by eight.
- Keep the network monophonic and block-based. Do not nest resampling containers or put the node in a frame context.
- Place any FFT after the oversampling container and avoid a parallel dry path because resampling latency is not reported.
