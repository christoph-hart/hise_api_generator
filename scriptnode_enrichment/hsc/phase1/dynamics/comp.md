# dynamics.comp - HSC Scenario

## Node

- Factory path: `dynamics.comp`
- Source page: `scriptnode_enrichment/output/dynamics/comp.md`

## Scenario

- Title: Sidechain ducking compressor
- Project context: A stereo synth pad should dip in level whenever a kick-trigger signal arrives, creating the classic pumping effect used in dance production. The example wraps `dynamics.comp` in `container.sidechain`, routes the kick key into the extra sidechain channels, and uses external sidechain mode so the compressor responds to a second signal rather than the pad itself.
- Teaching goal: Demonstrate how `dynamics.comp` works with `container.sidechain` to compress one stereo signal from the level of another.

## Support Nodes

- Required: [`container.sidechain`, `routing.receive`, `routing.send`]
- Optional: [`container.fix16_block`, `math.mul`]
- Rationale: `container.sidechain` is the standard routing wrapper because it doubles the channel count and exposes zeroed sidechain channels to the compressor. A send/receive pair provides a realistic external key signal, `container.fix16_block` is optional if the example wants deterministic sub-block updates for more predictable time-sensitive behaviour, and `math.mul` is optional if the compressor's modulation output also drives a secondary ducking target.

## Assumptions

- Channels: multichannel required
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The example should use `container.sidechain` so children see channels 0-1 as program audio and channels 2-3 as sidechain input.
- Treat `container.sidechain` as a channel-duplicating topology node: stereo input becomes two internal stereo pairs, not a separate keyed branch.
- The `Sidechain` parameter should be set to `Sidechain`, not `Disabled` or `Original`, otherwise the example collapses into ordinary self-keyed compression.
- The second stereo pair should be cleared and replaced with a `core.ramp` detector so the pumping stays independent from the source audio.
- If responsiveness is part of the example, wrap the time-sensitive section in `container.fix16_block` or `container.fix8_block` so the compressor update timing is deterministic.
- If the modulation output is exposed, note that it represents inverse gain reduction and must be inverted before it controls gain on another target.
