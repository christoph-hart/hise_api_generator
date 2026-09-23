# container.oversample - HSC Scenario

## Node

- Factory path: `container.oversample`
- Source page: `scriptnode_enrichment/output/container/oversample.md`

## Scenario

- Title: Selectable Anti-Aliasing Quality
- Project context: A monophonic distortion effect drives incoming audio through an aggressive sine-folding expression that generates strong high-order harmonics. A public Quality selector switches the child processing from 1x through 16x so alias reduction and CPU cost can be compared with one topology.
- Teaching goal: Demonstrate how `container.oversample` changes the sample rate and block size seen by nonlinear children, and why its factor is a configuration choice rather than a continuously modulated effect parameter.

## Support Nodes

- Required: [`math.expr`]
- Optional: [`analyse.fft`]
- Rationale: `math.expr` implements a deliberately aggressive sine-folding transfer function that produces obvious aliasing at 1x; an optional `analyse.fft` can display the reduction in folded spectral components without becoming part of the processing topology.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put only the nonlinear `math.expr` stage inside `container.oversample`; unrelated processors would multiply CPU cost without helping alias suppression.
- Use a compile-enabled network and lock a single-line SNEX sine-folding formula with explicit float literals and enough drive to make spectral foldback visible.
- Expose Oversampling as labelled choices None, 2x, 4x, 8x, and 16x. The raw values are exponent indices 0 through 4, not factors.
- Treat Quality changes as setup operations. Each change re-prepares the child chain and can produce a brief silent buffer, so do not automate or modulate it during performance.
- Keep the topology monophonic and block-based. Do not nest it in another oversampling container or a frame context.
- Verify each factor using identical source audio and FFT settings, and compare both alias components and CPU. If `analyse.fft` is added, place it after the container rather than inside it.
- Start with Polyphase filtering and optionally compare FIR as a deliberate second verification. Account for unreported resampling latency and avoid an uncompensated parallel dry path.
- Bypass removes resampling but still runs the waveshaper at the original rate; it is not a CPU bypass for the child.
