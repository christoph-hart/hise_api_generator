# control.intensity - HSC Scenario

## Node

- Factory path: `control.intensity`
- Source page: `scriptnode_enrichment/output/control/intensity.md`

## Scenario

- Title: HISE-Style Gain Modulation Depth
- Project context: A repeating ramp supplies a 0 to 1 gain modulation signal to an audio multiplier. `control.intensity` provides the user-facing Amount control, fading from unity gain at zero intensity to the complete ramp-shaped tremolo at full intensity.
- Teaching goal: Demonstrate the HISE gain modulation formula where zero intensity means no gain change, not zero output.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `math.mul`]
- Optional: []
- Rationale: `container.modchain` keeps the ramp's additive audio contribution out of the parent signal; `core.ramp` supplies an easily inspected normalised modulation shape; and `math.mul` applies the intensity result as raw linear gain to incoming audio.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place `core.ramp` inside `container.modchain`, connect its modulation output to `control.intensity.Value`, and connect the intensity output to `math.mul.Value` in the parent audio path.
- Expose Intensity as Amount from 0 to 100 percent and optionally expose ramp period as Rate. Keep all modulation and multiplier ranges at 0 to 1.
- Verify the formula at three settings: Amount 0 must hold multiplier gain at 1.0, Amount 0.5 must blend halfway between unity and the ramp, and Amount 1 must follow the ramp directly.
- Do not replace `math.mul` with `core.gain`; decibel conversion and smoothing would obscure the linear HISE intensity formula.
- Keep the ramp in the modchain because `core.ramp` otherwise adds its value to every audio channel.
