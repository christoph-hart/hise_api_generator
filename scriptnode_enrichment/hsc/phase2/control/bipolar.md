# control.bipolar - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/bipolar.md`
- Reference: `scriptnode_enrichment/output/control/bipolar.md`

## Naming

- Module ID: `CentrePreservingVibrato`
- Network ID: `centre_preserving_vibrato`

## Graph Plan

```text
centre_preserving_vibrato
  VibratoControl         container.modchain
    MidiIsolation        container.no_midi
      TriangleLfo        core.oscillator
      Normalise          math.sig2mod
      LfoPeak            core.peak
    SymmetricDepth       control.bipolar
  SawTone                core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Verify fractional values after narrowing `SawTone.Freq Ratio`.
- Channel/routing setup:
  - Required channels: default stereo; LFO uses isolated mono control processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI blocked only for fixed-rate LFO]

## Public Parameters

- VibratoDepth -> `SymmetricDepth.Scale` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.5`

## Defaults To Omit

- `Normalise.Value` default `0.0`
- `LfoPeak.Value` default `0.0`
- `SymmetricDepth.Scale` default `0.0`
- `SymmetricDepth.Gamma` default `1.0`

## Locked Build Values

- `TriangleLfo.Mode` = `Triangle`
- `TriangleLfo.Frequency` range = `[0.5, 8]`
- `TriangleLfo.Frequency` = `5`
- `TriangleLfo.Gate` = `On`
- `LfoPeak` output -> `SymmetricDepth.Value` raw connection over `[0, 1]`
- `SymmetricDepth.Gamma` = `1.0`
- `SymmetricDepth` output -> `SawTone.Freq Ratio` range = `[0.988514, 1.011619]`, midpoint `1.0`
- `SawTone.Mode` = `Saw`
- `SawTone.Gate` = `On`

## Friction Comments To Weave In

- Before `MidiIsolation`: note events must not retune the fixed-rate triangle LFO.
- Before `SymmetricDepth`: Scale zero outputs 0.5, which maps to the neutral ratio 1.0 rather than shifting pitch.
- Before the target connection: narrow the oscillator ratio to the musically meaningful continuous interval `[0.988514, 1.011619]`, representing -20 to +20 cents around midpoint `1.0`.

## Cosmetic Plan

- Main node: `SymmetricDepth`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`TriangleLfo`, `LfoPeak`, `SawTone`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`MidiIsolation`, `Normalise`]
- Nodes that must stay visible: [`SymmetricDepth`, `TriangleLfo`, `LfoPeak`, `SawTone`]

## Open Questions

- None
