# container.fix32_block - HSC Scenario

## Node

- Factory path: `container.fix32_block`
- Source page: `scriptnode_enrichment/output/container/fix32_block.md`

## Scenario

- Title: Sidechain Dynamic Mid Cut
- Project context: A separate internally generated key signal is analysed by an envelope follower while the main stereo input passes through untouched. The follower scales a peak EQ cut on the main signal inside a 32-sample container, creating a compact TrackSpacer-style frequency ducking demonstration.
- Teaching goal: Demonstrate why `container.fix32_block` is a practical general-purpose cadence for envelope-followed dynamic EQ: responsive enough for level tracking while avoiding the iteration cost reserved for pitch modulation and very fast envelopes.

## Support Nodes

- Required: [`container.sidechain`, `container.multi`, `container.chain`, `container.no_midi`, `core.oscillator`, `dynamics.envelope_follower`, `control.pma_unscaled`, `filters.svf_eq`]
- Optional: []
- Rationale: `container.sidechain` creates an internal auxiliary stereo pair; `container.multi` separates untouched main audio from the key detector; an empty `container.chain` passes the main pair; `container.no_midi` protects the fixed-rate key oscillator; `dynamics.envelope_follower` analyses only the key slice; `control.pma_unscaled` multiplies raw maximum-cut dB by the follower amount; and `filters.svf_eq` applies the resulting peak cut after both slices have been processed.

## Assumptions

- Channels: default stereo externally, four channels inside the sidechain container
- Public control needed: yes; `MaxCut` controls the maximum negative EQ gain in dB
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put `container.sidechain` inside `container.fix32_block`; inside it, process an empty main stereo branch and a separately generated key stereo branch with `container.multi`.
- Generate a slow sine key inside `container.no_midi` so the example is self-contained. The key is for detector demonstration only and is discarded when leaving `container.sidechain`.
- Place the peak EQ after `container.multi`, not inside the main branch. This guarantees the key follower and PMA update before the EQ processes each 32-sample chunk.
- Leave `dynamics.envelope_follower.ProcessSignal` off so it analyses the key while passing the auxiliary signal unchanged.
- Use `control.pma_unscaled` to multiply raw negative MaxCut dB by the follower's normalised 0 to 1 output, then drive `filters.svf_eq.Gain` directly.
- Set EQ smoothing to exactly zero so envelope timing and the 32-sample cadence are not hidden by another interpolation stage.
- Explain that this is an internally keyed teaching fixture, not a DAW sidechain input. External TrackSpacer-style routing requires the appropriate plugin channel configuration.
- Describe 32 samples as a maximum chunk size because a final remainder can be shorter.
