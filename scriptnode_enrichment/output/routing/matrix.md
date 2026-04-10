---
title: Matrix
description: "Applies an arbitrary channel routing matrix to the signal, configured through a visual editor."
factoryPath: routing.matrix
factory: routing
polyphonic: false
tags: [routing, matrix, channels, static]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors:
    - { parameter: "channel count", impact: "linear", note: "Cost scales linearly with channel count; common stereo patterns are optimised" }
seeAlso:
  - { id: "routing.selector", type: alternative, reason: "Dynamic channel routing with modulatable parameters" }
llmRef: |
  routing.matrix

  Applies an arbitrary channel routing defined by a visual matrix editor. Each source channel maps to a destination channel; multiple sources can be summed into one destination. Channels mapped to no destination are muted. Supports send channels for parallel routing.

  Signal flow:
    multichannel in -> apply routing map -> multichannel out

  CPU: low, monophonic. Common stereo patterns (swap, mono sum) are optimised.

  Parameters:
    None. Routing is configured via the matrix editor (stored as EmbeddedData property).

  When to use:
    Used in 8 networks (rank 49). For static channel routing that does not need to change at runtime. Common uses: swapping left/right, summing to mono, routing multichannel signals. For dynamic routing, use routing.selector instead.

  See also:
    [alternative] routing.selector - dynamic channel routing with modulatable parameters
---

Applies an arbitrary channel routing to the signal. The routing is configured through a visual matrix editor where you click cells to connect source channels to destination channels. Multiple source channels can be summed into one destination, and channels with no mapping are muted.

The node also supports send channels (shift-click in the matrix editor), which provide a secondary destination for each source channel. This allows routing the same input to two different output channels without signal loss.

Common stereo patterns -- swapping left and right, summing to mono, copying one channel to both -- are detected automatically and processed more efficiently. For dynamic channel routing that changes at runtime, use [routing.selector]($SN.routing.selector$) instead.

## Signal Path

::signal-path
---
glossary:
  functions:
    applyRoutingMap:
      desc: "Routes each source channel to its mapped destination, summing where multiple sources share a destination"
---

```
// routing.matrix - static channel routing
// multichannel in -> multichannel out

process(channels) {
    temp = copy(channels)
    zero(channels)

    for each source in temp:
        dest = routingMap[source]
        if dest != muted:
            channels[dest] += temp[source]
}
```

::

## Notes

The routing is stored as an EmbeddedData property on the node and does not change at runtime. The matrix adapts to the channel count of the signal path -- it operates on however many channels are available, up to 16.

The matrix has no user-facing parameters. All configuration is done through the visual editor in the node's property panel.

**See also:** $SN.routing.selector$ -- dynamic channel routing with modulatable parameters
