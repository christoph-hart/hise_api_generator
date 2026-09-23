# container.modchain - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/modchain.md`
- Reference: `scriptnode_enrichment/output/container/modchain.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: The final revision wraps both modulation source and audio target in a fixed 32-sample container to increase parameter-update resolution.

## Naming

- Module ID: `ControlRateOscillatorVibrato`
- Network ID: `control_rate_oscillator_vibrato`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
control_rate_oscillator_vibrato
  Resolution32
    VibratoControl
      LfoRamp
      FullCycle
      SineShape
      Normalise
      VibratoPeak
    SawTone
```

## Verified Parameters

- `LfoRamp.PeriodTime` = `500` ms, range `100..2000`
- `FullCycle.Value` = `2`, range `0..2`
- `SawTone.Mode` = `2` (`Saw`)
- `SawTone.Freq Ratio` range = `0.98..1.02`
- `SawTone.Freq Ratio` step size = `0`
- Root `Rate` = `500` ms, range `100..2000`

## Verified Connections

- Root `Rate` -> `LfoRamp.PeriodTime`, matched
- `VibratoPeak.0` -> `SawTone.Freq Ratio`, scaled to `0.98..1.02`

## Trace Validation

- Command:
  ```bash
  hise-cli dsp trace --module ControlRateOscillatorVibrato --container control_rate_oscillator_vibrato --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- Evidence:
  - Root: stereo, 48 kHz, block size 512.
  - `Resolution32`: stereo, 48 kHz, block size 32.
  - `VibratoControl`: isolated mono control buffer, 6 kHz, block size 4.
  - The modchain signal is silent in the parent audio path.
  - Normalized LFO values remained in `0..1`.
  - `SawTone.Freq Ratio` changed continuously and reached `0.9808` in the final verification.
  - `SawTone` produced nonzero audio on both channels.
- Important: The fractional target range must use step size zero. Retaining the oscillator's stock integer step quantizes the modulation to `1.0`.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ControlRateOscillatorVibrato --agent
hise-cli builder set --module ControlRateOscillatorVibrato --network control_rate_oscillator_vibrato --agent

# A fixed 32-sample wrapper increases updates from once per host block to every 32 audio samples.
hise-cli dsp add --module ControlRateOscillatorVibrato --type container.fix32_block --id Resolution32 --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type container.modchain --id VibratoControl --parent Resolution32 --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.ramp --id LfoRamp --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.pi --id FullCycle --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.sin --id SineShape --parent VibratoControl --agent
# Convert bipolar sine to 0..1 before peak, avoiding zero-crossing folding.
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.sig2mod --id Normalise --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.peak --id VibratoPeak --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.oscillator --id SawTone --parent Resolution32 --agent

hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param PeriodTime --range "100,2000" --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param PeriodTime --value 500 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Value --range "0,2" --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Value --value 2 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param Mode --value 2 --agent
# The stock oscillator ratio step is integer. Set step size zero before applying subtle modulation.
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param 'Freq Ratio' --range "0.98,1.02" --stepSize 0 --middlePosition 1 --agent

hise-cli dsp create_parameter --module ControlRateOscillatorVibrato --container control_rate_oscillator_vibrato --id Rate --range "100,2000" --default 500 --agent
hise-cli dsp connect --module ControlRateOscillatorVibrato --source control_rate_oscillator_vibrato --source-param Rate --target LfoRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module ControlRateOscillatorVibrato --source VibratoPeak --target SawTone --param 'Freq Ratio' --agent

hise-cli dsp set --module ControlRateOscillatorVibrato --node Resolution32 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Resolution32 --param Comment --value '"Constrains source and target to 32-sample blocks, so vibrato updates every 32 audio samples instead of once per host block."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoControl --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoControl --param Comment --value '"Processes an isolated mono control buffer at one eighth of the parent sample rate and does not enter the stereo audio path."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param Comment --value '"PeriodTime is the full vibrato cycle in milliseconds."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Normalise --param Comment --value '"Convert the bipolar sine to 0..1 before peak extraction so the negative half-cycle is not folded."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoPeak --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoPeak --param Comment --value '"Exports the normalized control buffer into SawTone Freq Ratio range 0.98..1.02."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param Comment --value '"Freq Ratio uses a continuous fractional range; step size must be zero or the subtle vibrato is quantized away."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Folded --value true --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SineShape --param Folded --value true --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Normalise --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module ControlRateOscillatorVibrato --agent
hise-cli dsp screenshot --module ControlRateOscillatorVibrato --scale 200% --output "scriptnode_enrichment/hsc/output/container/modchain.png" --agent
```

## Open Issues

- None.
