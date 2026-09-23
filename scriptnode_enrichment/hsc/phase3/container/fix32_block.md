# container.fix32_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix32_block.md`
- Reference: `scriptnode_enrichment/output/container/fix32_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as an internally keyed TrackSpacer-style dynamic mid-cut. The separate key slice is analysed before a peak EQ processes the main signal at a 32-sample cadence.

## Naming

- Module ID: `SidechainDynamicMidCut`
- Network ID: `sidechain_dynamic_mid_cut`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Injected deterministic stereo noise as the main test signal.
  - Generated a separate slow sine key on the internal auxiliary pair.
  - Kept the main branch intentionally empty so channels 0-1 pass unchanged into the EQ.
  - Placed the EQ after channel slicing so key analysis finishes before each EQ chunk.
- Channel/routing setup verified:
  - Required channels: `default stereo externally; four channels inside InternalSidechain`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `sidechain_dynamic_mid_cut.MaxCut` = `-9` range `-18..0` stepSize `0.1`
- `KeyOscillator.Frequency` = `2` range `0.5..8`
- `KeyOscillator.Mode` = `0` (`Sine`)
- `KeyOscillator.Gate` = `1`
- `KeyFollower.Attack` = `10` ms
- `KeyFollower.Release` = `150` ms
- `KeyFollower.ProcessSignal` = `0`
- `CutDepthPMA.Multiply` range = `0..1`
- `CutDepthPMA.Add` = `0`
- `DynamicMidEQ.Mode` = `4` (`Peak`)
- `DynamicMidEQ.Frequency` = `1800` Hz
- `DynamicMidEQ.Q` = `2`
- `DynamicMidEQ.Gain` range = `0..-18` dB, stepSize `0.1`
- `DynamicMidEQ.Smoothing` = `0`

## Verified Connections

- `sidechain_dynamic_mid_cut.MaxCut` -> `CutDepthPMA.Value` unscaled: true
- `KeyFollower.0` -> `CutDepthPMA.Multiply` scaled: true
- `CutDepthPMA.0` -> `DynamicMidEQ.Gain` unscaled: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SidechainDynamicMidCut --container sidechain_dynamic_mid_cut --inject noise --gain 0.25 --seed 1234 --inject-param sidechain_dynamic_mid_cut.MaxCut=0 --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module SidechainDynamicMidCut --container sidechain_dynamic_mid_cut --inject noise --gain 0.25 --seed 1234 --inject-param sidechain_dynamic_mid_cut.MaxCut=-9 --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - With MaxCut `0`, `CutDepthPMA.Value=0`, follower Multiply was `0.9815`, and `DynamicMidEQ.Gain=0` exactly.
  - With MaxCut `-9`, follower Multiply was `0.5583` and EQ Gain was `-5.0243`, matching `-9 * 0.5583`.
- Signal trace commands:
  - Same recursive deterministic-noise commands as above.
- Signal trace evidence:
  - Root specs reported `sampleRate=48000`, `numChannels=2`, and `blockSize=512`.
  - `ThirtyTwoSampleDucker` reported `blockSize=32`.
  - `InternalSidechain` reported `numChannels=4` and `blockSize=32`.
  - `MainAudio` passed independent stereo noise with channel peaks `-0.2424` and `-0.2497` and valid peak indices `23` and `11`.
  - `KeyDetector` carried equal stereo key values on the auxiliary slice.
  - Only processed main channels 0-1 returned from `InternalSidechain`.
- Trace caveats:
  - This is an internally generated sidechain teaching fixture, not an external DAW sidechain input.
  - A final child chunk can be shorter than 32 samples.

## Locked Build Values Applied

- Maximum child chunk size = `32` samples
- ChannelSlices children = exactly `2` stereo slices
- Key frequency = `2 Hz`
- Follower timing = `10 ms` attack, `150 ms` release
- Peak EQ = `1800 Hz`, Q `2`, smoothing `0`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They exclude pipeline-only save and screenshot operations.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SidechainDynamicMidCut --agent
hise-cli builder set --module SidechainDynamicMidCut --network sidechain_dynamic_mid_cut --agent

# Thirty-two samples is the maximum child chunk size and is a practical envelope-follower cadence.
hise-cli dsp add --module SidechainDynamicMidCut --type container.fix32_block --id ThirtyTwoSampleDucker --agent
# This creates and later discards an internal auxiliary pair; it is not an external DAW sidechain input.
hise-cli dsp add --module SidechainDynamicMidCut --type container.sidechain --id InternalSidechain --parent ThirtyTwoSampleDucker --agent
hise-cli dsp add --module SidechainDynamicMidCut --type container.multi --id ChannelSlices --parent InternalSidechain --agent
# Intentionally empty: channels 0-1 pass unchanged into the dynamic EQ.
hise-cli dsp add --module SidechainDynamicMidCut --type container.chain --id MainAudio --parent ChannelSlices --agent
hise-cli dsp add --module SidechainDynamicMidCut --type container.no_midi --id KeyDetector --parent ChannelSlices --agent
hise-cli dsp add --module SidechainDynamicMidCut --type core.oscillator --id KeyOscillator --parent KeyDetector --agent
hise-cli dsp add --module SidechainDynamicMidCut --type dynamics.envelope_follower --id KeyFollower --parent KeyDetector --agent
# Value carries raw negative dB; Multiply receives the normalised follower amount.
hise-cli dsp add --module SidechainDynamicMidCut --type control.pma_unscaled --id CutDepthPMA --parent KeyDetector --agent
# Keep the EQ after ChannelSlices so key analysis completes before each EQ chunk.
hise-cli dsp add --module SidechainDynamicMidCut --type filters.svf_eq --id DynamicMidEQ --parent InternalSidechain --agent

hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param Frequency --range "0.5,8" --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param Frequency --value 2 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param Attack --value 10 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param Release --value 150 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param ProcessSignal --value 0 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param Multiply --range "0,1" --agent

hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Mode --value 4 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Frequency --value 1800 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Q --value 2 --agent
# EQ smoothing must remain zero so the follower and fixed-block cadence remain authoritative.
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Smoothing --value 0 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Gain --range "0,-18" --stepSize 0.1 --agent

hise-cli dsp create_parameter --module SidechainDynamicMidCut --container sidechain_dynamic_mid_cut --id MaxCut --range "-18,0" --default -9 --stepSize 0.1 --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source sidechain_dynamic_mid_cut --source-param MaxCut --target CutDepthPMA --param Value --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source KeyFollower --target CutDepthPMA --param Multiply --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source CutDepthPMA --target DynamicMidEQ --param Gain --agent

hise-cli dsp set --module SidechainDynamicMidCut --node ThirtyTwoSampleDucker --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SidechainDynamicMidCut --node ThirtyTwoSampleDucker --param Comment --value '"**Sidechain dynamic mid cut** - Thirty-two-sample chunks provide a practical envelope-follower cadence for frequency ducking."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node InternalSidechain --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node InternalSidechain --param Comment --value '"Creates an internal auxiliary pair for teaching; this is not an external DAW sidechain input."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node ChannelSlices --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param Comment --value '"Intentionally empty: channels 0-1 pass unchanged before the dynamic EQ."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyDetector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param Comment --value '"Multiplies raw negative MaxCut dB by the normalised key envelope."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Comment --value '"Placed after channel slicing so key analysis updates Gain before each EQ chunk; Smoothing remains zero."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module SidechainDynamicMidCut --agent
hise-cli dsp screenshot --module SidechainDynamicMidCut --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix32_block.png" --agent
```

