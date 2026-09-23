# container.fix8_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix8_block.md`
- Reference: `scriptnode_enrichment/output/container/fix8_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Reworked from a diagnostic staircase into a practical event-raster vibrato example. The user approved the final sine oscillator, bipolar depth control, exact plus or minus 20-cent range, comments, and root Intensity control.

## Naming

- Module ID: `EventRasterVibrato`
- Network ID: `event_raster_vibrato`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Used silent input because `AudibleTone` generates additively.
  - Isolated the fixed-rate triangle LFO from MIDI.
  - Narrowed `VibratoDepth.Scale` before creating its matched root parameter.
  - Used a sine oscillator so stepped-pitch sidebands are not masked by saw harmonics.
- Channel/routing setup verified:
  - Required channels: `default stereo; isolated mono modulation path`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `event_raster_vibrato.Intensity` = `1` range `0..1` stepSize `0`
- `TriangleLfo.Mode` = `2` (`Triangle`)
- `TriangleLfo.Frequency` = `5` range `0.5..8` stepSize `0.1`
- `TriangleLfo.Gate` = `1`
- `VibratoDepth.Value` range = `0..1`
- `VibratoDepth.Scale` range = `0..1`
- `VibratoDepth.Gamma` = `1`
- `AudibleTone.Mode` = `0` (`Sine`)
- `AudibleTone.Frequency` = `220`
- `AudibleTone.Freq Ratio` = `1` range `0.9885140204..1.0116194403`, middle position `1`
- `AudibleTone.Gate` = `1`
- `AudibleTone.Gain` = `0.125`

## Verified Connections

- `LfoValue.0` -> `VibratoDepth.Value` scaled: true
- `event_raster_vibrato.Intensity` -> `VibratoDepth.Scale` matched: true
- `VibratoDepth.0` -> `AudibleTone.Freq Ratio` scaled: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module EventRasterVibrato --container event_raster_vibrato --inject silence --inject-param event_raster_vibrato.Intensity=0 --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module EventRasterVibrato --container event_raster_vibrato --inject silence --inject-param event_raster_vibrato.Intensity=1 --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - Intensity `0` produced `VibratoDepth.Scale=0`, bipolar output `0.5`, and `AudibleTone.Freq Ratio=1` exactly.
  - Intensity `1` enabled bipolar excursion and produced changing oscillator ratios within `0.9885140204..1.0116194403`.
  - A traced low excursion reached `0.9887`, close to the configured minus-20-cent boundary while the LFO continued moving during capture.
- Signal trace commands:
  - Same recursive commands as the parameter traces above.
  - Active/bypassed comparison was also captured by toggling `EightSampleVibrato.Bypassed` around a recursive silence trace.
- Signal trace evidence:
  - Active `EightSampleVibrato` specs reported `sampleRate=48000`, `numChannels=2`, `blockSize=8`.
  - Active `VibratoControl` reported `sampleRate=6000`, `numChannels=1`, `blockSize=1`, confirming one control frame per eight audio samples.
  - Bypassed `EightSampleVibrato` reported `blockSize=512`; the modchain then reported `blockSize=64` at its 6000 Hz control rate.
  - `AudibleTone` generated equal stereo output from silent input with peaks below the locked `0.125` gain.
- Trace caveats:
  - Parameter values can change between the probed-value snapshot and touched-edge report because the 5 Hz LFO remains active throughout capture.
  - Eight samples is the maximum chunk size; a final host-buffer remainder can be shorter.

## Locked Build Values Applied

- Maximum child chunk size = `8` samples
- Triangle LFO = `5 Hz`
- Vibrato depth = exactly plus or minus `20` cents at Intensity `1`
- Ratio lower bound = `2^(-20/1200)` = `0.9885140204`
- Ratio upper bound = `2^(20/1200)` = `1.0116194403`
- Audible tone = `220 Hz` sine at gain `0.125`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They exclude pipeline-only save and screenshot operations.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id EventRasterVibrato --agent
hise-cli builder set --module EventRasterVibrato --network event_raster_vibrato --agent

# Eight samples mirrors HISE_EVENT_RASTER and is the maximum child chunk size; a final remainder can be shorter.
hise-cli dsp add --module EventRasterVibrato --type container.fix8_block --id EightSampleVibrato --agent
hise-cli dsp add --module EventRasterVibrato --type container.modchain --id VibratoControl --parent EightSampleVibrato --agent
# MIDI isolation prevents played notes from retuning the fixed-rate LFO.
hise-cli dsp add --module EventRasterVibrato --type container.no_midi --id MidiIsolation --parent VibratoControl --agent
hise-cli dsp add --module EventRasterVibrato --type core.oscillator --id TriangleLfo --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type math.sig2mod --id NormaliseLfo --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type core.peak --id LfoValue --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type control.bipolar --id VibratoDepth --parent VibratoControl --agent
# Sine mode reveals subtle stepped-pitch sidebands that saw harmonics would mask.
hise-cli dsp add --module EventRasterVibrato --type core.oscillator --id AudibleTone --parent EightSampleVibrato --agent

hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Mode --value 2 --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Frequency --range "0.5,8" --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Frequency --value 5 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Mode --value 0 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Frequency --value 220 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Gain --value 0.125 --agent
# Reciprocal frequency-ratio bounds create symmetric plus or minus 20-cent pitch excursion.
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param 'Freq Ratio' --range "0.9885140204,1.0116194403" --middlePosition 1 --agent

hise-cli dsp connect --module EventRasterVibrato --source LfoValue --target VibratoDepth --param Value --agent
hise-cli dsp connect --module EventRasterVibrato --source VibratoDepth --target AudibleTone --param 'Freq Ratio' --agent

# Set the Scale target range before matching. A matched connection can copy the target range back to the root parameter.
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param Scale --range "0,1" --agent
hise-cli dsp create_parameter --module EventRasterVibrato --container event_raster_vibrato --id Intensity --range "0,1" --default 1 --agent
hise-cli dsp connect --module EventRasterVibrato --source event_raster_vibrato --source-param Intensity --target VibratoDepth --param Scale --matched --agent

hise-cli dsp set --module EventRasterVibrato --node EightSampleVibrato --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module EventRasterVibrato --node EightSampleVibrato --param Comment --value '"**Event-raster vibrato** - Eight-sample chunks mirror HISE_EVENT_RASTER for high-resolution pitch modulation."' --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node MidiIsolation --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node MidiIsolation --param Comment --value '"Blocks MIDI from retuning the fixed-rate triangle LFO."' --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node NormaliseLfo --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node LfoValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param Comment --value '"Set Scale to 0..1 before matching Intensity; matched connections can copy the target range back to the root parameter."' --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Comment --value '"Sine mode exposes subtle stepped-pitch sidebands that saw harmonics would mask; the ratio range is exactly plus or minus 20 cents."' --agent
hise-cli dsp set --module EventRasterVibrato --node NormaliseLfo --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module EventRasterVibrato --agent
hise-cli dsp screenshot --module EventRasterVibrato --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix8_block.png" --agent
```

