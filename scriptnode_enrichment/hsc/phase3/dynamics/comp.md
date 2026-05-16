# dynamics.comp - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/dynamics/comp.md`
- Reference: `scriptnode_enrichment/output/dynamics/comp.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved for Phase 4 conversion. The live build demonstrates external sidechain compression by using `container.sidechain` to create a four-channel internal layout, replacing detector channels 2-3 with a synthetic ramp, and setting `DuckComp.Sidechain` to `Sidechain`.
- Phase 2 deviation: removed `TimingBlock` because `dynamics.comp` does not need fixed-block processing for ordinary sidechain compression. Fixed-block containers only matter here if the compressor modulation output drives another downstream parameter. Also changed `PumpRate -> PumpRamp.Frequency` to `PumpTime -> PumpRamp.PeriodTime`, because current `core.ramp` exposes `PeriodTime`, not `Frequency`.

## Naming

- Module ID: `SidechainDucker`
- Network ID: `sidechain_ducker`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `default stereo externally; four internal channels inside SidechainHost`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `DuckComp.Threshhold` = `-24` range `-36..-12` stepSize `0.1`
- `DuckComp.Release` = `140` range `40..220` stepSize `0.1`
- `DuckComp.Ratio` = `6` range `2..12` stepSize `0.1`
- `DuckComp.Sidechain` = `2` range `0..2` stepSize `1`
- `PumpRamp.PeriodTime` = `1000` range `250..4000` stepSize `1`
- `sidechain_ducker.DuckThreshold` = `-24` range `-36..-12` stepSize `0.1`
- `sidechain_ducker.DuckRelease` = `140` range `40..220` stepSize `0.1`
- `sidechain_ducker.DuckRatio` = `6` range `2..12` stepSize `0.1`
- `sidechain_ducker.PumpTime` = `1000` range `250..4000` stepSize `1`

## Verified Connections

- `sidechain_ducker.DuckThreshold` -> `DuckComp.Threshhold` matched: true
- `sidechain_ducker.DuckRelease` -> `DuckComp.Release` matched: true
- `sidechain_ducker.DuckRatio` -> `DuckComp.Ratio` matched: true
- `sidechain_ducker.PumpTime` -> `PumpRamp.PeriodTime` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SidechainDucker --container sidechain_ducker --inject-param sidechain_ducker.DuckThreshold=-18 --inject-param sidechain_ducker.DuckRelease=200 --inject-param sidechain_ducker.DuckRatio=10 --inject-param sidechain_ducker.PumpTime=500 --probe-param DuckComp.Threshhold --probe-param DuckComp.Release --probe-param DuckComp.Ratio --probe-param PumpRamp.PeriodTime --trace-compact --agent`
- Parameter trace evidence:
  - `DuckComp.Threshhold` probed as `-18`, `DuckComp.Release` as `200`, `DuckComp.Ratio` as `10`, and `PumpRamp.PeriodTime` as `500`; all matched injected root control values.
- Signal trace commands:
  - `hise-cli dsp trace --module SidechainDucker --container sidechain_ducker --inject noise --gain 0.5 --seed 1234 --probe-recursive --probe-param DuckComp.Sidechain --trace-compact --agent`
- Signal trace evidence:
  - `SidechainHost` changed the internal context to `numChannels=4` while root input/output remained stereo.
  - `PairView` exposed program channels 0-1 at about `-0.4995..0.4995` and detector channels 2-3 at about `0.5467` after `PumpRamp`.
  - `DetectorClear` silenced the duplicated detector pair before `PumpRamp` replaced it.
  - `DuckComp.Sidechain` probed as `2`; `DuckComp` processed the four-channel stream and attenuated the program pair to about `-0.0923..-0.0927` in the traced block.
- Trace caveats:
  - The compressor's internal sidechain compression is not the same as exported modulation-to-parameter timing. No fixed-block container is needed because this example does not route `DuckComp` modulation output to another target.
  - `container.sidechain` returns only the original external channel count after its children process the four-channel internal layout.
  - `core.ramp` adds its ramp value to the detector audio channels, so `DetectorClear` must run before it to prevent source audio from leaking into the sidechain key.

## Locked Build Values Applied

- None from Phase 2.

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SidechainDucker --agent
hise-cli builder set --module SidechainDucker --network sidechain_ducker --agent

