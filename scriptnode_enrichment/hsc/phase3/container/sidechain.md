# container.sidechain - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/sidechain.md`
- Reference: `scriptnode_enrichment/output/container/sidechain.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `InternallyKeyedPumpingCompressor`
- Network ID: `internally_keyed_pumping_compressor`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
internally_keyed_pumping_compressor
  InternalSidechain
    FourChannelSlices
      MainStereo
      KeyStereo
        PumpOscillator
    PumpCompressor
```

## Verified Configuration

- External context: stereo
- `InternalSidechain`: four internal channels
- `FourChannelSlices`: two children, each receiving two channels
- `MainStereo`: intentionally empty passthrough for channels 0-1
- `KeyStereo`: generated key on channels 2-3
- `PumpOscillator.Frequency`: `0.5..8 Hz`, default `2 Hz`
- `PumpCompressor.Sidechain` = `Sidechain`
- `PumpCompressor.Threshhold` = `-24 dB`
- `PumpCompressor.Ratio` = `8`
- `PumpCompressor.Attack` = `5 ms`
- `PumpCompressor.Release` = `180 ms`
- Root `PumpRate` -> `PumpOscillator.Frequency`, matched

## Trace Validation

A `0.25` stereo DC input verified:

- Main pair remained `[0.25, 0.25]` through the empty branch.
- The oscillator filled the auxiliary pair.
- The compressor reduced the returned main pair to approximately `[0.033, 0.033]`.
- Only the original stereo pair left `InternalSidechain`.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id InternallyKeyedPumpingCompressor --agent
hise-cli builder set --module InternallyKeyedPumpingCompressor --network internally_keyed_pumping_compressor --agent

# sidechain appends a zeroed auxiliary pair internally; it is not a DAW sidechain input.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.sidechain --id InternalSidechain --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.multi --id FourChannelSlices --parent InternalSidechain --agent
# The first stereo slice intentionally passes the program signal unchanged.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.chain --id MainStereo --parent FourChannelSlices --agent
# The second stereo slice fills the initially silent auxiliary channels.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.no_midi --id KeyStereo --parent FourChannelSlices --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type core.oscillator --id PumpOscillator --parent KeyStereo --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type dynamics.comp --id PumpCompressor --parent InternalSidechain --agent

hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param Frequency --range "0.5,8" --stepSize 0 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param Frequency --value 2 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Sidechain --value 2 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Threshhold --value -24 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Ratio --value 8 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Attack --value 5 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Release --value 180 --agent
hise-cli dsp create_parameter --module InternallyKeyedPumpingCompressor --container internally_keyed_pumping_compressor --id PumpRate --range "0.5,8" --default 2 --agent
hise-cli dsp connect --module InternallyKeyedPumpingCompressor --source internally_keyed_pumping_compressor --source-param PumpRate --target PumpOscillator --param Frequency --matched --agent

hise-cli dsp set --module InternallyKeyedPumpingCompressor --node InternalSidechain --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node InternalSidechain --param Comment --value '"Appends a zeroed stereo auxiliary pair internally; this is not a DAW sidechain input, and only channels 0-1 leave the container."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node FourChannelSlices --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node FourChannelSlices --param Comment --value '"The first child receives main channels 0-1; the second receives auxiliary channels 2-3."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node MainStereo --param Comment --value '"Intentionally empty so the original stereo pair reaches PumpCompressor unchanged."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node KeyStereo --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node KeyStereo --param Comment --value '"Generates the internal stereo key and blocks MIDI so notes cannot retune it."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Comment --value '"Sidechain mode detects channels 2-3 while applying gain reduction only to channels 0-1."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node MainStereo --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp trace --module InternallyKeyedPumpingCompressor --container internally_keyed_pumping_compressor --inject dc --gain 0.25 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp save --module InternallyKeyedPumpingCompressor --agent
hise-cli dsp screenshot --module InternallyKeyedPumpingCompressor --scale 200% --output "scriptnode_enrichment/hsc/output/container/sidechain.png" --agent
```

## Open Issues

- None.
