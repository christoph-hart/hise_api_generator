# container.oversample16x - HSC Scenario

## Node

- Factory path: `container.oversample16x`
- Source page: `scriptnode_enrichment/output/container/oversample16x.md`

## Scenario

- Title: Extreme Foldback Stress Test
- Project context: A deliberately pathological nested-sine expression processes high-frequency input and produces harmonics close to and beyond Nyquist. The example uses fixed 16x oversampling as a diagnostic upper bound, then requires evidence that its spectral improvement over lower practical factors warrants the extreme CPU cost.
- Teaching goal: Demonstrate that `container.oversample16x` is a last-resort quality setting for extreme nonlinear spectra, not a default wrapper for ordinary distortion.

## Support Nodes

- Required: [`math.expr`]
- Optional: [`analyse.fft`]
- Rationale: `math.expr` supplies a controllable nested-sine transfer function with more severe high-order content than ordinary clipping, while an optional post-container FFT provides the spectral evidence needed to justify or reject the 16x factor.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put only the nested-sine `math.expr` inside `container.oversample16x`; multiplying unrelated child work by sixteen would undermine the example's CPU lesson.
- Use a compile-enabled network and a single-line SNEX formula with explicit float literals. Expose a bounded Stress control and choose a default that creates measurable foldback without unstable or unbounded output.
- Verify at a low base sample rate and with high-frequency source material so 4x, 8x, and 16x differences can be measured. Lower-factor reference captures may use temporary comparison builds, but the canonical final topology contains only `container.oversample16x`.
- Record spectrum and CPU for all compared factors at matched source, expression value, output level, filter type, and analyser settings. The example succeeds only if it communicates when 16x is unnecessary as well as when it helps.
- At 44.1 kHz, confirm child preparation at 705.6 kHz and a block size multiplied by sixteen.
- Keep the network monophonic and block-based, do not nest resamplers, and avoid parallel dry paths because filter latency is unreported.
- Bypass is the 1x comparison and still runs the expression; it does not emulate 4x or 8x and does not save the child's processing cost.
