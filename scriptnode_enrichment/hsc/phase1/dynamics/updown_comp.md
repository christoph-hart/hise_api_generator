# dynamics.updown_comp - HSC Scenario

## Node

- Factory path: `dynamics.updown_comp`
- Source page: `scriptnode_enrichment/output/dynamics/updown_comp.md`

## Scenario

- Title: Dual-threshold vocal leveler
- Project context: A stereo vocal or dialogue stem has both whisper-quiet syllables and occasional loud peaks, and needs a single processor that gently lifts the low-level phrases while taming louder moments. `dynamics.updown_comp` is used as a broad leveler with a unity zone between the low and high thresholds so mid-level material stays natural, and its modulation output is forwarded to the global cable system for linked metering or downstream dynamics-aware processing.
- Teaching goal: Demonstrate how `dynamics.updown_comp` combines upward and downward compression around a defined unity region while publishing its gain-change signal to a `routing.global_cable` target.

## Support Nodes

- Required: [`routing.global_cable`]
- Optional: [`math.mul`]
- Rationale: `routing.global_cable` makes the example more practical by showing how the processor's gain-change signal can be reused elsewhere in the project for metering or linked dynamics reactions. An optional math target could further reshape that signal, but the core point is the cable handoff.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The topology must stay exactly stereo; this node is not suitable for mono or wider multichannel layouts.
- The example should preserve a visible gap between `LowThreshold` and `HighThreshold` so the unity zone is easy to understand.
- The modulation output only reflects attenuation in the exported 0..1 range, so note that upward boost is not represented when sending the signal to `routing.global_cable`.
- If RMS is exposed, present it as a character switch between transient-sensitive peak behaviour and smoother average-level control.
