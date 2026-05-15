# math.fill1 - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/fill1.md`
- Reference: `scriptnode_enrichment/output/math/fill1.md`

## Naming

- Module ID: `EnvelopeSeedSource`
- Network ID: `envelope_seed_source`

## Graph Plan

```text
envelope_seed_source
  EnvelopeSeed          math.fill1
  ShapeEnvelope         envelope.simple_ar
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script Envelope`
- Additional builder steps:
  - Create a HISE Script Envelope module and build this control-signal network inside it.
- Channel/routing setup:
  - Required channels: default stereo inside the Script Envelope; the signal is a duplicated control-rate style DC source
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [control-signal example living on normal stereo lanes]

## Public Parameters

- Release -> `ShapeEnvelope.Release` matched
- Target range before connection: `[40, 500]`
- Macro range: `[40, 500]`
- Default: `180`

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `EnvelopeSeed`: `math.fill1` replaces any incoming signal with a constant 1.0 source, so frame the patch as a custom-envelope seed rather than as audio synthesis.

## Cosmetic Plan

- Main node: `EnvelopeSeed`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`ShapeEnvelope`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`EnvelopeSeed`, `ShapeEnvelope`]

## Open Questions

- None
