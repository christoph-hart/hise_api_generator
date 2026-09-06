---
id: fx.bitcrush.crushed-echo-trail
node: fx.bitcrush
domain: scriptnode
category: dsp-network
title: Crushed feedback delay
summary: Places a bipolar bitcrusher inside a feedback delay so each echo repeat degrades progressively.
useCase: Use this for lo-fi echo trails and repeated digital degradation.
difficulty: intermediate
aliases:
  - crushed echo
  - lo-fi feedback delay
networkName: crushed_echo_trail
moduleType: ScriptFX
moduleId: CrushedEchoTrail
tags:
  - bitcrush
  - feedback
  - lo-fi
relatedNodes:
  - fx.bitcrush
  - template.feedback_delay
  - filters.one_pole
parameters:
  Bits: Bit depth of each feedback repeat.
  Feedback: Feedback amount below unity.
  DelayMs: Delay time in milliseconds.
---
scriptnode example: fx.bitcrush

Crushed feedback delay

Reduces the bit depth of the audio signal, producing quantisation noise and digital distortion.

Context:
  A lo-fi echo should degrade more on each repeat instead of crushing only the direct signal once. `fx.bitcrush` is inserted inside a feedback delay path so every echo pass loses amplitude resolution and becomes progressively more digital.

Use this when:
  Demonstrate `fx.bitcrush` as a feedback-path colour stage and show why Bipolar mode is usually the safer choice for modulated or repeated signals.

Graph:
```text
crushed_echo_trail
  EchoLoop         template.feedback_delay
    EchoCrusher     fx.bitcrush
    FeedbackTone    filters.one_pole
```

Host:
  Module: CrushedEchoTrail
  Network: crushed_echo_trail
  Host context: Script FX
  Additional builder steps applied: inserted the crusher and tone stage into the feedback template block.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: template.feedback_delay
  Optional: filters.one_pole, core.gain
  The feedback delay template provides the safe fixed-block send/receive loop, and the bitcrusher can be inserted between the delay and feedback send. Optional filtering or gain can shape the feedback character without distracting from the target node.

Public controls:
  - Bits -> `EchoCrusher.BitDepth` matched
  - Target range before connection: `[4, 12]`
  - Macro range: `[4, 12]`
  - Default: `7`
  - Feedback -> internal feedback gain parameter of `EchoLoop` matched
  - Target range before connection: `[0, 0.8]`
  - Macro range: `[0, 0.8]`
  - Default: `0.45`
  - DelayMs -> internal delay time parameter of `EchoLoop` matched
  - Target range before connection: `[80, 600]`
  - Macro range: `[80, 600]`
  - Default: `240`

Verified connections:
  - `crushed_echo_trail.Bits -> EchoCrusher.BitDepth` matched
  - `crushed_echo_trail.Feedback -> EchoLoop_fb_out.Feedback` matched
  - `crushed_echo_trail.DelayMs -> EchoLoop_delay.DelayTime` matched

Key rules:
  - Keep Bipolar mode in a feedback path to avoid accumulating DC bias.
  - Keep feedback below unity.

Common mistakes:
  - DC Offset mode introduces DC bias: DC Offset mode rounds using ceil with a half-step shift, which introduces a small DC offset into the signal. Bipolar mode rounds toward zero and does not produce DC bias.
  - BitDepth 16 is effectively transparent: At 16 bits there are 65536 quantisation levels, producing noise well below audible threshold. The effect becomes clearly audible below roughly 10-12 bits.
  - Clipping does not remove DC offset: DC offset is a 0 Hz signal component, not an amplitude excess. Clipping to [-1, 1] has no effect on it. A high-pass filter is the correct remedy.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id CrushedEchoTrail --agent
hise-cli builder set --module CrushedEchoTrail --network crushed_echo_trail --agent
hise-cli dsp add --module CrushedEchoTrail --type template.feedback_delay --id EchoLoop --agent
hise-cli dsp add --module CrushedEchoTrail --type fx.bitcrush --id EchoCrusher --parent EchoLoop --agent
hise-cli dsp add --module CrushedEchoTrail --type filters.one_pole --id FeedbackTone --parent EchoLoop --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --index 1 --agent
hise-cli dsp set --module CrushedEchoTrail --node FeedbackTone --index 2 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param Mode --value 1 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param BitDepth --range "4,12" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param BitDepth --value 7 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_fb_out --param Feedback --range "0,0.8" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_fb_out --param Feedback --value 0.45 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_delay --param DelayTime --range "80,600" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_delay --param DelayTime --value 240 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id Bits --range "4,12" --default 7 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id Feedback --range "0,0.8" --default 0.45 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id DelayMs --range "80,600" --default 240 --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param Bits --target EchoCrusher --param BitDepth --matched --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param Feedback --target EchoLoop_fb_out --param Feedback --matched --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param DelayMs --target EchoLoop_delay --param DelayTime --matched --agent
```
