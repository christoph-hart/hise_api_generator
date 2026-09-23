# control.xfader - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/xfader.md`
- Reference: `scriptnode_enrichment/output/control/xfader.md`

## Naming

- Module ID: `ThreeWayEffectMorph`
- Network ID: `three_way_effect_morph`

## Graph Plan

```text
three_way_effect_morph
  MorphCoefficients      control.xfader
  EffectPaths            container.split
    DryPath              container.chain
      DryLevel           math.mul
    FilterPath           container.chain
      MorphFilter        filters.svf
      FilterLevel        math.mul
    SaturationPath       container.chain
      MorphSaturation    math.tanh
      SaturationLevel    math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; split copies identical input to all three paths
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [every parallel branch ends with its own coefficient multiplier]

## Public Parameters

- Morph -> `MorphCoefficients.Value` matched; target and macro range `[0, 1]`; default `0.5`

## Defaults To Omit

- `MorphCoefficients.Value` default `0.0`

## Locked Build Values

- `MorphCoefficients.NumParameters` property = `3`
- `MorphCoefficients.Mode` property = `RMS`
- Outputs 0, 1, 2 -> `DryLevel.Value`, `FilterLevel.Value`, `SaturationLevel.Value` matched `[0, 1]`
- `MorphFilter.Mode = LowPass`, Frequency = `1000`, Q = `0.7`, Smoothing = `0.02`
- `MorphSaturation.Value` = `0.65`
- Every branch's multiplier is its final child.

## Friction Comments To Weave In

- Before output connections: slot order is fixed as dry, filtered, saturated.
- Before branch layout: every path needs a final gain or it remains audible regardless of Morph.
- Before RMS mode: adjacent paths overlap with equal-power coefficients, but correlated material can still change perceived level.

## Cosmetic Plan

- Main node: `MorphCoefficients`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EffectPaths`, `MorphFilter`, `MorphSaturation`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`DryLevel`, `FilterLevel`, `SaturationLevel`]
- Nodes that must stay visible: [`MorphCoefficients`, `EffectPaths`, `MorphFilter`, `MorphSaturation`]

## Open Questions

- None