## Comments To Preserve In HSC

- Before `EightSampleVibrato`: Eight samples mirrors `HISE_EVENT_RASTER` and is a maximum chunk size.
- Before `MidiIsolation`: MIDI must not retune the fixed-rate triangle LFO.
- Before the ratio range: Reciprocal ratio bounds create musically symmetric plus or minus 20-cent excursion.
- Before `AudibleTone`: Sine mode exposes zipper sidebands that saw harmonics mask.
- Before matching Intensity: Narrow `VibratoDepth.Scale` first because matching can copy the target range back to the root parameter.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/fix8_block.md`: Replaced the additive staircase with the approved event-raster vibrato scenario.
  - `scriptnode_enrichment/hsc/phase2/container/fix8_block.md`: Added final bipolar topology, exact ranges, root control, comments, and cosmetics.
- General rules promoted:
  - None
- Local-only findings:
  - The target parameter range must be configured before creating a matched public connection.
  - A pure sine source makes subtle stepped-pitch spectral artifacts easier to inspect.

## Cosmetics Applied

- Main node: `EightSampleVibrato` colour `0xFF2F80ED`
- Support nodes: [`VibratoControl`, `MidiIsolation`, `TriangleLfo`, `NormaliseLfo`, `LfoValue`, `VibratoDepth`, `AudibleTone`] colour `0xFF6F8FAF`
- Folded nodes: [`NormaliseLfo`]
- Visible target nodes: [`EightSampleVibrato`, `VibratoControl`, `MidiIsolation`, `TriangleLfo`, `LfoValue`, `VibratoDepth`, `AudibleTone`]

## Defaults Omitted

- `NormaliseLfo.Value` default `0`
- `VibratoDepth.Value` default `0`
- `VibratoDepth.Scale` default `0`
- `VibratoDepth.Gamma` default `1`
- Both oscillator gates default `On`

## Open Issues

- None blocking this artifact.
