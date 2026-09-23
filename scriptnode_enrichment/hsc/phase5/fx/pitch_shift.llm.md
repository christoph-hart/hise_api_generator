---
id: fx.pitch_shift.microshift-doubler
node: fx.pitch_shift
domain: scriptnode
category: dsp-network
title: Microshift doubler
summary: Uses a narrow pitch ratio inside a dry/wet mixer to create a subtle widening effect.
useCase: Use this for simple micro-pitch doubling in a ScriptFX insert.
difficulty: intermediate
aliases:
  - microshift
  - pitch doubler
networkName: microshift_doubler
moduleType: ScriptFX
moduleId: MicroshiftDoubler
tags:
  - pitch-shift
  - microshift
  - doubler
relatedNodes:
  - fx.pitch_shift
  - template.dry_wet
  - core.gain
parameters:
  Mix: Dry/wet amount.
  Ratio: Narrow pitch ratio around unity.
---
scriptnode example: fx.pitch_shift

Microshift chorus doubler

Real-time pitch shifting using time-stretch-based resampling, with a range of two octaves up or down.

Context:
  A vocal or synth insert needs a subtle widening/chorus layer without writing a full delay-line chorus. The wet path uses `fx.pitch_shift` with a small ratio offset around `1.0`, then blends it with the dry input for a simple microshift doubler.

Use this when:
  Demonstrate `fx.pitch_shift` as an audio pitch shifter in a block-processing dry/wet effect, with FreqRatio exposed in meaningful musical bounds.

Graph:
```text
microshift_doubler
  ShiftMix          template.dry_wet
    ShiftMix_wet_path
      MicroPitch    fx.pitch_shift
      WetTrim       core.gain
```

Host:
  Module: MicroshiftDoubler
  Network: microshift_doubler
  Host context: Script FX
  Additional builder steps applied: kept the time-stretch node in the default block path.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: template.dry_wet
  Optional: core.gain
  The dry/wet template supplies a practical insert-style mix and keeps the pitch-shifted layer separate from the dry signal. Optional gain can tame the wet layer if trace or listening levels are too high.

Public controls:
  - Mix -> `ShiftMix.DryWet` matched
  - Target range before connection: `[0, 1]`
  - Macro range: `[0, 1]`
  - Default: `0.35`
  - Ratio -> `MicroPitch.FreqRatio` matched
  - Target range before connection: `[0.96, 1.04]`
  - Macro range: `[0.96, 1.04]`
  - Default: `1.015`

Verified connections:
  - `microshift_doubler.Mix -> ShiftMix.DryWet` matched
  - `microshift_doubler.Ratio -> MicroPitch.FreqRatio` matched

Key rules:
  - Keep the pitch shifter in block processing and expect processing latency.
  - Keep FreqRatio close to 1.0 for microshift.

Common mistakes:
  - High CPU cost in polyphonic context: Each voice maintains its own time stretcher with significant memory and CPU overhead. In polyphonic contexts the cost scales linearly with voice count.
  - Requires block-based processing: The node does not support frame-based (per-sample) processing. It must operate in a block-processing container such as container.chain.
  - Introduces processing latency: The time stretcher uses FFT-based overlap-add processing which introduces latency of at least one window length. This latency is not automatically compensated.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MicroshiftDoubler --agent
hise-cli builder set --module MicroshiftDoubler --network microshift_doubler --agent
hise-cli dsp add --module MicroshiftDoubler --type template.dry_wet --id ShiftMix --agent
hise-cli dsp add --module MicroshiftDoubler --type fx.pitch_shift --id MicroPitch --parent ShiftMix_wet_path --agent
hise-cli dsp add --module MicroshiftDoubler --type core.gain --id WetTrim --parent ShiftMix_wet_path --agent
hise-cli dsp remove --module MicroshiftDoubler --node ShiftMix_dummy --agent
hise-cli dsp set --module MicroshiftDoubler --node MicroPitch --param FreqRatio --range "0.96,1.04" --agent
hise-cli dsp set --module MicroshiftDoubler --node MicroPitch --param FreqRatio --value 1.015 --agent
hise-cli dsp set --module MicroshiftDoubler --node ShiftMix --param DryWet --value 0.35 --agent
hise-cli dsp create_parameter --module MicroshiftDoubler --container microshift_doubler --id Mix --range "0,1" --default 0.35 --agent
hise-cli dsp create_parameter --module MicroshiftDoubler --container microshift_doubler --id Ratio --range "0.96,1.04" --default 1.015 --agent
hise-cli dsp connect --module MicroshiftDoubler --source microshift_doubler --source-param Mix --target ShiftMix --param DryWet --matched --agent
# Expose DryWet so the root Mix cable is visible on the inner container.
hise-cli dsp set --module MicroshiftDoubler --node ShiftMix --param ShowParameters --value true --agent
hise-cli dsp connect --module MicroshiftDoubler --source microshift_doubler --source-param Ratio --target MicroPitch --param FreqRatio --matched --agent
```
