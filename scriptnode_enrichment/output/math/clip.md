---
title: math.clip
description: "Hard-clips the signal to a symmetric range."
factoryPath: math.clip
factory: math
polyphonic: true
tags: [math, distortion, clipping]
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "math.tanh", type: alternative, reason: "Soft clipping via hyperbolic tangent" }
commonMistakes: []
llmRef: |
  math.clip

  In normal block processing, hard-clips the signal to the symmetric range [-Value, Value]. Samples outside the range are truncated to the boundary.

  Frame-container discrepancy:
    The source's single-sample path computes s * clamp(s, -Value, Value), so frame containers do not produce the same result as normal block processing.

  Signal flow:
    audio in -> clamp to [-Value, Value] -> audio out

  CPU: negligible, polyphonic

  Parameters:
    Value (0.0 - 1.0, default 1.0): Symmetric clipping threshold. At 1.0, no clipping occurs for signals in the normal [-1, 1] range.

  When to use:
    Use for hard clipping and distortion effects. For softer saturation that avoids the harsh harmonics of hard clipping, use math.tanh instead.

  See also:
    alternative math.tanh -- soft clipping via hyperbolic tangent
---

In normal block processing, this node clamps every sample to the symmetric range [-Value, Value]. Any sample exceeding the threshold is truncated to the boundary, producing hard clipping. At a Value of 1.0, signals already within the normal [-1, 1] range pass through unchanged.

> [!Warning:Frame containers behave differently] The source's single-sample path computes `s * clamp(s, -Value, Value)` rather than the normal block clamp. Nodes placed in frame containers therefore produce a different, nonlinear result.

For softer saturation that rounds off peaks instead of truncating them, use [math.tanh]($SN.math.tanh$) instead.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Value:
      desc: "Symmetric clipping threshold"
      range: "0.0 - 1.0"
      default: "1.0"
---

```
// math.clip - normal block processing
// audio in -> audio out

process(input) {
    output = clamp(input, -Value, Value)
}
```

::

In a frame container, the source instead applies:

```javascript
output = input * clamp(input, -Value, Value)
```

## Parameters

::parameter-table
---
groups:
  - params:
      - { name: Value, desc: "Symmetric clipping limit for normal block processing. At 1.0, signals in the normal range pass through unchanged.", range: "0.0 - 1.0", default: "1.0" }
---
::

**See also:** $SN.math.tanh$ -- soft clipping via hyperbolic tangent
