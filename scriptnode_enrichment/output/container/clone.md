---
title: container.clone
description: "An array of identical child node chains with configurable processing modes."
factoryPath: container.clone
factory: container
polyphonic: false
tags: [container, parallel, clone]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors:
    - { parameter: "NumClones", impact: "linear", note: "Each active clone runs a full processing pass" }
    - { parameter: "SplitSignal", impact: "mode-dependent", note: "Parallel and Copy modes add buffer overhead; Serial is cheapest" }
seeAlso:
  - { id: "container.split", type: alternative, reason: "Parallel processing with different children instead of identical clones" }
commonMistakes:
  - title: "All clones receive identical parameters"
    wrong: "Expecting each clone to have independent parameter values by default"
    right: "Use control.clone_cable or control.clone_pack to send different values to each clone."
    explanation: "Clone parameters are synchronised across all clones. For per-clone differentiation (detuning, panning, harmonic frequencies), use the dedicated clone control nodes to distribute different values."
  - title: "Clone inside a frame-based container"
    wrong: "Placing a clone container inside container.frame2_block or similar frame containers"
    right: "Keep clone containers outside frame-based containers. Use frame containers inside the clone's children instead."
    explanation: "Clone does not support frame-based processing. Place frame containers inside the cloned child chain if per-sample processing is needed."
  - title: "NumClones not set as first macro control"
    wrong: "Adding NumClones as a secondary parameter or with mismatched ranges across connected nodes"
    right: "Always make NumClones the first macro control. Ensure all nodes connected to it have matching min/max parameter ranges."
    explanation: "If NumClones is not the first macro parameter, or if connected nodes have mismatched ranges, the clone container may fail silently or produce compilation errors."
forumReferences:
  - { tid: 11905, reason: "NumClones compile-time vs runtime semantics" }
  - { tid: 11866, reason: "clone_forward connection rules" }
llmRef: |
  container.clone

  An array of identical child node chains processed in one of three modes: Serial, Parallel, or Copy. The number of active clones is controlled at runtime. All clones share the same structure and synchronised parameters.

  Signal flow (Copy mode, default):
    input --copy--> clone[0] --\
    input --copy--> clone[1] ---+--> sum --> output
    input --copy--> clone[N] --/

  Signal flow (Serial mode):
    input -> clone[0] -> clone[1] -> ... -> clone[N] -> output

  Signal flow (Parallel mode):
    input --passthrough--> output
    silence -> clone[0] --add--> output
    silence -> clone[1] --add--> output

  CPU: low + linear per active clone, monophonic

  Parameters:
    NumClones: 1 - N (integer, default 1)
      Number of active clones. Inactive clones are bypassed.
    SplitSignal: Serial / Parallel / Copy (default Copy)
      Selects the processing mode.

  When to use:
    Additive synthesis, unison voices, cascading filters, feedback delay networks, multistage effects (phasers). Any application requiring duplicated processing paths with per-clone parameter control.

  Key details:
    A clone container can contain up to 128 clones. NumClones only selects how many configured clones are active at runtime.
    Parameters and complex data are synchronised between clone siblings.
    Compiled networks forward external data assignments to every clone.
    The toolbar can show or hide clones, delete every clone except the first, or rebuild up to 128 clones by duplicating the first.
    For complex payloads, build the DSP chain as a separate compiled network first.
    NumClones must be the first macro control with matching ranges on all connected nodes.
    clone_forward connects to the first node only; one clone_forward per target container.

  Common mistakes:
    Clone parameters are synced. Use control.clone_cable or control.clone_pack for per-clone values.
    Clone does not support frame-based processing. Keep it outside frame containers.
    NumClones not set as first macro control causes silent failures or compile errors.

  See also:
    [alternative] container.split -- parallel processing with different children
---

The clone container creates an array of up to 128 identical processing chains. The configured clone count determines the available slots, while `NumClones` selects how many of them are active at runtime. This is the standard way to build additive synthesisers, unison voices, cascading filters, feedback delay networks, and multistage effects such as phasers. Instead of manually duplicating nodes and wiring parameters, clone handles the duplication automatically and keeps all clones synchronised.

The `SplitSignal` parameter selects between three processing modes:

- **Serial**: clones process sequentially, each receiving the previous clone's output (like stacking chains)
- **Parallel**: each clone receives silence, processes it, and the outputs are added to the original signal (useful for synthesis that does not require audio input)
- **Copy** (default): each clone receives a copy of the input, and all outputs are summed together

Clone parameters and complex data are synchronised between sibling clones by default. In compiled networks, external data assignments are forwarded to every clone as well. For per-clone parameter differentiation - different frequencies for harmonics, detuning for unison, or panning for spatial effects - use [control.clone_cable]($SN.control.clone_cable$) or [control.clone_pack]($SN.control.clone_pack$) to distribute different values to each clone.

## Signal Path

::signal-path
---
glossary:
  parameters:
    NumClones:
      desc: "Number of active clones"
      range: "1 - N"
      default: "1"
    SplitSignal:
      desc: "Processing mode: Serial, Parallel, or Copy"
      range: "Serial / Parallel / Copy"
      default: "Copy"
  functions:
    mode select:
      desc: "Routes audio differently based on the SplitSignal value"
---

```
// container.clone - array of identical children
// audio in -> audio out

dispatch(input) {
    mode select(SplitSignal):
        Serial:   clone[0..NumClones] process sequentially in-place
        Parallel: each clone processes silence, output added to input
        Copy:     each clone processes a copy of input, outputs summed
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Configuration
    params:
      - name: NumClones
        desc: "Number of active clones. Inactive clones are bypassed but remain prepared."
        range: "1 - N (dynamic)"
        default: "1"
        hints:
          - type: tip
            text: "This parameter only selects how many configured clones are active. It cannot exceed the configured clone count, which has a maximum of 128."
      - { name: SplitSignal, desc: "Processing mode. Serial chains clones sequentially; Parallel adds clone output to the original; Copy sums copies.", range: "Serial / Parallel / Copy", default: "Copy" }
---
::

### Limitations

- A clone container supports a maximum of 128 clones.
- Each clone's root element must be a container node.
- All clones must have the same structure. Mismatched clones produce an error.
- Clones cannot have modulation or parameter connections to nodes outside the clone or to each other.
- Resizing clones causes a brief audio gap (one buffer) while the internal state is updated.
- When bypassed, only the first clone processes audio.

### Using clone_forward

When forwarding a value into a clone container with [control.clone_forward]($SN.control.clone_forward$), connect it to the first node inside the container only -- propagation to the remaining clones happens automatically. If you have multiple separate clone containers that each need forwarding, use one `clone_forward` node per container.

### Workflow

For complex clone payloads, build the DSP chain as a separate compiled network first, then load it into the clone container. This reduces compile errors and simplifies debugging. Make `NumClones` the first macro control with matching parameter ranges for every connected node.

The clone toolbar can show or hide the clone children without changing processing. Its delete action removes every clone except the first. The duplicate action first performs that same cleanup, then rebuilds the requested clone count by duplicating the first clone; the entered count is limited to `1-128`.

**See also:** $SN.container.split$ -- parallel processing with different children instead of identical clones
