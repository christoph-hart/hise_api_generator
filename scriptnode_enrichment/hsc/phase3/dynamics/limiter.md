# dynamics.limiter - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/dynamics/limiter.md`
- Reference: `scriptnode_enrichment/output/dynamics/limiter.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Built and validated in live HISE. The network demonstrates `dynamics.limiter` as a final peak-safety stage after a small SNEX expression shaper. `math.expr` requires a compile-enabled network; `dsp status --autofix` applies HISE's built-in fix for this runtime error.
- Phase 2 deviation: changed the support node factory from `core.expr` to `math.expr`, because the current Scriptnode docs and live CLI expose the audio expression node as `math.expr`.

## Naming

- Module ID: `SafetyPeakLimiter`
- Network ID: `safety_peak_limiter`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Ran `dsp status --autofix` after adding the SNEX expression node so HISE enabled the required network compilation flag.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `DriveShaper.Value` = `0.5` range `0..0.75` stepSize `0.01`
- `DriveShaper.Code` = `input + value * input * input * input`
- `SafetyLimiter.Threshhold` = `-3` range `-12..-1` stepSize `0.1`
- `SafetyLimiter.Attack` = `5` range `0..250` stepSize `0.1`
- `SafetyLimiter.Release` = `90` range `20..180` stepSize `0.1`
- `SafetyLimiter.Ratio` = `20` range `12..32` stepSize `0.1`
- `safety_peak_limiter.DriveAmount` = `0.5` range `0..0.75` stepSize `0.01`
- `safety_peak_limiter.LimitThreshold` = `-3` range `-12..-1` stepSize `0.1`
- `safety_peak_limiter.LimitRelease` = `90` range `20..180` stepSize `0.1`
- `safety_peak_limiter.LimitRatio` = `20` range `12..32` stepSize `0.1`

## Verified Connections

- `safety_peak_limiter.DriveAmount` -> `DriveShaper.Value` matched: true
- `safety_peak_limiter.LimitThreshold` -> `SafetyLimiter.Threshhold` matched: true
- `safety_peak_limiter.LimitRelease` -> `SafetyLimiter.Release` matched: true
- `safety_peak_limiter.LimitRatio` -> `SafetyLimiter.Ratio` matched: true

## Trace Validation

- Runtime status commands:
  - `hise-cli dsp status --module SafetyPeakLimiter --agent`
  - `hise-cli dsp status --module SafetyPeakLimiter --autofix --agent`
  - `hise-cli dsp status --module SafetyPeakLimiter --agent`
- Runtime status evidence:
  - Initial status failed with `DriveShaper - You need to compile networks with this node. Check the AllowCompilation flag in the network properties to remove the error.`
  - Autofix status returned `success=true`, `ok=true`, `autofixRequested=true`, `autofixApplied=true`, and `fixedNodeId=DriveShaper`.
  - Follow-up status returned `success=true`, `ok=true`, `autofixRequested=false`, and `autofixApplied=false`.
- Parameter trace commands:
  - `hise-cli dsp trace --module SafetyPeakLimiter --container safety_peak_limiter --inject silence --inject-param safety_peak_limiter.DriveAmount=0.75 --inject-param safety_peak_limiter.LimitThreshold=-6 --inject-param safety_peak_limiter.LimitRelease=150 --inject-param safety_peak_limiter.LimitRatio=32 --probe-param DriveShaper.Value --probe-param SafetyLimiter.Threshhold --probe-param SafetyLimiter.Release --probe-param SafetyLimiter.Ratio --trace-compact --agent`
- Parameter trace evidence:
  - `DriveShaper.Value` probed as `0.75`, `SafetyLimiter.Threshhold` as `-6`, `SafetyLimiter.Release` as `150`, and `SafetyLimiter.Ratio` as `32`; all matched injected root control values.
- Signal trace commands:
  - `hise-cli dsp trace --module SafetyPeakLimiter --container safety_peak_limiter --inject noise --gain 0.9 --seed 1234 --probe-recursive --probe-param SafetyLimiter.Threshhold --probe-param SafetyLimiter.Attack --probe-param SafetyLimiter.Release --probe-param SafetyLimiter.Ratio --trace-compact --agent`
  - `hise-cli dsp trace --module SafetyPeakLimiter --container safety_peak_limiter --inject dirac --gain 1 --probe-recursive --probe-param SafetyLimiter.Attack --trace-compact --agent`
- Signal trace evidence:
  - Noise trace: `DriveShaper` produced about `-1.2624..1.2623`, then `SafetyLimiter` reduced the traced output to about `-0.709..-0.7099` with threshold `-3`, attack `5`, release `90`, and ratio `20`.
  - Dirac trace: `DriveShaper` produced `1.5`, then `SafetyLimiter` reduced the traced output to `0.7122` with attack `5`.
- Trace caveats:
  - `math.expr` is structurally valid before the network compilation flag is enabled, but runtime status and trace require resolving the compile-enabled-network error first.
  - `SafetyLimiter.Attack` is deliberately fixed at `5 ms`; it is not exposed as a root parameter because attack changes alter lookahead latency and can click at runtime.

## Locked Build Values Applied

- `DriveShaper.Code` = `input + value * input * input * input`
- `SafetyLimiter.Attack` = `5`

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SafetyPeakLimiter --agent
hise-cli builder set --module SafetyPeakLimiter --network safety_peak_limiter --agent

hise-cli dsp add --module SafetyPeakLimiter --type math.expr --id DriveShaper --agent
hise-cli dsp add --module SafetyPeakLimiter --type dynamics.limiter --id SafetyLimiter --agent
hise-cli dsp status --module SafetyPeakLimiter --autofix --agent

hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Code --value '"input + value * input * input * input"' --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Value --range "0,0.75" --stepSize 0.01 --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Value --value 0.5 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Attack --value 5 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Threshhold --range "-12,-1" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Threshhold --value -3 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Release --range "20,180" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Release --value 90 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Ratio --range "12,32" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Ratio --value 20 --agent

hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id DriveAmount --range "0,0.75" --default 0.5 --stepSize 0.01 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitThreshold --range "-12,-1" --default -3 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitRelease --range "20,180" --default 90 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitRatio --range "12,32" --default 20 --stepSize 0.1 --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param DriveAmount --target DriveShaper --param Value --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitThreshold --target SafetyLimiter --param Threshhold --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitRelease --target SafetyLimiter --param Release --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitRatio --target SafetyLimiter --param Ratio --matched --agent

hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Comment --value '"DriveShaper adds cubic colour before the limiter so the safety stage has real overs to catch."' --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Comment --value '"**Peak safety limiter** - Final stage catches shaper peaks. Attack is fixed because it changes lookahead latency."' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module SafetyPeakLimiter --agent
hise-cli dsp screenshot --module SafetyPeakLimiter --scale 200% --output "scriptnode_enrichment/hsc/phase5/dynamics/limiter.png" --agent
```

## Comments To Preserve In HSC

- Before `DriveShaper.Code`: lock the expression to `input + value * input * input * input` so the example stays on a simple cubic shaper that compiles cleanly in SNEX.
- Before `dsp status --autofix`: run HISE's runtime autofix so the network compilation flag required by `math.expr` is enabled before tracing.
- Before `SafetyLimiter`: place the limiter last so it reads as a safety stage after the non-linear shaper.
- Before `SafetyLimiter.Attack`: treat attack as a fixed lookahead/latency choice, not a performance macro, because changing it at runtime causes clicks.

## Cosmetics Applied

- Main node: `SafetyLimiter` colour `0xFFE67E22`
- Support nodes: [`DriveShaper`] colour `0xFF8F7766`
- Folded nodes: []
- Visible target nodes: [`DriveShaper`, `SafetyLimiter`]

## Defaults Omitted

- `SafetyLimiter.Sidechain` default `Disabled`
- `DriveShaper.Debug` default `false`

## Open Issues

- None
