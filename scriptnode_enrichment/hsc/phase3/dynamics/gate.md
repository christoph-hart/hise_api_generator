# dynamics.gate - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/dynamics/gate.md`
- Reference: `scriptnode_enrichment/output/dynamics/gate.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved for Phase 4 conversion. The live prototype keeps the original dry signal unmodified by splitting the input into three branches: untouched dry passthrough, gate-control analysis, and synthetic noise. Trace confirmed the native gate modulation output is gain-reduction amount, so `NoiseGain.Gain` uses a reversed target range to turn closed-gate reduction into texture attenuation and open-gate activity into texture gain.
- Phase 2 deviation: the live build uses an extra empty `DryPath` and a `GateControlPath` with `ControlClear` because `dynamics.gate` has no `ProcessSignal` parameter and would otherwise alter or duplicate the original input.

## Naming

- Module ID: `NoiseLayerGate`
- Network ID: `noise_layer_gate`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `[0,1]`
  - Master routing: `default stereo`

## Verified Parameters

- `SelfGate.Threshhold` = `-30` range `-48..-18` stepSize `0.1`
- `SelfGate.Release` = `80` range `20..160` stepSize `0.1`
- `SelfGate.Ratio` = `10` range `4..16` stepSize `0.1`
- `noise_layer_gate.GateThreshold` = `-30` range `-48..-18` stepSize `0.1`
- `noise_layer_gate.GateRelease` = `80` range `20..160` stepSize `0.1`
- `noise_layer_gate.GateDepth` = `10` range `4..16` stepSize `0.1`
- `NoiseSource.Mode` = `4` range `0..4` stepSize `1`
- `NoiseSource.Gain` = `0.25` range `0..1`
- `NoiseFilter.Mode` = `1` range `0..4` stepSize `1`
- `NoiseFilter.Frequency` = `2500` range `20..20000`
- `NoiseFilter.Q` = `0.8` range `0.3..9.9`
- `NoiseGain.Gain` = `0` range `0..-100` stepSize `0.1`
- `NoiseGain.Smoothing` = `0`

## Verified Connections

- `noise_layer_gate.GateThreshold` -> `SelfGate.Threshhold` matched: true
- `noise_layer_gate.GateRelease` -> `SelfGate.Release` matched: true
- `noise_layer_gate.GateDepth` -> `SelfGate.Ratio` matched: true
- `SelfGate` -> `NoiseGain.Gain` matched: false, target range reversed `0..-100`

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module NoiseLayerGate --container noise_layer_gate --inject-param noise_layer_gate.GateThreshold=-24 --inject-param noise_layer_gate.GateRelease=120 --inject-param noise_layer_gate.GateDepth=14 --probe-param SelfGate.Threshhold --probe-param SelfGate.Release --probe-param SelfGate.Ratio --trace-compact --agent`
- Parameter trace evidence:
  - `SelfGate.Threshhold` probed as `-24`, `SelfGate.Release` as `120`, and `SelfGate.Ratio` as `14`; all matched the injected root control values.
- Signal trace commands:
  - `hise-cli dsp trace --module NoiseLayerGate --container noise_layer_gate --inject silence --delay-ms 100 --probe-recursive --probe-param NoiseGain.Gain --trace-compact --agent`
  - `hise-cli dsp trace --module NoiseLayerGate --container noise_layer_gate --inject noise --gain 1 --seed 1234 --inject-param noise_layer_gate.GateThreshold=-48 --inject-param noise_layer_gate.GateDepth=4 --probe-recursive --probe-param NoiseGain.Gain --trace-compact --agent`
  - `hise-cli dsp trace --module NoiseLayerGate --container noise_layer_gate --inject noise --gain 0.001 --seed 1234 --probe-recursive --probe-param NoiseGain.Gain --trace-compact --agent`
- Signal trace evidence:
  - Delayed silence trace: after the gate release settled, `DryPath`, `GateControlPath`, `NoisePath`, and final output were silent; `NoiseSource` and `NoiseFilter` generated stereo noise internally; reversed `NoiseGain.Gain` mapped to `-100`, making `NoisePath` silent at the split output.
  - Open-state trace: with temporary `GateThreshold=-48` and `GateDepth=4`, `DryPath` passed the original source, `SelfGate` analysed a duplicate source in `GateControlPath`, `ControlClear` removed the gated duplicate audio, and `NoiseGain.Gain` mapped to about `-25.2`, making the filtered noise layer audible on both channels.
  - Low-signal trace: low-level source still passed through `DryPath`; `SelfGate` stayed closed in the control branch; `NoiseGain.Gain` mapped to `-100`, muting the texture layer.
  - Recursive specs stayed stereo throughout: sample rate `44100`, block size `512`, `numChannels=2`, `polyphonic=false`, `processMidi=false`.
