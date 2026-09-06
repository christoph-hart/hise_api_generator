---
id: envelope.silent_killer.silent-envelope-cleanup
node: envelope.silent_killer
domain: scriptnode
category: dsp-network
title: Silence-based envelope cleanup
summary: Terminates a Script Envelope voice after its release signal reaches silence.
useCase: Use this fallback when the modulation path has no explicit gate output.
difficulty: intermediate
aliases:
  - silence-based envelope cleanup
tags:
  - envelope
  - voice-lifecycle
  - scriptnode
relatedNodes:
  - envelope.silent_killer
  - envelope.voice_manager
  - math.fill1
networkName: silent_envelope_cleanup
moduleType: ScriptEnvelopeModulator
moduleId: SilentEnvelopeCleanup
parameters:
  CleanupActive: Enables or disables silence-based cleanup.
---
scriptnode example: envelope.silent_killer

Silence-based Script Envelope cleanup

Sends a voice reset message when silence is detected after note-off, providing automatic voice cleanup.

Context:
  A custom Script Envelope module generates its modulation signal by shaping a constant 1.0 value from `math.fill1`. Instead of using an explicit Gate output, `envelope.silent_killer` watches the generated modulation signal and resets the voice once note-off has occurred and the signal has fallen to silence.

Use this when:
  Demonstrate how `envelope.silent_killer` can monitor a control/modulation signal for silence, not just an audible audio path.

Graph:
```text
silent_envelope_cleanup
  EnvelopeSeed          math.fill1
  ReleaseEnvelope       envelope.simple_ar
  SilentCleanup         envelope.silent_killer
```

Host:
  Module: SilentEnvelopeCleanup
  Network: silent_envelope_cleanup
  Host context: Script Envelope
  Additional builder steps applied: topology and lifecycle setup from Phase 2.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: math.fill1, envelope.simple_ar
  `math.fill1` provides the static 1.0 control signal, and `envelope.simple_ar` shapes it into a signal that eventually reaches silence. `envelope.silent_killer` then demonstrates fallback cleanup by watching that modulation signal.

Public controls:
  - CleanupActive -> `SilentCleanup.Active` matched
  - Target range before connection: `[Off, On]`
  - Macro range: `[Off, On]`
  - Default: `On`

Verified connections:
  - Public parameter connections match the Phase 4 script.
  - Lifecycle output connections were verified live where available.

Key rules:
  - Preserve the verified polyphonic lifecycle context.

Common mistakes:
  - Threshold parameter has no effect: The per-block silence check uses its own hardcoded threshold. The Threshold parameter exists in the interface but does not influence the detection.
  - Silence during note-on does not kill the voice: The node tracks note-on/off state internally. Silence detection only fires after note-off to avoid false kills during intentional momentary silences.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id SilentEnvelopeCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module SilentEnvelopeCleanup --network silent_envelope_cleanup --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type envelope.simple_ar --id ReleaseEnvelope --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type envelope.silent_killer --id SilentCleanup --agent
hise-cli dsp create_parameter --module SilentEnvelopeCleanup --container silent_envelope_cleanup --id CleanupActive --range "0,1" --default 1 --agent
hise-cli dsp connect --module SilentEnvelopeCleanup --source silent_envelope_cleanup --source-param CleanupActive --target SilentCleanup --param Active --matched --agent
```
