# control.smoothed_parameter_unscaled - HSC Scenario

## Node

- Factory path: `control.smoothed_parameter_unscaled`
- Source page: `scriptnode_enrichment/output/control/smoothed_parameter_unscaled.md`

## Scenario

- Title: Click-Free Raw Delay Time
- Project context: A public Delay Time control sends native millisecond values to an interpolating delay line that has no internal smoothing. `control.smoothed_parameter_unscaled` ramps those raw values before forwarding them directly, preventing abrupt read-position jumps.
- Teaching goal: Demonstrate smoothing in a native unit domain without applying the target's range conversion.

## Support Nodes

- Required: [`jdsp.jdelay`]
- Optional: []
- Rationale: `jdsp.jdelay` accepts DelayTime in milliseconds and explicitly requires external smoothing for direct control changes, making it the canonical raw-value destination.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Override Value to the same millisecond range used by `jdsp.jdelay.DelayTime`, connect the public Delay Time control to Value, and forward output directly to the delay target.
- Use a monophonic effect context so the full delay range is available; polyphonic jdelay use reduces Limit and DelayTime to 30 ms.
- Set delay Limit above the maximum exposed time. Set smoothing Mode to Linear Ramp and keep Enabled on.
- Verify the target receives exact millisecond values rather than a second range mapping, and compare enabled versus disabled smoothing during large knob jumps.
- Expose SmoothingTime separately and ensure the source range never exceeds the allocated Limit.
- This control-rate smoothing is appropriate for knob changes, not a substitute for frame-rate modulation in chorus or flanger effects.
