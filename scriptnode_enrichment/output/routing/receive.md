---
title: Receive
description: "Receives audio from a connected send node and adds it to the current signal, scaled by the Feedback parameter."
factoryPath: routing.receive
factory: routing
polyphonic: true
tags: [routing, receive, aux, feedback]
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "routing.send", type: companion, reason: "Sends the signal that this node receives" }
  - { id: "routing.global_cable", type: alternative, reason: "Receives control signals from independent networks" }
commonMistakes:
  - title: "Feedback defaults to zero"
    wrong: "Connecting a receive node and expecting audio to pass through immediately"
    right: "Set the Feedback parameter above 0 to hear the received signal."
    explanation: "Feedback defaults to 0.0, which completely mutes the received signal. This is intentional to prevent unexpected signal when first adding the node."
  - title: "Feedback is additive not crossfade"
    wrong: "Treating Feedback as a wet/dry mix between the input and received signal"
    right: "Feedback scales only the received signal, which is then added to the existing input: output = input + received * Feedback."
    explanation: "The input signal always passes through at full level. Feedback controls how much of the received signal is mixed on top. At Feedback = 1.0 the full received signal is added; the original is never attenuated."
llmRef: |
  routing.receive

  Receives audio from a connected send node's cable buffer and adds it to the current signal, scaled by the Feedback parameter. Formula: output = input + received * Feedback. The input signal always passes through at full level.

  Signal flow:
    audio in + (cable buffer * Feedback) -> audio out

  CPU: negligible, polyphonic

  Parameters:
    Feedback: 0.0 - 1.0 (default 0.0). Scales the received signal before adding to the input. NormalizedPercentage display.

  When to use:
    Very commonly used (rank 17, 21 instances). Always paired with routing.send. Two main patterns: AUX-style parallel effects and feedback delay loops.

  Common mistakes:
    Feedback defaults to 0 -- must be increased to hear the routed signal.
    Feedback is additive, not a wet/dry crossfade.

  See also:
    [companion] routing.send - sends the signal that this node receives
    [alternative] routing.global_cable - control signal routing across networks
---

Receives audio from a connected [routing.send]($SN.routing.send$) node and adds it to the current signal. The received signal is scaled by the Feedback parameter before being mixed in: `output = input + received * Feedback`. The existing signal in the buffer always passes through at full level -- Feedback controls only the level of the received signal, not a wet/dry crossfade.

When no send node is connected, the receive passes its input through unchanged. Each voice reads from its own cable buffer in polyphonic contexts, maintaining voice isolation.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Feedback:
      desc: "Scales the received signal before adding to the input"
      range: "0.0 - 1.0"
      default: "0.0"
  functions:
    readFromCable:
      desc: "Reads audio data from the connected send node's cable buffer"
---

```
// routing.receive - additive signal receiver
// audio in + cable -> audio out

process(input) {
    received = readFromCable()
    output = input + received * Feedback
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Signal
    params:
      - { name: Feedback, desc: "Scales the received signal before adding it to the input. At 0 the received signal is muted; at 1 the full signal is added.", range: "0.0 - 1.0", default: "0.0" }
---
::

## Notes

In a feedback loop configuration (receive placed before the processing, send placed after), there is one block of latency between the send and receive. This is inherent to the circular buffer design and cannot be eliminated.

When disconnected, the receive node behaves as a transparent pass-through -- it does not output silence.

**See also:** $SN.routing.send$ -- sends the signal that this node receives, $SN.routing.global_cable$ -- control signal routing across independent networks
