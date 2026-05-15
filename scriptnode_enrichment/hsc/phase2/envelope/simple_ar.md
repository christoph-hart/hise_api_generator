# envelope.simple_ar - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/simple_ar.md`
- Reference: `scriptnode_enrichment/output/envelope/simple_ar.md`

## Naming

- Module ID: `TimerGatedArModulator`
- Network ID: `timer_gated_ar_modulator`

## Graph Plan

```text
timer_gated_ar_modulator
  InternalModHost       container.mod_chain
    PulseTimer          control.timer
    EnvelopeSeed        math.fill1
    ArEnvelope          envelope.simple_ar
  ModTarget             core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Create a monophonic Script FX module before building the graph.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic Script FX; the mod chain generates a hidden control signal, while `ModTarget` stays on the audible stereo path
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [mod-chain topology is intentional because the envelope is used as internal DSP modulation rather than as a MIDI envelope]

## Public Parameters

- Attack -> `ArEnvelope.Attack` matched
- Target range before connection: `[1, 150]`
- Macro range: `[1, 150]`
- Default: `10`
- Release -> `ArEnvelope.Release` matched
- Target range before connection: `[20, 400]`
- Macro range: `[20, 400]`
- Default: `120`
- AttackCurve -> `ArEnvelope.AttackCurve` matched
- Target range before connection: `[0.0, 1.0]`
- Macro range: `[0.0, 1.0]`
- Default: `0.0`
- PulseRate -> `PulseTimer.Frequency` matched
- Target range before connection: `[0.5, 8.0]`
- Macro range: `[0.5, 8.0]`
- Default: `2.0`

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`
- `ArEnvelope.Gate` default `Off`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `InternalModHost`: keep this as a monophonic Script FX modulation example, not a Script Envelope module.
- Before the modulation connection to `ArEnvelope.Gate`: the timer is driving the manual gate input, which is the core point of this example.
- Before the modulation connection to `ModTarget.Gain`: place the gain node outside `container.mod_chain`, because the mod-chain signal is hidden control data and does not process the audible path by itself.
- Before the parameter notes: sustain is fixed at 1.0 here, so avoid layering AHDSR-style controls onto the example.

## Cosmetic Plan

- Main node: `ArEnvelope`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`InternalModHost`, `PulseTimer`, `EnvelopeSeed`, `ModTarget`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`InternalModHost`, `PulseTimer`, `EnvelopeSeed`, `ArEnvelope`, `ModTarget`]

## Open Questions

- None