hise-cli dsp add --module SidechainDucker --type container.sidechain --id SidechainHost --agent
hise-cli dsp add --module SidechainDucker --type container.multi --id PairView --parent SidechainHost --agent
hise-cli dsp add --module SidechainDucker --type container.chain --id ProgramPair --parent PairView --agent
hise-cli dsp add --module SidechainDucker --type container.chain --id SidechainPair --parent PairView --agent
hise-cli dsp add --module SidechainDucker --type math.clear --id DetectorClear --parent SidechainPair --agent
hise-cli dsp add --module SidechainDucker --type core.ramp --id PumpRamp --parent SidechainPair --agent
hise-cli dsp add --module SidechainDucker --type dynamics.comp --id DuckComp --parent SidechainHost --agent

hise-cli dsp set --module SidechainDucker --node PumpRamp --param PeriodTime --range "250,4000" --stepSize 1 --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Sidechain --value 2 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Threshhold --range "-36,-12" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Threshhold --value -24 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Release --range "40,220" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Release --value 140 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Ratio --range "2,12" --stepSize 0.1 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Ratio --value 6 --agent

hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckThreshold --range "-36,-12" --default -24 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckRelease --range "40,220" --default 140 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id DuckRatio --range "2,12" --default 6 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SidechainDucker --container sidechain_ducker --id PumpTime --range "250,4000" --default 1000 --stepSize 1 --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckThreshold --target DuckComp --param Threshhold --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckRelease --target DuckComp --param Release --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param DuckRatio --target DuckComp --param Ratio --matched --agent
hise-cli dsp connect --module SidechainDucker --source sidechain_ducker --source-param PumpTime --target PumpRamp --param PeriodTime --matched --agent

hise-cli dsp set --module SidechainDucker --node DuckComp --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SidechainDucker --node DuckComp --param Comment --value '"**Sidechain compressor** - DuckComp listens to the synthetic detector pair while compressing the program pair."' --agent
hise-cli dsp set --module SidechainDucker --node SidechainHost --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node SidechainHost --param Comment --value '"SidechainHost expands stereo into four internal channels: program 0-1 and detector 2-3."' --agent
hise-cli dsp set --module SidechainDucker --node PairView --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node PairView --param Comment --value '"PairView exposes the two stereo pairs before DuckComp processes the full four-channel stream."' --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param Comment --value '"Clear the duplicated detector pair before replacing it with the synthetic pump ramp."' --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SidechainDucker --node PumpRamp --param Comment --value '"Pump time controls the ramp period for wider ducking cycles."' --agent
hise-cli dsp set --module SidechainDucker --node ProgramPair --param Folded --value true --agent
hise-cli dsp set --module SidechainDucker --node DetectorClear --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module SidechainDucker --agent
hise-cli dsp screenshot --module SidechainDucker --scale 200% --output "scriptnode_enrichment/hsc/phase5/dynamics/comp.png" --agent
```

## Comments To Preserve In HSC

- Before `SidechainHost`: `container.sidechain` expands stereo into an internal four-channel layout so `DuckComp` can use channels 2-3 as its detector pair.
- Before `PairView`: `container.multi` exposes the program and detector stereo pairs visually; it is not a dry/wet split.
- Before `DetectorClear`: clear the duplicated detector pair first so the detector no longer follows the source audio.
- Before `PumpRamp`: replace the detector pair with an artificial ramp; `PumpTime` controls the ramp period directly.
- Before `DuckComp.Sidechain`: set sidechain mode to `Sidechain`; `Disabled` and `Original` collapse the example into ordinary self-keyed compression.
- Before cosmetics: do not fold `SidechainPair`, because folding it would hide the visible `PumpRamp` detector source.

## Cosmetics Applied

- Main node: `DuckComp` colour `0xFFE67E22`
- Support nodes: [`SidechainHost`, `PairView`, `DetectorClear`, `PumpRamp`] colour `0xFF8F7766`
- Folded nodes: [`ProgramPair`, `DetectorClear`]
- Visible target nodes: [`SidechainHost`, `PairView`, `SidechainPair`, `PumpRamp`, `DuckComp`]

## Defaults Omitted

- `DuckComp.Attack` default `50`
- `DetectorClear.Value` default `0.0`
- `PumpRamp.LoopStart` default `0`
- `PumpRamp.Gate` default `On`

## Open Issues

- None
