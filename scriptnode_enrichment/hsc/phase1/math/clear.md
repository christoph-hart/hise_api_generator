# math.clear - HSC Scenario

## Node

- Factory path: `math.clear`
- Source page: `scriptnode_enrichment/output/math/clear.md`

## Scenario

- Title: Empty split branch filler
- Project context: A `container.split` creates one dry branch and one branch that should contribute only a separately generated layer. `math.clear` is placed at the start of the secondary branch so the original input does not leak into it before that branch adds its own signal.
- Teaching goal: Demonstrate how `math.clear` intentionally erases inherited signal in a branch so that downstream processing starts from silence.

## Support Nodes

- Required: [`container.split`, `core.oscillator`]
- Optional: [`core.gain`]
- Rationale: `container.split` makes the branch topology explicit, and a simple oscillator on the cleared branch shows why wiping the inherited signal is useful before adding a new layer.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The example should clearly show that `math.clear` is not just a mute at the end of a chain, but a branch-initializer inside a split topology.
- The non-cleared dry branch and the cleared replacement branch should stay visually distinct.
- Keep the replacement layer simple so the purpose of the clear node remains the main lesson.