## Comments To Preserve In HSC

- Before `ThirtyTwoSampleDucker`: Thirty-two samples is a maximum and a practical general-purpose follower cadence.
- Before `InternalSidechain`: The auxiliary pair is generated internally and discarded on exit.
- Before `MainAudio`: The empty branch intentionally passes main channels unchanged.
- Before `DynamicMidEQ`: Process the key slice first by placing the EQ after `ChannelSlices`.
- Before `CutDepthPMA`: Multiply normalised follower amount by raw negative MaxCut dB.
- Before EQ smoothing: Keep it zero so it does not conceal follower timing or chunk cadence.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/fix32_block.md`: Replaced the additive staircase with an internally sidechained dynamic mid-cut.
  - `scriptnode_enrichment/hsc/phase2/container/fix32_block.md`: Added final four-channel topology, PMA mapping, comments, and cosmetics.
- General rules promoted:
  - None
- Local-only findings:
  - An existing envelope-follower example already used a self-keyed dynamic EQ, so this example uses a separate internal key slice to avoid duplication.
  - An EQ placed after the multi container observes control updates produced by the key branch in the same chunk.

## Cosmetics Applied

- Main node: `ThirtyTwoSampleDucker` colour `0xFF2F80ED`
- Support nodes: [`InternalSidechain`, `ChannelSlices`, `MainAudio`, `KeyDetector`, `KeyOscillator`, `KeyFollower`, `CutDepthPMA`, `DynamicMidEQ`] colour `0xFF6F8FAF`
- Folded nodes: [`MainAudio`]
- Visible target nodes: [`ThirtyTwoSampleDucker`, `InternalSidechain`, `ChannelSlices`, `KeyDetector`, `KeyOscillator`, `KeyFollower`, `CutDepthPMA`, `DynamicMidEQ`]

## Defaults Omitted

- `KeyOscillator.Mode` default `Sine`
- `KeyOscillator.Gate` default `On`
- `KeyFollower.ProcessSignal` default `Off`
- `CutDepthPMA.Add` default `0`
- `DynamicMidEQ.Enabled` default `On`

## Open Issues

- None blocking this artifact.
