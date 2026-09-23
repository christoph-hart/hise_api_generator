# control.unscaler - HSC Scenario

## Node

- Factory path: `control.unscaler`
- Source page: `scriptnode_enrichment/output/control/unscaler.md`

## Scenario

- Title: Exact Millisecond Delay Broadcast
- Project context: One public Delay Time parameter is expressed in milliseconds and must set two serial delay stages to the identical native value. `control.unscaler` forwards that raw number to both targets without each target reinterpreting it through its own range.
- Teaching goal: Demonstrate unchanged unnormalised passthrough and bypass of target range conversion.

## Support Nodes

- Required: [`core.fix_delay`]
- Optional: []
- Rationale: Two `core.fix_delay` instances provide native millisecond destinations where exact equality can be inspected and where accidental normalised mapping would produce clearly incorrect times.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Override `control.unscaler.Value` to the public millisecond range and connect its output to DelayTime on both `core.fix_delay` instances.
- Keep both delay target ranges compatible with the source and below the 1000 ms maximum. The output value must reach both targets unchanged.
- Expose Delay Time in milliseconds and lock distinct non-zero FadeTime values only if their crossfade behaviour needs differentiation; FadeTime uses samples.
- Verify exact target values at minimum, midpoint, and maximum, including a value above 1 to prove no normalised mapping occurs.
- This node does not smooth or convert units. Use the smoothed unscaled variant if abrupt target changes are unsuitable.
