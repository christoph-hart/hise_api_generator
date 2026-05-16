# dynamics.envelope_follower - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/dynamics/envelope_follower.md`
- Reference: `scriptnode_enrichment/output/dynamics/envelope_follower.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved for Phase 4 conversion. The live build demonstrates `dynamics.envelope_follower` as a dynamic EQ control source: the follower analyses the incoming stereo signal without replacing it, `control.pma_unscaled` multiplies a raw dB depth value by the follower amount, and `filters.svf_eq` applies the resulting cut.
- Phase 2 deviation: inserted `CutDepthPMA` because `MidCutDepth` and `InputFollower` should not both directly drive `HarshBandEQ.Gain`. Changed `MidCutDepth` from direct EQ gain control to raw max-cut depth in dB (`-18..-3`) feeding `CutDepthPMA.Value`.

## Naming

- Module ID: `DynamicMidCut`
- Network ID: `dynamic_mid_cut`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `InputFollower.Attack` = `20` range `5..80` stepSize `0.1`
- `InputFollower.Release` = `120` range `40..300` stepSize `0.1`
- `InputFollower.ProcessSignal` = `0` range `0..1` stepSize `1`
- `CutDepthPMA.Value` = `0` unscaled input
- `CutDepthPMA.Multiply` = `1` range `0..1` stepSize `0.0001`
- `CutDepthPMA.Add` = `0`
- `HarshBandEQ.Mode` = `4` range `0..4` stepSize `1`
- `HarshBandEQ.Frequency` = `2500` range `20..20000`
- `HarshBandEQ.Q` = `2.5` range `0.3..9.9`
- `HarshBandEQ.Gain` = `0` range `0..-18` stepSize `0.1`
- `HarshBandEQ.Smoothing` = `0` range `0..1`
- `dynamic_mid_cut.FollowerAttack` = `20` range `5..80` stepSize `0.1`
- `dynamic_mid_cut.FollowerRelease` = `120` range `40..300` stepSize `0.1`
- `dynamic_mid_cut.MidCutDepth` = `-9` range `-18..-3` stepSize `0.1`

## Verified Connections

- `dynamic_mid_cut.FollowerAttack` -> `InputFollower.Attack` matched: true
- `dynamic_mid_cut.FollowerRelease` -> `InputFollower.Release` matched: true
- `dynamic_mid_cut.MidCutDepth` -> `CutDepthPMA.Value` matched: false, raw unscaled dB passthrough
- `InputFollower` -> `CutDepthPMA.Multiply` matched: false, follower `0..1` controls how much depth is applied
- `CutDepthPMA` -> `HarshBandEQ.Gain` matched: false, unscaled PMA output drives dB gain directly

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module DynamicMidCut --container dynamic_mid_cut --inject-param dynamic_mid_cut.FollowerAttack=40 --inject-param dynamic_mid_cut.FollowerRelease=240 --inject-param dynamic_mid_cut.MidCutDepth=-15 --probe-param InputFollower.Attack --probe-param InputFollower.Release --probe-param CutDepthPMA.Value --trace-compact --agent`
- Parameter trace evidence:
  - `InputFollower.Attack` probed as `40`, `InputFollower.Release` as `240`, and `CutDepthPMA.Value` as `-15`; `MidCutDepth` is passed as raw dB into the unscaled PMA value input.
- Signal trace commands:
  - `hise-cli dsp trace --module DynamicMidCut --container dynamic_mid_cut --inject silence --delay-ms 250 --probe-param CutDepthPMA.Value --probe-param CutDepthPMA.Multiply --probe-param HarshBandEQ.Gain --trace-compact --agent`
  - `hise-cli dsp trace --module DynamicMidCut --container dynamic_mid_cut --inject noise --gain 0.05 --seed 1234 --probe-param CutDepthPMA.Value --probe-param CutDepthPMA.Multiply --probe-param HarshBandEQ.Gain --trace-compact --agent`
  - `hise-cli dsp trace --module DynamicMidCut --container dynamic_mid_cut --inject noise --gain 1 --seed 1234 --probe-param CutDepthPMA.Value --probe-param CutDepthPMA.Multiply --probe-param HarshBandEQ.Gain --trace-compact --agent`
  - `hise-cli dsp trace --module DynamicMidCut --container dynamic_mid_cut --inject noise --gain 1 --seed 1234 --inject-param dynamic_mid_cut.MidCutDepth=-18 --probe-param CutDepthPMA.Value --probe-param CutDepthPMA.Multiply --probe-param HarshBandEQ.Gain --trace-compact --agent`
- Signal trace evidence:
  - Silence trace with `MidCutDepth=-9`: `CutDepthPMA.Value=-9`, `CutDepthPMA.Multiply=0`, `HarshBandEQ.Gain=0`, so no EQ cut is applied when the follower is silent.
  - Low input trace with `MidCutDepth=-9`: `CutDepthPMA.Multiply=0.0339`, `HarshBandEQ.Gain=-0.3054`, producing a shallow cut.
  - Loud input trace with `MidCutDepth=-9`: `CutDepthPMA.Multiply=0.6787`, `HarshBandEQ.Gain=-6.1086`, matching `-9 * 0.6787`.
  - Loud input trace with `MidCutDepth=-18`: `CutDepthPMA.Multiply=0.6787`, `HarshBandEQ.Gain=-12.2173`, matching `-18 * 0.6787`.
