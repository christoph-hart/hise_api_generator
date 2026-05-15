# envelope.simple_ar - HSC Scenario

## Node

- Factory path: `envelope.simple_ar`
- Source page: `scriptnode_enrichment/output/envelope/simple_ar.md`

## Scenario

- Title: Timer-gated internal AR modulator
- Project context: A monophonic Script FX needs a small internal modulation pulse for a DSP parameter, independent of incoming MIDI notes. A `control.timer` periodically drives the `Gate` parameter of `envelope.simple_ar` inside a `container.mod_chain`, while `math.fill1` supplies the constant 1.0 signal that the envelope shapes.
- Teaching goal: Demonstrate how `envelope.simple_ar` can be used as a manually gated attack/release shaper for internal modulation inside a Script FX network.

## Support Nodes

- Required: [`container.mod_chain`, `math.fill1`, `control.timer`]
- Optional: [`core.gain`]
- Rationale: `container.mod_chain` demonstrates an internal modulation setup in a monophonic Script FX context. `control.timer` drives the manual Gate input, and `math.fill1` provides the static signal that becomes the AR-shaped modulation source.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build this as a monophonic Script FX example, not a Script Envelope module, to show internal DSP modulation with `container.mod_chain`.
- Drive `simple_ar.Gate` from `control.timer` so the example demonstrates non-MIDI triggering.
- Keep the audible gain target outside `container.mod_chain`, because the mod-chain signal is hidden control data and does not process the audio path by itself.
- The example should explicitly state that sustain is fixed at 1.0 and there is no Decay or Sustain parameter.
- Expose Attack, Release, AttackCurve, and timer rate only; adding AHDSR-style controls would blur the point of using this lightweight node.
