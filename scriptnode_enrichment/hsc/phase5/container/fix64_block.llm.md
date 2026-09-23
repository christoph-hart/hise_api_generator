---
id: container.fix64_block.slowly-evolving-filter-tone
node: container.fix64_block
domain: scriptnode
category: dsp-network
title: "Slowly Evolving Filter Tone"
summary: "Splits the audio buffer into chunks of 64 samples for higher modulation update rates."
useCase: "Demonstrate that `container.fix64_block` is a sensible default for slowly evolving modulation: its parameter updates are much finer than the smoothing trajectory requires, while it avoids the iteration cost of 8-, 16-, and 32-sample containers."
difficulty: intermediate
networkName: slowly_evolving_filter_tone
moduleType: ScriptFX
moduleId: SlowlyEvolvingFilterTone
tags:
  - container
  - fix64
  - block
  - block-size
  - processing-context
aliases:
  - slowly evolving filter tone
  - fix64 block container
relatedNodes:
  - container.fix64_block
  - control.smoothed_parameter
  - filters.svf
parameters:
  Tone: "Tone -> ToneSmoother.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.25"
---

scriptnode example: container.fix64_block

Slowly Evolving Filter Tone.

Demonstrate that `container.fix64_block` is a sensible default for slowly evolving modulation: its parameter updates are much finer than the smoothing trajectory requires, while it avoids the iteration cost of 8-, 16-, and 32-sample containers.

Graph:
```text
slowly_evolving_filter_tone
  SixtyFourSampleMotion  container.fix64_block
    ToneSmoother         control.smoothed_parameter
    EvolvingLowPass      filters.svf
```

Host:
  Module: SlowlyEvolvingFilterTone
  Network: slowly_evolving_filter_tone
  Host context: Script FX
  Required channels: default stereo
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "SlowlyEvolvingFilterTone"`, then set its network to `slowly_evolving_filter_tone`.

Support nodes:
  Required: control.smoothed_parameter, filters.svf
  `control.smoothed_parameter` converts abrupt root control changes into a deterministic long ramp, and `filters.svf` provides an audible cutoff target whose own smoothing can be disabled so the control node and 64-sample cadence remain authoritative.

Key rules:
  - Before SixtyFourSampleMotion: Sixty-four samples is a low-overhead default for slowly evolving modulation.
  - Before ToneSmoother: Linear Ramp reaches its target in exactly 1000 ms.
  - Before filter range setup: Configure the target range before connecting the normalized smoother.
  - Before filter smoothing: Keep it at zero to avoid stacking a second interpolation stage.
  - Before validation: Use noise or another harmonically rich input because silence cannot reveal cutoff movement.

Public controls:
  - Tone -> ToneSmoother.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.25

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SlowlyEvolvingFilterTone --agent
hise-cli builder set --module SlowlyEvolvingFilterTone --network slowly_evolving_filter_tone --agent

# Sixty-four samples is the default starting size for adjustable block containers and is sufficient for slow modulation.
hise-cli dsp add --module SlowlyEvolvingFilterTone --type container.fix64_block --id SixtyFourSampleMotion --agent
hise-cli dsp add --module SlowlyEvolvingFilterTone --type control.smoothed_parameter --id ToneSmoother --parent SixtyFourSampleMotion --agent
hise-cli dsp add --module SlowlyEvolvingFilterTone --type filters.svf --id EvolvingLowPass --parent SixtyFourSampleMotion --agent

hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param Mode --value '"Linear Ramp"' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param SmoothingTime --value 1000 --agent
# Configure the skewed target range before connecting the normalised smoother output.
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Frequency --range "200,8000" --middlePosition 1000 --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Frequency --value 200 --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Q --value 0.7 --agent
# Keep this at zero so only ToneSmoother defines the transition.
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Smoothing --value 0 --agent

hise-cli dsp create_parameter --module SlowlyEvolvingFilterTone --container slowly_evolving_filter_tone --id Tone --range "0,1" --default 0.25 --agent
hise-cli dsp connect --module SlowlyEvolvingFilterTone --source slowly_evolving_filter_tone --source-param Tone --target ToneSmoother --param Value --matched --agent
hise-cli dsp connect --module SlowlyEvolvingFilterTone --source ToneSmoother --target EvolvingLowPass --param Frequency --agent

hise-cli dsp set --module SlowlyEvolvingFilterTone --node SixtyFourSampleMotion --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node SixtyFourSampleMotion --param Comment --value '"**Slowly evolving filter tone** - Sixty-four-sample chunks are sufficient for a one-second smoothed cutoff transition with low iteration overhead."' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param Comment --value '"Linear Ramp turns abrupt Tone changes into an exact one-second transition before the filter is updated."' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Comment --value '"Its 200 to 8000 Hz range must be configured before connecting; Smoothing remains zero to avoid a second interpolation stage."' --agent
```

