# envelope.flex_ahdsr - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/flex_ahdsr.md`
- Reference: `scriptnode_enrichment/output/envelope/flex_ahdsr.md`

## Naming

- Module ID: `ScriptEnvelopeFlexAhdsr`
- Network ID: `script_envelope_flex_ahdsr`

## Graph Plan

```text
script_envelope_flex_ahdsr
  EnvelopeSeed          math.fill1
  FlexEnvelope          envelope.flex_ahdsr
  VoiceKill             envelope.voice_manager
```

## Builder Setup

- Host context: `Script Envelope`
- Additional builder steps:
  - Create a HISE Script Envelope module and build this network inside it.
- Channel/routing setup:
  - Required channels: default stereo inside the Script Envelope; the graph carries a duplicated modulation signal rather than audio processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [Script Envelope control-signal graph, gate output used for lifecycle control]

## Public Parameters

- Mode -> `FlexEnvelope.Mode` matched
- Target range before connection: `[Trigger, Note, Loop]`
- Macro range: `[Trigger, Note, Loop]`
- Default: `Note`
- Attack -> `FlexEnvelope.Attack` matched
- Target range before connection: `[1, 250]`
- Macro range: `[1, 250]`
- Default: `5`
- Decay -> `FlexEnvelope.Decay` matched
- Target range before connection: `[20, 800]`
- Macro range: `[20, 800]`
- Default: `100`
- Sustain -> `FlexEnvelope.Sustain` matched
- Target range before connection: `[0.2, 0.9]`
- Macro range: `[0.2, 0.9]`
- Default: `0.5`
- Release -> `FlexEnvelope.Release` matched
- Target range before connection: `[40, 1200]`
- Macro range: `[40, 1200]`
- Default: `300`

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`
- `FlexEnvelope.Hold` default `0.0`
- `FlexEnvelope.AttackLevel` default `1.0`
- `FlexEnvelope.AttackCurve` default `0.5`
- `FlexEnvelope.DecayCurve` default `0.5`
- `FlexEnvelope.ReleaseCurve` default `0.5`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `EnvelopeSeed`: this stays in a Script Envelope context, not a free-running audio patch.
- Before `create_parameter Mode`: expose mode as a direct raw enum so users can compare Trigger, Note, and Loop without rebuilding the network.
- Before the parameter setup notes: avoid realtime modulation-slot automation of flex envelope parameters because the reference page calls out deferred/update limitations.

## Cosmetic Plan

- Main node: `FlexEnvelope`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EnvelopeSeed`, `VoiceKill`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`EnvelopeSeed`, `FlexEnvelope`, `VoiceKill`]

## Open Questions

- None
