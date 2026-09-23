# container.sidechain - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/sidechain.md`
- Reference: `scriptnode_enrichment/output/container/sidechain.md`

## Naming

- Module ID: `InternallyKeyedPumpingCompressor`
- Network ID: `internally_keyed_pumping_compressor`

## Graph Plan

```text
internally_keyed_pumping_compressor
  InternalSidechain      container.sidechain
    FourChannelSlices    container.multi
      MainStereo         container.chain
      KeyStereo          container.no_midi
        PumpOscillator   core.oscillator
    PumpCompressor       dynamics.comp
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None; the sidechain container creates and consumes the internal auxiliary pair.
- Channel/routing setup:
  - Required channels: default stereo externally, expanded to four channels inside `InternalSidechain`
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [channels 0-1 main audio, channels 2-3 generated key, auxiliary pair discarded on exit]

## Public Parameters

- PumpRate -> `PumpOscillator.Frequency` matched
- Target range before connection: `[0.5, 8]`
- Macro range: `[0.5, 8]`
- Default: `2`

## Defaults To Omit

- `PumpOscillator.Gain` default `1.0`
- `PumpCompressor.Attack` default `20`
- `PumpCompressor.Release` default `50`

## Locked Build Values

- `FourChannelSlices` has exactly two stereo children.
- `MainStereo` is intentionally empty and passes channels 0-1 unchanged.
- `KeyStereo` receives channels 2-3, which begin zeroed.
- `PumpOscillator.Mode` = `Sine`
- `PumpOscillator.Frequency` range = `[0.5, 8]`
- `PumpOscillator.Gate` = `On`
- `PumpCompressor.Sidechain` = `Sidechain`
- `PumpCompressor.Threshold` = `-24`
- `PumpCompressor.Ratio` = `8`
- `PumpCompressor.Attack` = `5`
- `PumpCompressor.Release` = `180`

## Friction Comments To Weave In

- Before `InternalSidechain`: the node appends zeroed auxiliary channels internally; it does not connect a DAW sidechain input.
- Before `MainStereo`: this branch is intentionally empty so the original pair reaches the compressor unchanged.
- Before `KeyStereo`: the oscillator explicitly fills the otherwise silent auxiliary pair, and no_midi prevents note retuning.
- Before `PumpCompressor`: Sidechain mode detects channels 2-3 while applying gain reduction only to channels 0-1.

## Cosmetic Plan

- Main node: `InternalSidechain`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`FourChannelSlices`, `KeyStereo`, `PumpOscillator`, `PumpCompressor`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: [`MainStereo`]
- Nodes that must stay visible: [`InternalSidechain`, `FourChannelSlices`, `KeyStereo`, `PumpOscillator`, `PumpCompressor`]

## Open Questions

- None
