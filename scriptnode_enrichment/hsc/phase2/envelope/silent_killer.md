# envelope.silent_killer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/silent_killer.md`
- Reference: `scriptnode_enrichment/output/envelope/silent_killer.md`

## Naming

- Module ID: `SilentEnvelopeCleanup`
- Network ID: `silent_envelope_cleanup`

## Graph Plan

```text
silent_envelope_cleanup
  EnvelopeSeed          math.fill1
  ReleaseEnvelope       envelope.simple_ar
  SilentCleanup         envelope.silent_killer
```

## Builder Setup

- Host context: `Script Envelope`
- Additional builder steps:
  - Create a HISE Script Envelope module and build this network inside it.
- Channel/routing setup:
  - Required channels: default stereo inside the Script Envelope; the node watches a duplicated control signal rather than an audible audio path
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [silence detection is applied to a control/modulation signal, not a conventional audio branch]

## Public Parameters

- CleanupActive -> `SilentCleanup.Active` matched
- Target range before connection: `[Off, On]`
- Macro range: `[Off, On]`
- Default: `On`

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`
- `SilentCleanup.Threshold` default `-100.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SilentCleanup`: make sure the monitored modulation path actually decays to digital silence after note-off or the node never fires.
- Before the parameter notes: keep `Active` public, but note that `Threshold` is stored yet ignored by the current implementation.
- Before the comparison note: mention that `envelope.voice_manager` is the preferred option when a real gate signal is available.

## Cosmetic Plan

- Main node: `SilentCleanup`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EnvelopeSeed`, `ReleaseEnvelope`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`EnvelopeSeed`, `ReleaseEnvelope`, `SilentCleanup`]

## Open Questions

- None
