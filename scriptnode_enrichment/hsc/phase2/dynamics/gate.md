# dynamics.gate - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/gate.md`
- Reference: `scriptnode_enrichment/output/dynamics/gate.md`

## Naming

- Module ID: `NoiseLayerGate`
- Network ID: `noise_layer_gate`

## Graph Plan

```text
noise_layer_gate
  TextureSplit          container.split
    DryPath             container.chain
      SelfGate          dynamics.gate
    NoisePath           container.chain
      NoiseClear        math.clear
      NoiseSource       core.oscillator
      NoiseFilter       filters.svf_eq
      NoiseGain         core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; both split branches stay stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [split-branch topology makes the dry source and gated noise layer visually distinct, noise branch input must be cleared before adding the synthetic layer]

## Public Parameters

- GateThreshold -> `SelfGate.Threshhold` matched
- Target range before connection: `[-48, -18]`
- Macro range: `[-48, -18]`
- Default: `-30`
- GateRelease -> `SelfGate.Release` matched
- Target range before connection: `[20, 160]`
- Macro range: `[20, 160]`
- Default: `80`
- GateDepth -> `SelfGate.Ratio` matched
- Target range before connection: `[4, 16]`
- Macro range: `[4, 16]`
- Default: `10`

## Defaults To Omit

- `SelfGate.Attack` default `50`
- `SelfGate.Sidechain` default `Disabled`
- `NoiseClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `TextureSplit`: keep the dry branch and the synthetic noise branch visually separate so the modulation target is obvious.
- Before `NoiseClear`: clear the inherited split signal first so the noise branch does not double the dry source.
- Before the modulation connection to `NoiseGain.Gain`: use the gate's output to control the texture layer depth instead of sidechain-routing the gate itself.
- Before `NoiseSource`: set the oscillator to noise, while noting that a looped file-player noise source would often be more production-friendly.

## Cosmetic Plan

- Main node: `SelfGate`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`TextureSplit`, `NoiseClear`, `NoiseSource`, `NoiseGain`]
- Supporting colour: `0xFF8F7766`
- Folded nodes: [`DryPath`]
- Nodes that must stay visible: [`TextureSplit`, `SelfGate`, `NoisePath`, `NoiseGain`]

## Open Questions

- None
