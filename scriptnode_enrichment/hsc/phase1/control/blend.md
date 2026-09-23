# control.blend - HSC Scenario

## Node

- Factory path: `control.blend`
- Source page: `scriptnode_enrichment/output/control/blend.md`

## Scenario

- Title: Humanised LFO Blend
- Project context: A regular sine LFO and a sampled, heavily smoothed noise source provide two normalised control signals. A Humanise control crossfades their values through `control.blend`, moving a filter cutoff from predictable motion toward slow random drift.
- Teaching goal: Demonstrate direct linear interpolation between two live control values and immediate recalculation when either source or Alpha changes.

## Support Nodes

- Required: [`container.modchain`, `container.split`, `container.no_midi`, `core.oscillator`, `fx.sampleandhold`, `core.smoother`, `math.sig2mod`, `core.peak`, `control.normaliser`, `filters.svf`]
- Optional: []
- Rationale: `container.modchain` isolates control generation; `container.split` provides independent sine and noise branches; `container.no_midi` prevents note events retuning the LFO oscillators; two `core.oscillator` instances generate sine and noise; `fx.sampleandhold` reduces the noise update rate; `core.smoother` turns the stepped noise into slow drift; `math.sig2mod` and `core.peak` normalise and export each branch; `control.normaliser` maps the raw blended value into the filter range; and `filters.svf` makes the blended signal audible as cutoff motion.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Inside the modchain, use a split with one fixed-rate sine branch and one Noise-mode oscillator followed by `fx.sampleandhold` and `core.smoother`. End each branch with `math.sig2mod -> core.peak` and route those outputs separately to Value1 and Value2.
- Override the sine oscillator Frequency range for a sub-audio rate and wrap MIDI-sensitive LFO generation in `container.no_midi`. Use sample-and-hold Counter `412` and smoother SmoothingTime `772.6` to make the noise branch audible as slow drift.
- Expose `control.blend.Alpha` as Humanise, with 0 selecting the sine and 1 selecting filtered noise. Route the raw blend output through `control.normaliser` before the bounded LP SVF frequency range.
- Set the target filter cutoff low enough to make modulation audible and keep the target SVF smoothing non-zero.
- Verify exact endpoint equality and midpoint interpolation using control traces before judging the audible result.
