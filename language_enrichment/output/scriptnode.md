---
title: Scriptnode
description: "HISE's visual DSP graph system for building signal processing networks from nodes, containers, parameters, modulation, and routing"

guidance:
  summary: >
    Conceptual reference for the scriptnode system. Covers the DSP network tree
    model, XML representation, editing surfaces, containers and nodes,
    processing context, channel handling, MIDI event flow, parameters and
    ranges, properties, modulation sources and targets, connection scaling,
    local and global routing, polyphony, voice management, bypassing, and the
    differences between interpreted editing and compiled networks. Treats
    scriptnode as a visual DSP language: there is no text syntax, but there are
    rules, conventions, and mental models that determine how a network behaves.
  concepts:
    - scriptnode
    - DSP network
    - signal flow
    - XML
    - nodes
    - factories
    - containers
    - processing context
    - sample rate
    - block size
    - channel count
    - MIDI events
    - parameters
    - ranges
    - properties
    - modulation
    - connections
    - scaled connections
    - unscaled connections
    - routing
    - send receive
    - global_cable
    - local_cable
    - polyphony
    - voice management
    - bypass
  prerequisites: []
  complexity: intermediate
---

Scriptnode is HISE's visual DSP graph system. You build a network by placing nodes inside containers, then connecting parameters and modulation outputs to control how signal flows through the tree.

Scriptnode is not a language in the usual sense. There are no keywords or syntax rules for a text parser. The useful way to think about it is as a visual DSP language: nodes are the operations, containers are the control flow, parameter cables are assignments, and the processing context determines what each node actually receives.

In practice, you will use scriptnode for three things:

- **Building DSP networks** - filters, waveshapers, modulation chains, synthesis voices, parallel effects, routing matrices, and reusable DSP building blocks.
- **Bridging HISE and custom DSP** - expose HISE modulation chains inside a network, control network parameters from UI components, and send modulation values back out.
- **Preparing DSP for deployment** - edit networks live in the HISE IDE, automate graph edits from `hise-cli`, then compile stable networks for hardcoded modules or exported plugins.

> [!Tip:Think in contexts, not just nodes] A node's behaviour depends on where it is placed. The same node can receive a different sample rate, block size, channel count, MIDI policy, or voice context when it is moved into another container.

