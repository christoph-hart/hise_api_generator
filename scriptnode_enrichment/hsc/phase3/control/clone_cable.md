# control.clone_cable - HSC Construction Artifact

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/clone_cable.md`
- Phase 2: `scriptnode_enrichment/hsc/phase2/control/clone_cable.md`
- Reference: `scriptnode_enrichment/output/control/clone_cable.md`

## Status

- Built in HISE: true
- User approved: true
- Final topology approved: true
- Notes: The Script FX host requires an explicit `container.midichain` for MIDI-reactive Harmonics mode. The clone editor shows one representative clone with `ShowClones=false`; the representative child remains unfolded.

## Naming

- Module ID: `MidiHarmonicOscillatorBank`
- Network ID: `midi_harmonic_oscillator_bank`

## Final Topology

```text
midi_harmonic_oscillator_bank
  MidiContext            container.midichain
    HarmonicFrequencies  control.clone_cable
    HarmonicBank         container.clone
      PartialVoice       container.chain
        SinePartial      core.oscillator
```

## Builder Setup Applied

- Host context: `Script FX`
- MIDI context: `MidiContext` is required because Script FX does not process MIDI at the root.
- Clone count: 16 configured physical clones.
- Clone display: `HarmonicBank.ShowClones=false`, displaying one representative clone.
- Representative child: `PartialVoice.Folded=false`.
- `HarmonicBank.IsVertical=false`.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default

## Verified Parameters

- First root macro: `NumHarmonics`, range `1..16`, step `1`, default `8`
- `HarmonicBank.NumClones`: range `1..16`, step `1`
- `HarmonicFrequencies.NumClones`: range `1..16`, step `1`
- `HarmonicBank.SplitSignal` = `Parallel`
- `HarmonicFrequencies.Mode` = `Harmonics`
- `SinePartial.Mode` = `Sine`
- `SinePartial.Frequency` range = linear `[0..20000]` Hz
- `SinePartial.Gain` = `0.05`
- `SinePartial.Gate` = `On`
- Gamma remains unexposed and ignored by Harmonics mode.

## Verified Connections

- `NumHarmonics` -> `HarmonicBank.NumClones`, matched range
- `NumHarmonics` -> `HarmonicFrequencies.NumClones`, matched range
- `HarmonicFrequencies.0` -> `SinePartial.Frequency`, scaled modulation

## Trace Validation

- MIDI trace command:
  - `hise-cli dsp trace --module MidiHarmonicOscillatorBank --container midi_harmonic_oscillator_bank --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Evidence:
  - Root Script FX reported `processMidi=false`.
  - `MidiContext` reported `processMidi=true`.
  - `HarmonicBank` reported 16 clone children with `processMidi=true`.
  - The oscillator frequency modulation edge was touched by `HarmonicFrequencies`.
  - The clone bank produced non-silent output from the triggered note.
- Macro trace command:
  - `hise-cli dsp trace --module MidiHarmonicOscillatorBank --container midi_harmonic_oscillator_bank --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --inject-param midi_harmonic_oscillator_bank.NumHarmonics=8 --probe-changed-parameters --trace-compact --agent`
- Macro evidence:
  - The root macro accepted value `8` and produced non-silent stereo output.
- Runtime status:
  - `ok=true`

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They exclude save and screenshot commands.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MidiHarmonicOscillatorBank --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module MidiHarmonicOscillatorBank --network midi_harmonic_oscillator_bank --agent
hise-cli dsp add --module MidiHarmonicOscillatorBank --type container.midichain --id MidiContext --parent midi_harmonic_oscillator_bank --agent
hise-cli dsp add --module MidiHarmonicOscillatorBank --type control.clone_cable --id HarmonicFrequencies --parent MidiContext --agent
hise-cli dsp add --module MidiHarmonicOscillatorBank --type container.clone --id HarmonicBank --parent MidiContext --agent
hise-cli dsp rename --module MidiHarmonicOscillatorBank --node clone_child --id PartialVoice --agent
hise-cli dsp add --module MidiHarmonicOscillatorBank --type core.oscillator --id SinePartial --parent PartialVoice --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param SplitSignal --value Parallel --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicFrequencies --param Mode --value Harmonics --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param Mode --value Sine --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param Frequency --range "0,20000" --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param Gain --value 0.05 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param Gate --value On --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param NumClones --range "1,16" --stepSize 1 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicFrequencies --param NumClones --range "1,16" --stepSize 1 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param NumClones --value 16 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicFrequencies --param NumClones --value 16 --agent
hise-cli dsp create_parameter --module MidiHarmonicOscillatorBank --container midi_harmonic_oscillator_bank --id NumHarmonics --range "1,16" --default 8 --stepSize 1 --agent
hise-cli dsp connect --module MidiHarmonicOscillatorBank --source midi_harmonic_oscillator_bank --source-param NumHarmonics --target HarmonicBank --param NumClones --matched --agent
hise-cli dsp connect --module MidiHarmonicOscillatorBank --source midi_harmonic_oscillator_bank --source-param NumHarmonics --target HarmonicFrequencies --param NumClones --matched --agent
hise-cli dsp connect --module MidiHarmonicOscillatorBank --source HarmonicFrequencies --target SinePartial --param Frequency --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param ShowClones --value false --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param IsVertical --value false --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node PartialVoice --param Folded --value false --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node MidiContext --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicFrequencies --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node MidiContext --param Comment --value '\"**MIDI context** - Harmonics mode derives each partial frequency from incoming note-on events.\"' --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicFrequencies --param Comment --value '\"**Harmonic distribution** - Splits the incoming note frequency into integer multiples for the active clones.\"' --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node HarmonicBank --param Comment --value '\"**Parallel harmonic bank** - Up to sixteen identical sine voices run in parallel.\"' --agent
hise-cli dsp set --module MidiHarmonicOscillatorBank --node SinePartial --param Comment --value '\"**Sine partial** - Each clone receives one MIDI-derived harmonic frequency at conservative gain.\"' --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp status --module MidiHarmonicOscillatorBank --agent
hise-cli dsp trace --module MidiHarmonicOscillatorBank --container midi_harmonic_oscillator_bank --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp save --module MidiHarmonicOscillatorBank --agent
hise-cli dsp screenshot --module MidiHarmonicOscillatorBank --scale 200% --output "scriptnode_enrichment/hsc/output/control/clone_cable.png" --agent
```

## Cosmetics Applied

- Main node: `HarmonicFrequencies`, colour `0xFF8E44AD`
- Supporting nodes: [`MidiContext`, `HarmonicBank`, `SinePartial`], colour `0xFF7F6A91`
- Folded nodes: []
- Visible target nodes: [`MidiContext`, `HarmonicFrequencies`, `HarmonicBank`, `PartialVoice`, `SinePartial`]
- `HarmonicBank.ShowClones=false`
- `HarmonicBank.IsVertical=false`

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/control/clone_cable.md`
  - `scriptnode_enrichment/hsc/phase2/control/clone_cable.md`
- General rules promoted:
  - MIDI-reactive control nodes in Script FX require an explicit MIDI-aware container.
  - Clone count must be the first root macro with identical matched ranges on the clone container and clone cable.
  - Keep a linear 0..20000 Hz target range for MIDI-reactive frequency modulation.
- Local-only findings:
  - With `ShowClones=false`, the editor displays one representative clone; unfold that child to inspect its oscillator.

## Open Issues

- None
