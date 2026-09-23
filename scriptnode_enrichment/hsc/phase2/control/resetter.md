# control.resetter - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/resetter.md`
- Reference: `scriptnode_enrichment/output/control/resetter.md`

## Naming

- Module ID: `ManualEnvelopeRetrigger`
- Network ID: `manual_envelope_retrigger`

## Graph Plan

```text
manual_envelope_retrigger
  RetriggerImpulse       control.resetter
  SustainedTone          core.oscillator
  RestartedEnvelope      envelope.simple_ar
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Implement Retrigger as an alternating value so every press changes the input.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Retrigger -> `RetriggerImpulse.Value` matched; range `[0, 1]`, alternating trigger; default `0`

## Defaults To Omit

- `RetriggerImpulse.Value` default `0.0`

## Locked Build Values

- `SustainedTone.Mode = Saw`, Frequency = `220`, Gain = `0.2`, Gate = `On`
- `RestartedEnvelope.Attack` = `300`
- `RestartedEnvelope.Release` = `800`
- `RetriggerImpulse` output -> `RestartedEnvelope.Gate` matched `[0, 1]`
- Audio order = `SustainedTone`, `RestartedEnvelope`

## Friction Comments To Weave In

- Before Retrigger: input magnitude is ignored; each change emits immediate zero then one.
- Before `RestartedEnvelope`: the fixed pair forces a rising edge even while Gate is already high.
- Before description: this is synchronous retriggering, not a configurable pulse-width generator.

## Cosmetic Plan

- Main node: `RetriggerImpulse`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SustainedTone`, `RestartedEnvelope`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`RetriggerImpulse`, `SustainedTone`, `RestartedEnvelope`]

## Open Questions

- None
