# dynamics.comp - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/comp.md`
- Reference: `scriptnode_enrichment/output/dynamics/comp.md`

## Naming

- Module ID: `SidechainDucker`
- Network ID: `sidechain_ducker`

## Graph Plan

```text
sidechain_ducker
  SidechainHost         container.sidechain
    PairView            container.multi
      ProgramPair       container.chain
      SidechainPair     container.chain
        DetectorClear   math.clear
        PumpRamp        core.ramp
    DuckComp            dynamics.comp
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: four internal channels inside `SidechainHost`; channels 0-1 stay the program pair and channels 2-3 become the synthetic detector pair
  - Module routing: default stereo
  - Master routing: default
  - Channel-specific comments needed: [sidechain wrapper duplicates stereo into two internal pairs, `container.multi` only exposes the pairs visually, sidechain pair audio is intentionally cleared and replaced with a ramp]

## Public Parameters

- DuckThreshold -> `DuckComp.Threshhold` matched
- Target range before connection: `[-36, -12]`
- Macro range: `[-36, -12]`
- Default: `-24`
- DuckRelease -> `DuckComp.Release` matched
- Target range before connection: `[40, 220]`
- Macro range: `[40, 220]`
- Default: `140`
- DuckRatio -> `DuckComp.Ratio` matched
- Target range before connection: `[2, 12]`
- Macro range: `[2, 12]`
- Default: `6`
- PumpTime -> `PumpRamp.PeriodTime` matched
- Target range before connection: `[250, 4000]`
- Macro range: `[250, 4000]`
- Default: `1000`

## Defaults To Omit

- `DuckComp.Attack` default `50`
- `DetectorClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SidechainHost`: `container.sidechain` duplicates the stereo source into a 4-channel buffer so the compressor can separate program and detector pairs.
- Before `PairView`: `container.multi` is only there to expose the two stereo pairs visually; `dynamics.comp` still processes the full 4-channel stream.
- Before `DetectorClear`: clear the duplicated detector pair first so it no longer follows the source audio.
- Before `PumpRamp`: replace the detector pair with an artificial ramp so the pumping is obvious and independent from the source material; `PumpTime` controls the ramp period directly.
- Before `set DuckComp.Sidechain`: set the mode to `Sidechain`; `Disabled` and `Original` collapse this into ordinary self-keyed compression.

## Cosmetic Plan

- Main node: `DuckComp`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`SidechainHost`, `PairView`, `DetectorClear`, `PumpRamp`]
- Supporting colour: `0xFF8F7766`
- Folded nodes: [`ProgramPair`, `DetectorClear`]
- Nodes that must stay visible: [`SidechainHost`, `PairView`, `SidechainPair`, `PumpRamp`, `DuckComp`]

## Open Questions

- None