- Trace caveats:
  - `dynamics.gate` has no `ProcessSignal` parameter, so the original dry signal must remain on a separate split branch if it should be unmodified.
  - `dynamics.gate` native modulation is gain-reduction amount, not open-gate activity. The `NoiseGain.Gain` target range is reversed (`0..-100`) before connection so closed gate maps to attenuation and open gate maps toward unity.
  - `NoiseGain.Smoothing` is locked to `0` so the audible texture envelope follows `SelfGate.Release` instead of adding a second gain-node smoothing stage.
  - Immediate first-block silence traces can show the gate release state before it settles. Use a delayed silence trace when validating closed-state attenuation.
  - The empty `DryPath` is intentionally folded because it has no visible child nodes. `GateControlPath` is intentionally not folded so `SelfGate` remains visible.

## Locked Build Values Applied

- None from Phase 2.

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id NoiseLayerGate --agent
hise-cli builder set --module NoiseLayerGate --network noise_layer_gate --agent

hise-cli dsp add --module NoiseLayerGate --type container.split --id TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id DryPath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id GateControlPath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type dynamics.gate --id SelfGate --parent GateControlPath --agent
hise-cli dsp add --module NoiseLayerGate --type math.clear --id ControlClear --parent GateControlPath --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id NoisePath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type math.clear --id NoiseClear --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type core.oscillator --id NoiseSource --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type filters.svf_eq --id NoiseFilter --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type core.gain --id NoiseGain --parent NoisePath --agent

hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Mode --value 4 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Gain --value 0.25 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Mode --value 1 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Frequency --value 2500 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Q --value 0.8 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Gain --range "0,-100" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Smoothing --value 0 --agent

hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Threshhold --range "-48,-18" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Threshhold --value -30 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Release --range "20,160" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Release --value 80 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Ratio --range "4,16" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Ratio --value 10 --agent

hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateThreshold --range "-48,-18" --default -30 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateRelease --range "20,160" --default 80 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateDepth --range "4,16" --default 10 --stepSize 0.1 --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateThreshold --target SelfGate --param Threshhold --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateRelease --target SelfGate --param Release --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateDepth --target SelfGate --param Ratio --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source SelfGate --target NoiseGain --param Gain --agent

hise-cli dsp set --module NoiseLayerGate --node SelfGate --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Comment --value '"**Self-keyed gate** - This duplicate input branch drives the gate modulation while the original dry branch stays untouched."' --agent
hise-cli dsp set --module NoiseLayerGate --node TextureSplit --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node TextureSplit --param Comment --value '"Texture split keeps the dry source and control branch separate."' --agent
hise-cli dsp set --module NoiseLayerGate --node GateControlPath --param Comment --value '"Control branch only. SelfGate analyses a dry copy and ControlClear removes duplicate audio."' --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param Comment --value '"Clear the gated duplicate so only the dry branch reaches the output."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param Comment --value '"Clear inherited signal before adding the synthetic noise layer."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Comment --value '"Oscillator noise keeps the example compact."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Comment --value '"Reversed target range maps gate reduction to open gate texture gain."' --agent
hise-cli dsp set --module NoiseLayerGate --node DryPath --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module NoiseLayerGate --agent
hise-cli dsp screenshot --module NoiseLayerGate --scale 200% --output "scriptnode_enrichment/hsc/phase5/dynamics/gate.png" --agent
```

## Comments To Preserve In HSC

- Before `TextureSplit`: split into three branches so the original dry source remains unmodified, the gate analyses a duplicate, and the noise layer can be generated separately.
- Before `ControlClear`: clear the gated duplicate after `SelfGate` so the control branch does not add audio to the split output.
- Before `NoiseClear`: clear the inherited split signal first so the noise branch does not double the dry source.
- Before `NoiseSource`: set the oscillator to noise; a looped file-player noise bed would often be better in production.
- Before the modulation connection to `NoiseGain.Gain`: the gate modulation output is gain-reduction amount, so reverse `NoiseGain.Gain` to `0..-100` before connecting it.
- Before `NoiseGain.Smoothing`: disable gain-node smoothing so `SelfGate.Release` is the only release envelope demonstrated by the noise layer.
- Before cosmetic properties: do not fold `GateControlPath`, because folding a parent would hide the demonstrated `SelfGate` child.

## Cosmetics Applied

- Main node: `SelfGate` colour `0xFFE67E22`
- Support nodes: [`TextureSplit`, `ControlClear`, `NoiseClear`, `NoiseSource`, `NoiseFilter`, `NoiseGain`] colour `0xFF8F7766`
- Folded nodes: [`DryPath`, `ControlClear`, `NoiseClear`, `NoiseSource`, `NoiseFilter`]
- Visible target nodes: [`TextureSplit`, `GateControlPath`, `SelfGate`, `NoisePath`, `NoiseGain`]

## Defaults Omitted

- `SelfGate.Attack` default `50`
- `SelfGate.Sidechain` default `Disabled`
- `ControlClear.Value` default `0.0`
- `NoiseClear.Value` default `0.0`
- `NoiseSource.Frequency` default `220`
- `NoiseSource.Freq Ratio` default `1`
- `NoiseSource.Gate` default `On`
- `NoiseSource.Phase` default `0`
- `NoiseFilter.Gain` default `0`
- `NoiseFilter.Smoothing` default `0.01`
- `NoiseFilter.Enabled` default `On`
- `NoiseGain.ResetValue` default `0`

## Open Issues

- None
