# fx.pitch_shift - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/pitch_shift.md`
- Reference: `scriptnode_enrichment/output/fx/pitch_shift.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a ScriptFX.

## Naming
- Module ID: `MicroshiftDoubler`
- Network ID: `microshift_doubler`

## Builder Setup Applied
- Host context: `Script FX`
- Additional builder steps applied: kept the time-stretch node in the default block path.
- Channel/routing setup verified: default stereo routing.

## Verified Parameters
- `MicroPitch.FreqRatio` = `1.015`, range `[0.96, 1.04]`
- `ShiftMix.DryWet` = `0.35`

## Verified Connections
- `microshift_doubler.Mix -> ShiftMix.DryWet` matched
- `microshift_doubler.Ratio -> MicroPitch.FreqRatio` matched

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MicroshiftDoubler --agent
hise-cli builder set --module MicroshiftDoubler --network microshift_doubler --agent
hise-cli dsp add --module MicroshiftDoubler --type template.dry_wet --id ShiftMix --agent
hise-cli dsp add --module MicroshiftDoubler --type fx.pitch_shift --id MicroPitch --parent ShiftMix_wet_path --agent
hise-cli dsp add --module MicroshiftDoubler --type core.gain --id WetTrim --parent ShiftMix_wet_path --agent
hise-cli dsp remove --module MicroshiftDoubler --node ShiftMix_dummy --agent
hise-cli dsp set --module MicroshiftDoubler --node MicroPitch --param FreqRatio --range "0.96,1.04" --agent
hise-cli dsp set --module MicroshiftDoubler --node MicroPitch --param FreqRatio --value 1.015 --agent
hise-cli dsp set --module MicroshiftDoubler --node ShiftMix --param DryWet --value 0.35 --agent
hise-cli dsp create_parameter --module MicroshiftDoubler --container microshift_doubler --id Mix --range "0,1" --default 0.35 --agent
hise-cli dsp create_parameter --module MicroshiftDoubler --container microshift_doubler --id Ratio --range "0.96,1.04" --default 1.015 --agent
hise-cli dsp connect --module MicroshiftDoubler --source microshift_doubler --source-param Mix --target ShiftMix --param DryWet --matched --agent
hise-cli dsp connect --module MicroshiftDoubler --source microshift_doubler --source-param Ratio --target MicroPitch --param FreqRatio --matched --agent
```

## Key rules
- Keep the pitch shifter in block processing; do not place it in a frame container.
- Narrow FreqRatio around `1.0` for microshift rather than exposing the full pitch range.
- Expect inherent processing latency.
