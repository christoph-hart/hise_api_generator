---
title: Send
description: "Copies the signal to an internal cable buffer for one or more receive nodes without altering the original signal."
factoryPath: routing.send
factory: routing
polyphonic: true
tags: [routing, send, aux, feedback]
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "routing.receive", type: companion, reason: "Receives the signal sent by this node" }
  - { id: "routing.global_cable", type: alternative, reason: "Sends a control signal across independent networks" }
commonMistakes:
  - title: "Receive Feedback defaults to zero"
    wrong: "Adding a send/receive pair and expecting signal to pass through immediately"
    right: "After connecting, set the receive node's Feedback parameter above 0 to hear the routed signal."
    explanation: "The receive node's Feedback parameter defaults to 0.0, which mutes the received signal entirely. The send node itself has no gain control -- the level is set on the receive side."
  - title: "Matching processing specifications"
    wrong: "Placing send and receive in containers with different buffer sizes or channel counts"
    right: "Ensure both nodes share the same buffer size, channel count, and sample rate."
    explanation: "The internal cable buffer assumes identical processing specifications. Mismatched settings between send and receive can produce silence or glitches."
llmRef: |
  routing.send

  Copies the audio signal into an internal cable buffer for connected receive nodes. The original signal passes through unchanged -- it acts as a tap, not a redirect. Multiple receive nodes can read from the same send.

  Signal flow:
    audio in -> copy to cable buffer -> audio out (unchanged)

  CPU: negligible, polyphonic

  Parameters:
    None. The send node has no user-facing parameters.

  When to use:
    Very commonly used (rank 18, 21 instances). Two main use cases: AUX-style parallel effect chains (send to a reverb/delay bus) and feedback loops for delay-based effects. Always paired with routing.receive.

  Common mistakes:
    Receive Feedback defaults to 0 -- increase it to hear the routed signal.
    Send and receive must share the same buffer size, channel count, and sample rate.

  See also:
    [companion] routing.receive - receives the signal from this node
    [alternative] routing.global_cable - sends control signals across independent networks
---

Copies the audio signal into an internal cable buffer that one or more [routing.receive]($SN.routing.receive$) nodes can read from. The original signal passes through the node unchanged -- it acts as a non-destructive tap rather than a redirect. This makes it suitable for AUX-style parallel effect routing and feedback loops.

Each voice maintains its own cable buffer when used in a polyphonic context, so voice isolation is preserved. Multiple receive nodes can connect to the same send node and each will read the full-level signal independently.

## Signal Path

::signal-path
---
glossary:
  functions:
    copyToCable:
      desc: "Copies the audio data into the internal cable buffer for connected receive nodes"
---

```
// routing.send - non-destructive signal tap
// audio in -> audio out (unchanged)

process(input) {
    copyToCable(input)
    output = input
}
```

::

## Notes

The send node has no parameters. The Connection property (set in the node editor) determines which receive node(s) are linked. The signal level at the receive end is controlled by the receive node's Feedback parameter, not by the send node.

When used in a feedback loop, there is one block of latency between the send and receive. Place the receive node before the processing chain and the send node after it.

**See also:** $SN.routing.receive$ -- receives the signal from this node, $SN.routing.global_cable$ -- sends control signals across independent networks