**See also:** [Usage in HISE](#usage-in-hise) -- editing, scripting, and compiling networks, $LANG.snex$ -- custom DSP code inside scriptnode, $LANG.faust$ -- Faust integration, $LANG.cpp-dsp-nodes$ -- compiled custom nodes


## The System

### Networks are Trees

A scriptnode DSP network is a tree. The root is a container, and every child is either another container or a leaf node.

```
container.chain
  core.gain
  container.split
    filters.svf
    fx.reverb
  routing.send
```

The tree structure defines the audio signal flow. A `container.chain` processes children one after another, while a `container.split` processes branches in parallel and sums the result. Parameter cables and modulation cables can cross the tree, but the audio processing order still comes from the container hierarchy.

This tree model is the main mental model for scriptnode:

- Parent containers decide how children are processed.
- Leaf nodes do the actual DSP, control, analysis, or routing work.
- Children inherit a processing context from their parent.
- Some containers modify the context before passing it on.

The root container is usually a `container.chain`, because most networks start as a serial signal path.

### XML Representation

The natural stored form of a scriptnode network is XML. The XML records the node tree, node IDs, parameter values, ranges, connections, properties, layout, and embedded data references.

You will encounter scriptnode XML in two forms:

| Form | Where it lives | Use case |
| --- | --- | --- |
| Embedded network | Inside the project XML tree | Small project-local networks and quick experiments |
| Network file | `DspNetworks/` project files | Reusable networks and networks intended for compilation |

The XML is useful as a persistence format and mental model, but it is not meant to be handwritten. Use the scriptnode editor, `hise-cli /dsp`, or the scripting API to create and modify networks.

> [!Warning:Do not treat XML as the authoring language] Editing the XML directly bypasses the validation that the editor and CLI perform. Duplicate IDs, invalid connections, stale ranges, or missing data references can make a network fail to load or compile.

### Editing Surfaces

There are three practical ways to edit a network.

| Surface | Best for | Notes |
| --- | --- | --- |
| Scriptnode UI | Interactive design, listening, debugging, layout | The main workflow for building networks by hand |
| `hise-cli /dsp` | Repeatable edits, tests, automation | Agent-friendly and suitable for scripted graph construction |
| Scripting API | Runtime network creation and control | Useful when HiseScript needs to create or load a network |

The UI is the most direct way to understand signal flow because the container tree, parameter cables, node headers, and modulation outputs are visible together. When cables become visually noisy, reduce cable opacity in the editor so the signal path remains readable.

**See also:** $LANG.hsc#dsp$ -- edit scriptnode graphs from `hise-cli`, $API.Engine.createDspNetwork$ -- create DSP networks from HiseScript


### Factories and Node IDs

Nodes are named by factory path:

```
factory.node
```

Examples:

| Factory path | Meaning |
| --- | --- |
| `core.gain` | Core gain processor |
| `filters.svf` | State-variable filter |
| `control.pma` | Control value processor |
| `container.split` | Parallel container |
| `routing.send` | Local audio send |

Factories group nodes by purpose.

| Factory | Typical role |
| --- | --- |
| `container` | Tree structure and processing context |
| `core` | Basic DSP, custom-code nodes, modulation bridge nodes |
| `control` | Parameter and modulation value processing |
| `filters` | Filter algorithms |
| `math` | Audio-rate mathematical operations |
| `routing` | Audio and modulation routing |
| `envelope` | Envelope generators and voice helpers |
| `analyse` | Meters and diagnostic nodes |

**See also:** $SN.core.gain$ -- basic gain node, $SN.filters.svf$ -- filter node, $SN.control.pma$ -- parameter multiply-add node


### Containers

Containers are tree parents. They contain child nodes and define how those children process the incoming signal.

| Container | Signal flow | Main use |
| --- | --- | --- |
| `container.chain` | Serial | Standard signal chain: child 1 into child 2 into child 3 |
| `container.split` | Parallel, then sum | Dry/wet paths, parallel bands, layered processing |
| `container.multi` | Parallel channel slices | Multi-channel processing where each child handles a channel range |
| `container.branch` | One selected child | Switchable algorithms or modes |
| `container.clone` | Repeated child chain | Unison, stacked oscillators, repeated filter banks |

Specialised serial containers also change the processing context for their children.

| Container | Context change | Use for |
| --- | --- | --- |
| `container.modchain` | Mono control-rate processing | Modulation generators and control signals |
| `container.midichain` | Enables MIDI event processing | MIDI-aware child chains |
| `container.no_midi` | Blocks MIDI events | Isolating DSP from note or controller events |
| `container.frame*_block` | Block size becomes 1 | Sample-accurate processing and modulation |
| `container.fix*_block` | Fixed sub-block size | Algorithms that need predictable block chunks |
| `container.oversample*` | Higher sample rate and block size | Non-linear processors that benefit from oversampling |
| `container.sidechain` | Adds sidechain channels | Dynamics or analysis driven by a secondary signal |
| `container.soft_bypass` | Crossfaded bypass | Click-free bypass of a child chain |

> [!Tip:Containers are not just folders] Moving a node into a different container can change its sample rate, block size, channel count, MIDI access, and modulation update rate.

**See also:** $SN.container.chain$ -- serial container, $SN.container.split$ -- parallel summing container, $SN.container.multi$ -- channel-splitting container, $SN.container.modchain$ -- control-rate container


### Nodes

Leaf nodes are the building blocks of the DSP network. A node can process audio, produce a modulation value, analyse a signal, route audio, or transform a control value.

Most nodes have:

- A header with the node ID and state indicators.
- Optional body UI for code, graphs, tables, or displays.
- Parameters shown as knobs or sliders.
- Optional modulation outputs or routing slots.

Not every node is in the audio signal path. `control.*` nodes often live in the tree but do not process audio. They receive parameter values, transform them, and send results through connections.

| Node kind | Example | Signal role |
| --- | --- | --- |
| Audio processor | `filters.svf`, `core.gain`, `math.tanh` | Reads and writes audio samples |
| Control processor | `control.pma`, `control.converter` | Transforms parameter or cable values |
| Modulation source | `envelope.ahdsr`, `control.midi` | Sends values to target parameters |
| Modulation bridge | `core.global_mod`, `core.extra_mod` | Reads HISE modulation signals into scriptnode |
| Routing node | `routing.send`, `routing.receive`, `routing.global_cable` | Moves signals or values across graph boundaries |
| Analysis node | `analyse.fft`, `analyse.oscilloscope` | Displays or measures signal content |

### Signal

In scriptnode, a signal is more than a single audio channel. It is the bundle that flows through the network:

- Audio samples for one or more channels.
- MIDI events travelling alongside the audio.
- A sample rate.
- A maximum block size.
- A channel count.
- A monophonic or polyphonic voice context.

Most audio nodes process every channel they receive. A gain node does not need separate left and right versions. If the surrounding context is mono, it processes one channel. If the context is stereo, it processes two. If the network is wider, it processes the available channels unless the node or container explicitly fixes the channel count.

Use the `analyse.specs` diagnostic node when you need to inspect the signal context at a specific point in the graph.

**See also:** $SN.analyse.specs$ -- inspect the local signal specification

### Processing Context

Every node is prepared with a processing context. This context is inherited from the host module and modified by containers.

| Context field | Meaning | Changed by |
| --- | --- | --- |
| Sample rate | The rate used by child DSP calculations | Oversampling, repitching, host changes |
| Block size | Maximum number of samples processed at once | Frame containers, fixed-block containers, control-rate containers |
| Channel count | Number of audio channels in the current signal | Host layout, multi containers, sidechain containers, fixed-channel wrappers |
| Voice context | Whether node state is shared or per voice | Monophonic vs polyphonic host modules |

Nodes adapt to the context they receive. This is why the same network can often work in mono, stereo, or wider channel layouts without duplicating nodes manually.

> [!Warning:Context changes are real DSP changes] Oversampling changes the sample rate seen by child filters and oscillators. Frame containers change update timing. Fixed-block containers change how often child state is advanced. Do not move nodes across these boundaries casually after a patch is tuned.

### Channel Handling

Scriptnode tries to keep channel handling implicit. Most nodes operate on however many channels the current signal contains. Containers are the main exception because they can reinterpret or redistribute channels.

| Container | Channel rule |
| --- | --- |
| `container.chain` | Children share the same channel count |
| `container.split` | Each branch receives the same channel count, outputs are summed |
| `container.multi` | Children receive channel slices; total width is divided among children |
| `container.sidechain` | Child chain sees additional sidechain channels |
| `container.modchain` | Child chain is mono because it carries a control signal |
| `container.frame2_block` | Child chain is fixed to stereo frame processing |
| `container.framex_block` | Child chain processes frames with dynamic channel count |

When compiling a network, the root channel count becomes part of the compiled network. A network compiled for stereo should not be treated as a generic four-channel effect later.

### MIDI Event Flow

MIDI events travel as a hidden part of the signal. They are not audio samples, but they move through the network alongside the current audio block.

Nodes can choose to react to MIDI events. Typical examples:

- Oscillator nodes use note-on events to set frequency.
- Envelope nodes use note-on and note-off events to open and close gates.
- MIDI control nodes convert velocity, note number, controller, or random note events into modulation values.
- Voice-management nodes use note lifecycle information to decide when a voice can stop.

MIDI policy depends on the container and host context.

| Context | Default MIDI behaviour |
| --- | --- |
| Polyphonic networks | MIDI is enabled by default because voices need note events |
| Monophonic networks | MIDI is disabled by default unless a container or node requests it |
| `container.midichain` | Forces event processing for children |
| `container.no_midi` | Blocks MIDI events from children |
| `container.branch` | Only the selected child receives events |
| `container.chain` | Children receive events in order |

For sample-accurate MIDI-driven changes, place the relevant nodes in a MIDI-aware or frame-based context. Otherwise updates may happen once per block or at the current control-rate interval.

### Parameters

Parameters are realtime-controllable values on nodes and containers. They use an `ID -> Number` model: each parameter has an identifier and a numeric value.

Node parameters are static. A `core.gain` node exposes the parameters defined by that node type. Container parameters are dynamic macro parameters that you create on the container and connect to child parameters.

| Owner | Parameter count | Typical role |
| --- | --- | --- |
| Leaf node | Fixed by node type | Directly controls DSP or node behaviour |
| Container | User-created | Macro control for one or more child parameters |

Container parameters are how you design a reusable network interface. Instead of exposing every internal filter, gain, and control node, create a small set of root parameters and connect them to the internal targets.

> [!Tip:Use container parameters as the public API] Treat a reusable network like a module. Internal node parameters are implementation details; root container parameters are the controls you expose to HISE, UI components, automation, and compiled hardcoded modules.

### Parameter Ranges

Scriptnode parameter ranges are editable. A parameter has a current value, but it also has a range that defines how incoming normalised values map to useful units.

| Range field | Meaning |
| --- | --- |
| Minimum | Lowest target value |
| Maximum | Highest target value |
| SkewFactor | Curves normalised values towards one side of the range |
| StepSize | Quantises values into discrete steps |
| Inverted | Swaps the direction of the mapping |

`SkewFactor` and `StepSize` are alternative range behaviours. Use skew for continuous curved response, such as frequency. Use step size for discrete choices, such as mode indices or integer counts.

Changing a target range is often the cleanest way to adjust modulation depth. For example, a normalised modulation source can still control a filter over only 300 Hz to 2000 Hz if the target parameter range is set to that window.

### Properties

Properties are non-realtime node settings. They configure operating modes, code strings, file references, block sizes, algorithm choices, layout options, or other static behaviour.

| Aspect | Parameter | Property |
| --- | --- | --- |
| Value type | Number | Usually String, Boolean, or menu value |
| Realtime control | Yes | No |
| Modulation target | Yes | No |
| Typical UI | Knob or slider | Combo box, text editor, file selector, toggle |
| Example | Gain amount | Filter mode, expression code, smoothing algorithm |

Properties can be changed during editing, but they are not audio-rate controls. When a network is compiled, many property choices become fixed parts of the compiled DSP structure.

> [!Warning:Use parameters for playback controls] If a value needs to move during playback, make it a parameter. If it selects an algorithm, code snippet, data source, or structural mode, it is probably a property.

### Modulation

Scriptnode has two modulation directions.

| Direction | Meaning | Examples |
| --- | --- | --- |
| Scriptnode source to parameter | A node computes a value and sends it to one or more target parameters | `control.midi`, `envelope.ahdsr`, `control.pma` |
| HISE modulation into scriptnode | A node reads a HISE modulation chain and exposes it inside the network | `core.global_mod`, `core.extra_mod`, `core.pitch_mod`, `core.matrix_mod` |

A modulation source can feed many targets. A target parameter can only have one direct modulation source through a given connection slot. If several values need to contribute, combine them first with control nodes such as `control.pma`, `control.blend`, `control.xfader`, or a container parameter that fans out to multiple internal targets.

Modulation update rate depends on context.

| Context | Typical update rate |
| --- | --- |
| Frame processing | Once per sample |
| Normal block processing | Once per block for block-level sources |
| Control-rate containers | Reduced control rate |
| MIDI event sources | When relevant MIDI events arrive |

If a modulation cable causes zipper noise, inspect where the source is placed. Moving the source into a frame or more suitable context can change the update rate.

**See also:** $SN.core.global_mod$ -- read global modulators, $SN.core.extra_mod$ -- read extra modulation slots, $SN.core.pitch_mod$ -- read pitch modulation, $SN.control.midi$ -- convert MIDI events to modulation


### Connections

Connections carry values from a source to a target. The source can be a container parameter or a modulation output. The target is usually a node parameter, a container parameter, a bypass input on `container.soft_bypass`, or a multi-output switch target.

The important rule is range conversion. By default, scriptnode treats the source value as belonging to the source range, converts it to `0..1`, then converts that normalised value into the target range.

| Mode | Value flow | Use when |
| --- | --- | --- |
| Scaled | Source value -> source range to `0..1` -> target range -> target value | The source is a normalised control and the target range should define depth |
| Unscaled | Source value -> target value | The source already produces the exact value the target needs |
| Same range optimisation | Source value -> target value | Source and target ranges match exactly |

Examples:

| Situation | Preferred mode |
| --- | --- |
| Macro knob controls filter cutoff over a custom range | Scaled |
| `control.converter` outputs a converted value | Unscaled |
| `control.cable_expr` computes an exact formula result | Unscaled |
| One parameter mirrors another with identical range | Same range |

Unscaled parameters show a `U` icon in the editor. Some nodes have explicit unscaled variants, such as `control.pma_unscaled`, when the raw input value must pass through without target-range conversion.

> [!Tip:Match ranges when you can] If a source and target should represent the same unit, give them the same range. This avoids unnecessary conversion and makes the cable easier to reason about.

### Routing

Routing moves audio or modulation values without following the normal parent-child signal path.

| Mechanism | Carries | Scope | Typical use |
| --- | --- | --- | --- |
| `routing.send` / `routing.receive` | Audio signal | Within one network | Feedback loops, cross-branch audio routing |
| `routing.global_send` / `routing.global_receive` | Audio signal | Across networks in the same instance | Shared audio routing between separate networks |
| `routing.global_cable` | `0..1` control values | Across HISE and scriptnode networks | Global modulation/control values |
| `routing.local_cable` / `routing.local_cable_unscaled` | Control values | Within one network | Organising many parameter cables through named control paths |

For audio sends and receives, the processing specs must match. Sample rate, channel count, and block-size assumptions need to line up. If they do not, the receive side cannot safely add the incoming signal.

Use routing deliberately:

- Use local send/receive pairs for feedback loops inside one network.
- Use `global_cable` for modulation or control values that need to travel across HISE boundaries.
- Use `local_cable` organisation when many targets need the same value and direct cables would make the graph unreadable.
- Avoid global audio routing unless separate networks genuinely need to share audio.

**See also:** $SN.routing.send$ -- local audio send, $SN.routing.receive$ -- local audio receive, $SN.routing.local_cable$ -- network-scoped control-value cable, $SN.routing.local_cable_unscaled$ -- unscaled local cable, $SN.routing.global_cable$ -- global control-value cable, $SN.routing.global_send$ -- global audio send, $SN.routing.global_receive$ -- global audio receive


### Polyphony

Scriptnode has built-in polyphony. A polyphonic network gives nodes with state a separate state per voice. A monophonic network shares state across the whole signal.

Polyphonic nodes show `[poly]` in the node header. This is a quick way to see whether a node keeps per-voice state.

| Context | State model |
| --- | --- |
| Monophonic network | One shared state |
| Polyphonic network | One state per active voice for poly-capable nodes |
| Mono-only node in polyphonic network | Shared state, even inside the polyphonic graph |

Polyphony affects MIDI handling too. Note-on, note-off, controller, pitch wheel, and aftertouch events are routed to the relevant voice context so envelopes, oscillators, and per-voice modulators can respond independently.

### Voice Management

When a scriptnode network generates sound in a polyphonic context, HISE needs to know when each voice is finished. Otherwise voices can remain alive after they are inaudible.

Voice-management nodes solve this by telling the host when a voice can be reset. Use them when you build a custom synth voice, long envelope, or polyphonic effect that has a tail.

Typical voice-management nodes include:

- `envelope.voice_manager` for explicit voice lifetime control.
- `envelope.silent_killer` for ending voices after the signal becomes silent.
- Envelope nodes that expose gate or active-state information for related routing.

> [!Warning:Polyphonic tails need a reset path] If a polyphonic network has a tail and no voice-management path, voices can stay alive longer than expected. Add an appropriate voice-management node when building sound-generating networks.

**See also:** $SN.envelope.voice_manager$ -- voice lifetime helper, $SN.envelope.silent_killer$ -- silence-based voice reset, $MODULES.PolyScriptFX$ -- polyphonic scriptnode effect host


### Bypass

Scriptnode has two practical bypass behaviours.

| Bypass type | Behaviour | Use for |
| --- | --- | --- |
| Hard bypass | Immediately skips processing | Simple on/off switching where clicks are not a concern |
| Soft bypass | Crossfades between processed and dry signal | Click-free switching of effect chains |

Use `container.soft_bypass` when a bypass state is controlled from a parameter or modulation source. It is the container designed for smooth bypass automation. Regular containers can be bypassed in the editor, but they are not the right target for dynamic click-free bypass control.

**See also:** $SN.container.soft_bypass$ -- crossfaded bypass container


## Usage in HISE

### Build networks in the Scriptnode editor

The editor is the primary workflow for designing networks. Start with a root `container.chain`, add nodes, then introduce containers only when the signal flow demands them.

A practical build order:

1. Create the serial audio path first.
2. Add parallel containers for dry/wet or band splitting.
3. Add modulation sources and control nodes.
4. Promote important internal controls to container parameters.
5. Adjust parameter ranges at the final target parameters.
6. Add diagnostic nodes such as `analyse.specs`, meters, or oscilloscopes while debugging.
7. Remove or bypass diagnostics before compiling or shipping if they are not needed.

### Edit networks with hise-cli

The `hise-cli /dsp` mode lets you create and modify scriptnode graphs from commands. Use it when you need repeatable setup, automated tests, or agent-visible edits.

This is especially useful for:

- Creating standard test networks.
- Verifying parameter wiring.
- Rebuilding a graph after changing node IDs or layout.
- Running the same network construction on multiple projects.

**See also:** $LANG.hsc#dsp$ -- command reference for `/dsp` mode


### Control networks from HiseScript

HiseScript can create, load, and control DSP networks through the scripting API. Use this when your interface needs to load different networks, set parameters, or bridge UI components to scriptnode controls.

The cleanest pattern is to expose a small set of container parameters at the network root and bind UI controls to those parameters. Avoid scripting direct access to many internal nodes unless the network is genuinely part of the script logic.

**See also:** $LANG.hisescript$ -- scripting language reference, $API.Engine.createDspNetwork$ -- create a DSP network from script


### Use scriptnode with custom DSP languages

Scriptnode can host several custom DSP languages as nodes.

| If you want to... | Use |
| --- | --- |
| Write quick C++-style DSP inside HISE | $LANG.snex$ |
| Use concise functional DSP and Faust libraries | $LANG.faust$ |
| Import a Max/RNBO patch | $LANG.rnbo$ |
| Write full C++ with JUCE and scriptnode building blocks | $LANG.cpp-dsp-nodes$ |

These languages run inside the same graph model. A SNEX node, Faust node, or C++ DSP node still receives the current scriptnode processing context and participates in the same parameter, routing, and modulation systems.

### Compile networks

Compiled scriptnode networks are faster to load, easier to deploy as hardcoded modules, and less dependent on live graph editing. Compilation converts the visual network into a fixed DSP structure.

Compilation preserves the important DSP design:

- Node topology.
- Container structure.
- Parameter ranges and default values.
- Parameter and modulation connections.
- Channel count.
- Polyphony support.
- Embedded tables, slider packs, audio files, and routing matrices where supported.
- SNEX, Faust, and expression code where supported.

Compilation also fixes some choices that are editable in the live graph:

- Container structure cannot be changed at runtime.
- Parameter ranges are fixed.
- Oversampling factors and fixed block sizes are fixed.
- Many property values become fixed algorithm choices.
- Some global or editor-only routing nodes are not compileable.

> [!Tip:Compile stable networks, not sketches] Keep networks interpreted while the structure is changing. Compile once the node tree, parameter interface, and data dependencies are stable.

**See also:** $VIDEO.compile-scriptnode-networks$ -- compiling scriptnode networks, $LANG.cpp-dsp-nodes$ -- writing compiled custom nodes


## Differences from a Text Language

Scriptnode has language-like rules, but they are expressed as graph structure rather than text syntax.

| Text language concept | Scriptnode equivalent |
| --- | --- |
| Source file | DSP network XML or network file |
| Statement order | Container child order |
| Function call | Node processing step |
| Scope | Container boundary |
| Public API | Root container parameters |
| Variable assignment | Parameter value or property value |
| Control flow | Container type: chain, split, branch, multi, clone |
| Type/context | Processing context: sample rate, block size, channels, voice mode |
| Import/library | Node factory path or project node |
| Compilation | Export network to a fixed C++ DSP structure |

### No textual syntax

There is no textual grammar for everyday scriptnode authoring. The graph itself is the program. The rules are structural:

- Children are processed according to the parent container.
- Parameters receive numeric values.
- Properties configure non-realtime modes.
- Connections convert or forward values between ranges.
- MIDI events flow only through MIDI-aware paths.
- Polyphonic nodes keep per-voice state only in polyphonic contexts.

### Encapsulation matters

Container parameters are the intended boundary between a reusable network and its internals. A parent should control a child through exposed parameters, not by depending on a deeply nested internal node unless that internal node is deliberately part of the design.

This convention matters more after compilation, because the internal structure becomes fixed and harder to treat as an editable graph.

### Context replaces type annotations

In a text DSP language, you often specify buffer types, channel counts, and callback signatures. In scriptnode, the surrounding graph supplies that context. Nodes adapt to what they receive, and containers refine the context for their children.

When a network behaves unexpectedly, inspect the context first:

- Is the node running at audio rate, control rate, or frame rate?
- How many channels does it receive?
- Is MIDI enabled at this point?
- Is the network monophonic or polyphonic?
- Are parameter connections scaled or unscaled?

Most scriptnode problems are easier to solve once those questions are answered.


**See also:** $SN.container.chain$ -- serial signal flow, $SN.container.split$ -- parallel signal flow, $SN.routing.send$ -- local audio routing, $SN.routing.local_cable$ -- local control routing, $SN.routing.global_cable$ -- global control routing, $LANG.snex$ -- text DSP language hosted inside scriptnode, $LANG.hsc#dsp$ -- command language for editing scriptnode graphs