- Trace caveats:
  - `CutDepthPMA.Value` and `CutDepthPMA.Add` are raw/unscaled inputs, but `CutDepthPMA.Multiply` is range-scaled. Its range is set to `0..1` before connecting `InputFollower`.
  - `HarshBandEQ.Smoothing` is locked to `0` so EQ smoothing does not add another envelope on top of `InputFollower.Attack` and `InputFollower.Release`.
  - `TimingBlock` is intentional because this graph exports follower modulation into an EQ parameter; fixed 16-sample blocks make that modulation-to-parameter update interval deterministic.

## Locked Build Values Applied

- None from Phase 2.

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DynamicMidCut --agent
hise-cli builder set --module DynamicMidCut --network dynamic_mid_cut --agent

hise-cli dsp add --module DynamicMidCut --type container.fix16_block --id TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type dynamics.envelope_follower --id InputFollower --parent TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type control.pma_unscaled --id CutDepthPMA --parent TimingBlock --agent
hise-cli dsp add --module DynamicMidCut --type filters.svf_eq --id HarshBandEQ --parent TimingBlock --agent

hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Mode --value 4 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Frequency --value 2500 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Q --value 2.5 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Smoothing --value 0 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Gain --range "0,-18" --stepSize 0.1 --agent

hise-cli dsp set --module DynamicMidCut --node InputFollower --param Attack --range "5,80" --stepSize 0.1 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Attack --value 20 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Release --range "40,300" --stepSize 0.1 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Release --value 120 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Multiply --range "0,1" --stepSize 0.0001 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Add --value 0 --agent

hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id FollowerAttack --range "5,80" --default 20 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id FollowerRelease --range "40,300" --default 120 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module DynamicMidCut --container dynamic_mid_cut --id MidCutDepth --range "-18,-3" --default -9 --stepSize 0.1 --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param FollowerAttack --target InputFollower --param Attack --matched --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param FollowerRelease --target InputFollower --param Release --matched --agent
hise-cli dsp connect --module DynamicMidCut --source dynamic_mid_cut --source-param MidCutDepth --target CutDepthPMA --param Value --agent
hise-cli dsp connect --module DynamicMidCut --source InputFollower --target CutDepthPMA --param Multiply --agent
hise-cli dsp connect --module DynamicMidCut --source CutDepthPMA --target HarshBandEQ --param Gain --agent

hise-cli dsp set --module DynamicMidCut --node InputFollower --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module DynamicMidCut --node InputFollower --param Comment --value '"**Envelope follower** - Tracks input level while leaving the audio path unchanged."' --agent
hise-cli dsp set --module DynamicMidCut --node TimingBlock --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node TimingBlock --param Comment --value '"Fixed 16-sample blocks make the follower-to-EQ modulation update interval deterministic."' --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node CutDepthPMA --param Comment --value '"PMA unscaled multiplies raw depth dB by the follower amount."' --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module DynamicMidCut --node HarshBandEQ --param Comment --value '"Peak EQ cuts more as the follower output rises."' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module DynamicMidCut --agent
hise-cli dsp screenshot --module DynamicMidCut --scale 200% --output "scriptnode_enrichment/hsc/phase5/dynamics/envelope_follower.png" --agent
```

## Comments To Preserve In HSC

- Before `TimingBlock`: fixed 16-sample blocks make the exported follower-to-EQ parameter modulation interval deterministic.
- Before `CutDepthPMA`: use `control.pma_unscaled` so `MidCutDepth` is a raw dB max-cut value and the follower output simply scales how much of that cut is applied.
- Before `CutDepthPMA.Multiply`: set the multiply range to `0..1`; unlike `Value` and `Add`, `Multiply` is range-scaled.
- Before `HarshBandEQ.Gain`: the PMA output is already in dB, so connect it directly to the EQ gain target after setting the target range to `0..-18`.
- Before `HarshBandEQ.Smoothing`: disable EQ smoothing so the envelope timing comes from `InputFollower`, not a second smoothing stage.
- Before `InputFollower.ProcessSignal`: leave it at `Off` so the node analyses the source while passing audio through unchanged.

## Cosmetics Applied

- Main node: `InputFollower` colour `0xFFE67E22`
- Support nodes: [`TimingBlock`, `CutDepthPMA`, `HarshBandEQ`] colour `0xFF8F7766`
- Folded nodes: []
- Visible target nodes: [`TimingBlock`, `InputFollower`, `CutDepthPMA`, `HarshBandEQ`]

## Defaults Omitted

- `InputFollower.ProcessSignal` default `Off`
- `CutDepthPMA.Value` default `0`
- `CutDepthPMA.Add` default `0`
- `HarshBandEQ.Enabled` default `On`

## Open Issues

- None
