---
title: Sidechain
description: "A serial container that doubles the channel count by adding empty sidechain channels."
factoryPath: container.sidechain
factory: container
polyphonic: false
tags: [container, serial, sidechain, routing]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "container.multi", type: alternative, reason: "Channel splitting without doubling" }
commonMistakes:
  - title: "Forgetting to route into sidechain channels"
    wrong: "Adding a dynamics node with Sidechain enabled but not routing any signal into the extra channels"
    right: "Use routing nodes (routing.receive, routing.global_cable) to fill the sidechain channels with the desired input signal."
    explanation: "The extra channels created by the sidechain container are zeroed by default. Without routing a signal into them, sidechain-enabled processors detect silence and have no effect."
llmRef: |
  container.sidechain

  A serial container that doubles the channel count by adding zeroed sidechain channels. Children see twice as many channels: the first half is the original audio, the second half is empty sidechain input.

  Signal flow:
    input (ch0, ch1) ->
      children see (ch0, ch1, sc0=0, sc1=0) ->
    output (ch0, ch1)  [only original channels returned]

  CPU: low, monophonic
    One buffer zeroing operation per block for the sidechain channels.

  Parameters:
    None

  When to use:
    Sidechain compression, ducking, or any effect that uses a secondary signal to control processing. Combine with dynamics nodes that have a Sidechain parameter and routing nodes to fill the extra channels.

  Common mistakes:
    Sidechain channels are zeroed by default. Route a signal into them using routing nodes.

  See also:
    [alternative] container.multi -- channel splitting without doubling
---

The sidechain container doubles the channel count by adding empty channels alongside the original audio. In a stereo context, children see four channels: channels 0-1 are the original audio, channels 2-3 are zeroed sidechain inputs. After processing, only the original channels are returned to the parent.

The typical workflow for sidechain processing:

1. Wrap effect nodes in a sidechain container
2. Add a dynamics node (such as [dynamics.comp]($SN.dynamics.comp$)) and enable its `Sidechain` parameter so it uses channels 2-3 for level detection while processing channels 0-1
3. Use routing nodes ([routing.receive]($SN.routing.receive$) or [routing.global_cable]($SN.routing.global_cable$)) to fill the sidechain channels with the desired control signal

## Signal Path

::signal-path
---
glossary:
  functions:
    double channels:
      desc: "Creates zeroed sidechain channels alongside the original audio"
---

```
// container.sidechain - channel doubling for sidechain input
// audio in (N ch) -> audio out (N ch)

dispatch(input) {
    double channels:
        ch[0..N-1] = original audio
        ch[N..2N-1] = zeroed sidechain input
    children.process(all 2N channels)   // serial, in-place
    output = ch[0..N-1]                 // original channels only
}
```

::

## Notes

- Sidechain channels are zeroed at the start of each block. Signal routed into them does not carry over between blocks.
- Sidechain containers cannot be nested inside frame-based containers.

**See also:** $SN.container.multi$ -- channel splitting without doubling
