# envelope.global_mod_gate - HSC Scenario

## Node

- Factory path: `envelope.global_mod_gate`
- Source page: `scriptnode_enrichment/output/envelope/global_mod_gate.md`

## Scenario

- Title: Global envelope voice cleanup
- Project context: A custom control-signal network uses a GlobalModulatorContainer envelope as the shared contour for several synchronized sound generators. The scriptnode graph reads the continuous global modulator value elsewhere, but needs a matching gate signal to stop each voice when that global envelope has released.
- Teaching goal: Demonstrate how `envelope.global_mod_gate` turns the selected global modulator's per-voice active state into a binary Gate signal for `envelope.voice_manager`.

## Support Nodes

- Required: [`core.global_mod`, `envelope.voice_manager`]
- Optional: [`math.fill1`]
- Rationale: `core.global_mod` is the continuous-value companion that makes the shared global envelope context concrete. `envelope.voice_manager` consumes the binary gate and performs the actual voice reset.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Add a `GlobalModulatorContainer` with one `AHDSR` before building the scriptnode graph, then keep both nodes on index `0` so they bind to that first envelope.
- Avoid non-envelope global modulators because their gate state remains active and would not demonstrate release-based cleanup.
