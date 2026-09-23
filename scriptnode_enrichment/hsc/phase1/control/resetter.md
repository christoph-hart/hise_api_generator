# control.resetter - HSC Scenario

## Node

- Factory path: `control.resetter`
- Source page: `scriptnode_enrichment/output/control/resetter.md`

## Scenario

- Title: Manual Envelope Retrigger
- Project context: A continuously gated tone uses a public Retrigger control to restart its attack without first requiring the user to turn the gate off. `control.resetter` forces a zero-then-one transition into a simple AR envelope on every input change.
- Teaching goal: Demonstrate the fixed impulse pair and show that the Value input acts only as a change trigger.

## Support Nodes

- Required: [`core.oscillator`, `envelope.simple_ar`]
- Optional: []
- Rationale: `core.oscillator` supplies a sustained tone, and `envelope.simple_ar` provides a gate-sensitive attack that audibly restarts when it receives the resetter's immediate 0-to-1 pair.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Order the audible chain as oscillator then simple AR, leave oscillator Gate on, and connect resetter output to `envelope.simple_ar.Gate`.
- Drive resetter Value from an alternating public Retrigger control so every action changes the input parameter.
- Choose an audible Attack and a long enough Release to make a forced restart obvious while the target gate was already high.
- Verify every Value change sends 0 immediately followed by 1 and that input magnitude does not alter the impulse.
- Do not describe the node as a pulse-width generator; both values are emitted synchronously with no configurable interval.
- The simple AR sustains at full level and has no adjustable sustain parameter.
