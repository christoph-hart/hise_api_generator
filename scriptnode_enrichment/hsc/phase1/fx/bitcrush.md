# fx.bitcrush - HSC Scenario

## Node

- Factory path: `fx.bitcrush`
- Source page: `scriptnode_enrichment/output/fx/bitcrush.md`

## Scenario

- Title: Crushed feedback delay
- Project context: A lo-fi echo should degrade more on each repeat instead of crushing only the direct signal once. `fx.bitcrush` is inserted inside a feedback delay path so every echo pass loses amplitude resolution and becomes progressively more digital.
- Teaching goal: Demonstrate `fx.bitcrush` as a feedback-path colour stage and show why Bipolar mode is usually the safer choice for modulated or repeated signals.

## Support Nodes

- Required: [`template.feedback_delay`]
- Optional: [`filters.one_pole`, `core.gain`]
- Rationale: The feedback delay template provides the safe fixed-block send/receive loop, and the bitcrusher can be inserted between the delay and feedback send. Optional filtering or gain can shape the feedback character without distracting from the target node.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use `template.feedback_delay` instead of hand-building send/receive unless live CLI exposes a template limitation.
- Keep feedback below unity and document that the template's fixed block context is required for predictable feedback timing.
- Set `fx.bitcrush.Mode` to Bipolar for the public example unless the scenario explicitly wants DC bias.
- Expose a narrowed `Bits` macro, for example the musically audible lower range rather than the transparent 16-bit default.
