# dynamics.gate - HSC Scenario

## Node

- Factory path: `dynamics.gate`
- Source page: `scriptnode_enrichment/output/dynamics/gate.md`

## Scenario

- Title: Noise layer gate from split signal
- Project context: A transient-rich source should open a filtered noise layer only while the source is active, adding a short burst of texture around note attacks. The main signal feeds `dynamics.gate`, and the gate's modulation output controls the gain of a second split branch that contains an oscillator set to noise. In a real project, a looped noise sample in a file player would often be the better source, but the oscillator keeps the example minimal.
- Teaching goal: Demonstrate how `dynamics.gate` can derive a control signal from an input and use that signal to open or close a separate texture layer.

## Support Nodes

- Required: [`container.split`, `core.gain`, `core.oscillator`]
- Optional: [`container.fix16_block`, `filters.svf_eq`]
- Rationale: `container.split` makes the dry branch and the gated noise branch visible in one topology. `core.gain` is the practical target for the gate modulation, and `core.oscillator` provides a minimal noise source for the secondary branch. `container.fix16_block` is optional if the example wants deterministic gate/modulation timing, while EQ can shape the noise layer into a more deliberate texture.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep this example self-keyed; do not add a sidechain routing setup, because the point is using the source itself to control a second branch.
- Set the secondary oscillator to noise and mention that a looped file-player noise source would often be more production-friendly in a real project.
- Clear the split branch before the noise source so the texture path does not duplicate the dry input.
- The example should make the dry branch and the noise branch visually distinct so the modulation target is obvious at a glance.
- If the gate needs more predictable time-sensitive behaviour, wrap the relevant section in `container.fix16_block` or `container.fix8_block` so the control update rate does not depend on the parent block size.
- If adjustable gate depth is shown, scale the modulation output before the gain target instead of turning the example into a hard on/off gate only.
