---
title: Branch
description: "A container that processes only the child selected by its Index parameter."
factoryPath: container.branch
factory: container
polyphonic: false
tags: [container, conditional]
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "container.soft_bypass", type: companion, reason: "Click-free switching via soft bypass wrappers" }
commonMistakes:
  - title: "Expecting click-free index switching"
    wrong: "Switching the Index parameter mid-playback with stateful effects as children"
    right: "Use template.softbypass_switchN for click-free switching between processing paths."
    explanation: "Branch switches immediately with no crossfade. Stateful children (filters, delays) may produce clicks when switched. The softbypass_switch templates combine soft_bypass containers with control.xfader for smooth transitions."
llmRef: |
  container.branch

  A conditional container that processes only one child at a time, selected by the Index parameter. Unselected children are idle but remain fully prepared.

  Signal flow:
    input -> child[Index].process -> output
    (all other children: idle)

  CPU: negligible (single dispatch), monophonic

  Parameters:
    Index: 0 - N-1 (integer, default 0)
      Selects which child processes audio. Float values are rounded.

  When to use:
    Algorithm switching, mode selection, or any case where exactly one of several processing paths should be active. For click-free switching, use template.softbypass_switchN instead.

  Common mistakes:
    Index switching is immediate with no crossfade. Use template.softbypass_switchN for click-free transitions.

  See also:
    [companion] container.soft_bypass -- click-free switching via soft bypass wrappers
---

The branch container routes audio through exactly one child at a time, selected by its `Index` parameter. All other children remain idle - they do not process audio, saving CPU. This is useful for algorithm switching, mode selection, or any case where the user chooses between mutually exclusive processing paths.

All children are fully prepared regardless of the current index, so switching is instant. However, index changes take effect immediately with no crossfade, which may cause clicks with stateful effects. For click-free switching, use the `template.softbypass_switchN` nodes instead, which combine [container.soft_bypass]($SN.container.soft_bypass$) wrappers with crossfading.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Index:
      desc: "Selects which child processes audio"
      range: "0 - N-1"
      default: "0"
  functions:
    select child:
      desc: "Routes audio to the child at the current index"
---

```
// container.branch - index-selected processing
// audio in -> audio out

dispatch(input) {
    select child: child[Index].process(input)
    // all other children: idle
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Configuration
    params:
      - { name: Index, desc: "Selects which child processes audio. Float values are rounded to the nearest integer.", range: "0 - N-1 (dynamic)", default: "0" }
---
::

## Notes

- The `Index` parameter range adjusts automatically when children are added or removed. Out-of-range values are clamped.
- When bypassed, no children process audio - it passes through unmodified.
- All children are prepared and reset regardless of the active index. Only `process` and `handleHiseEvent` are index-selective.

**See also:** $SN.container.soft_bypass$ -- click-free switching via soft bypass wrappers
