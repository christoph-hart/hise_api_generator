# control.ppq - HSC Scenario

## Node

- Factory path: `control.ppq`
- Source page: `scriptnode_enrichment/output/control/ppq.md`

## Scenario

- Title: Phrase-Position Start Pan
- Project context: Starting playback at different positions within a one-bar window assigns a corresponding static pan position to the effect. The pan updates again only when the host jumps or loops, clearly separating a PPQ snapshot from a continuously moving clock ramp.
- Teaching goal: Demonstrate wrapped PPQ position capture on transport start and position jumps, including its intentionally non-continuous output.

## Support Nodes

- Required: [`jdsp.jpanner`]
- Optional: [`control.transport`]
- Rationale: `jdsp.jpanner` maps the normalised phrase position to an immediately audible left-to-right location; optional transport state can be displayed for verification but is not required for the modulation topology.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure Tempo and Multiplier for a one-bar window and connect PPQ output to `jdsp.jpanner.Pan` from -1 to +1.
- Lock a constant-power pan rule and use centred mono source material duplicated to stereo for clear position verification.
- Start playback at multiple points in the bar and confirm the pan is a snapshot. It must not sweep while playback advances normally.
- Test a loop boundary and a manual seek to confirm those position jumps emit updated values.
- Moving the ruler while stopped does not emit immediately; the new position is captured on the next start.
- Do not substitute `core.clock_ramp`, because continuous movement would contradict the node's defining behaviour.
