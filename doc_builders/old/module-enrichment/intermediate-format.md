# Signal Flow Intermediate Format

## Purpose

This document specifies a structured JSON format for representing the signal architecture of HISE audio modules. The intermediate format serves as a **single source of truth** produced by C++ source code exploration, from which multiple downstream outputs are derived:

- **SVG block diagrams** for the documentation website (docs.hise.dev)
- **Technical descriptions** derived mechanically from the graph structure
- **`seeAlso` relationships** derived from cross-module graph traversal
- **`signalFlow` strings** (concise `A -> B -> C` notation) for the MCP server
- **Context for LLM enrichment agents** producing `commonMistakes`, `llmRef`, and practical guidance

```
C++ source code
       |
       v
C++ Exploration Agent --> Intermediate JSON (this format)
                                |
                          ------+------
                          |           |
                          v           v
                    Derived        Enriched
                    (mechanical)   (LLM + real-world sources)
                    |              |
                    |- description |- commonMistakes
                    |- seeAlso    |- seeAlso (practical)
                    |  (structural)|
                    |- signalFlow |- llmRef prose
                    |- SVG        |- performance notes
```

## Pipeline Context

The intermediate format sits at the center of the module enrichment pipeline:

- **Phase 0**: `moduleList.json` - C++ metadata (parameters, ranges, types, categories, modulation chains)
- **Phase 1**: Intermediate JSON (this format) - C++ signal path exploration
- **Phase 2a**: Real-world project analysis (14 HISE projects) - usage patterns, parameter distributions
- **Phase 2b**: Documentation salvage (hise_documentation repo) - prose, warnings, workflows
- **Phase 3**: LLM enrichment - synthesis of all sources into final enriched fields
- **Phase 4**: Human review

The intermediate JSON is produced in Phase 1 and consumed by all subsequent phases.

## Top-Level Schema

```json
{
  "moduleId": "string",
  "notes": "string (optional)",
  "nodes": [],
  "edges": [],
  "groups": []
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `moduleId` | string | yes | Must match the `id` field in `moduleList.json` |
| `notes` | string | no | Free-text for anything the graph cannot capture structurally (caveats, deprecations, historical context, thread safety) |
| `nodes` | array | yes | Processing stages, inputs, outputs, parameters |
| `edges` | array | yes | Connections between nodes |
| `groups` | array | no | Visual groupings (polyphonic regions, shared resource zones) |

## Node Specification

```json
{
  "id": "string",
  "label": "string",
  "type": "string",
  "detail": "string (optional)",
  "scope": "string",
  "parameters": ["string"] ,
  "importance": 0.0-1.0,
  "condition": {}
}
```

### Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique within the graph. Use snake_case. |
| `label` | string | yes | Short display label for SVG (1-3 words). No explanatory text - the prose handles that. |
| `type` | enum | yes | Functional role of this node (see Node Types below) |
| `detail` | string | no | Terse clarification, not prose. E.g., "Left / Right", "per voice", "optional". |
| `scope` | enum | yes | Polyphony context (see Scope Semantics below) |
| `parameters` | string[] | no | Parameter IDs from `moduleList.json` that this node represents or is controlled by |
| `importance` | number | yes | 0.0 to 1.0. Controls whether this node appears at different complexity budgets. |
| `condition` | object | no | Conditional behavior based on a parameter value |

### Node Types

Each node type maps to a functional domain. The SVG rendering agent uses these to select colors, icons, and shapes.

| Type | Domain | Use case | Example |
|---|---|---|---|
| `io` | neutral | Input/output terminals of the module | "Input", "Output", "0..1" |
| `external_input` | cross-module | Signal arriving from outside the module tree | Macro control slot, event data, global modulator source |
| `midi_event` | MIDI | MIDI event processing or trigger points | Note-on, note-off, CC input |
| `audio` | audio | Audio signal processing stages | Voice rendering, oscillator, disk streaming |
| `modulation` | modulation | Modulation signal (0..1) generation or processing | Envelope stages, mod output |
| `filter` | audio | Frequency-domain filtering | LP filter, HP filter, EQ band |
| `gain` | audio | Amplitude/gain stages | Feedback gain, dry/wet mix, pre-gain |
| `waveshaper` | audio | Nonlinear distortion/shaping | Waveshaper function, saturation curve |
| `delay_line` | audio | Delay buffers and time-based processing | Delay line, allpass chain |
| `table` | data | Table/curve lookup operations | Velocity curve, waveshaper table |
| `parameter` | data | UI-controlled parameter injection | Attack time, filter frequency, mix amount |
| `decision` | control | Conditional routing or mode selection | TempoSync toggle, filter type selector |

### Condition Object

For nodes whose behavior changes based on a parameter:

```json
{
  "parameter": "TempoSync",
  "whenTrue": "Times from tempo-synced note values",
  "whenFalse": "Times in milliseconds"
}
```

## Edge Specification

```json
{
  "from": "string",
  "to": "string",
  "type": "string",
  "label": "string (optional)"
}
```

### Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `from` | string | yes | Source node ID |
| `to` | string | yes | Target node ID |
| `type` | enum | yes | Visual and semantic style of the connection |
| `label` | string | no | Short annotation (e.g., "Feedback loop", "per-voice scale") |

### Edge Types

| Type | Visual | Semantic meaning |
|---|---|---|
| `signal` | solid arrow | Main signal flow (audio, modulation, or MIDI depending on context) |
| `feedback` | dashed arrow, curved back | Signal feeding back into an earlier stage |
| `bypass` | dotted arrow | Dry path, bypass routing |
| `modulation` | thin colored arrow | Parameter modulation input (does not carry the main signal) |
| `sidechain` | dashed, alternate color | Detection/analysis path separate from main signal |

## Group Specification

```json
{
  "id": "string",
  "label": "string",
  "nodes": ["string"],
  "style": "string"
}
```

### Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique group identifier |
| `label` | string | yes | Display label for the group boundary |
| `nodes` | string[] | yes | Node IDs contained in this group |
| `style` | enum | yes | Visual treatment of the group |

### Group Styles

| Style | Visual hint | Use case |
|---|---|---|
| `polyphonic` | Stacked/multiplied border, "x N voices" annotation | Per-voice processing region |
| `shared_region` | Distinct background, single-instance indicator | Shared parameters or resources above the voice loop |
| `dashed_outline` | Dashed border grouping | Logical grouping (e.g., "Feedback Path", "Scale before Offset") |

## Scope Semantics

The `scope` field on each node defines its relationship to the polyphonic voice architecture. This is one of the most important concepts the format captures.

| Scope | Meaning | Instance count | Example |
|---|---|---|---|
| `shared_resource` | Data or state that exists once; voices read from it | 1 | Wavetable bank, sample map, IR buffer, loaded DSP network |
| `per_voice` | Independent instance per active voice | N (voice count) | Envelope state, filter coefficients, oscillator phase |
| `monophonic` | Processed once per buffer, one output value | 1 | LFO output, master effect processing, monophonic gain |
| `parameter` | UI-controlled value, same for all voices unless modulated | 1 (base value) | Attack time knob, filter frequency, mix amount |

### The parameter-to-per_voice bridge

A key architectural pattern in HISE: a `parameter` scope node provides a base value shared across all voices, but a per-voice modulation chain can scale that value differently for each voice. This is the bridge between "one knob" and "different behavior per voice."

For example, AHDSR's Attack parameter:
- The Attack knob (`scope: "parameter"`) sets the base time (e.g., 20ms)
- The AttackTimeModulation chain (`scope: "per_voice"`, `type: "external_input"`) scales it per voice
- The effective attack time for each voice = base * modulation value

The intermediate format represents this as two nodes (parameter + external_input) both feeding into the per-voice processing node, connected by `modulation` type edges.

## Importance and Complexity Budgets

The `importance` field (0.0 to 1.0) on each node enables the SVG rendering agent to scale diagram complexity to fit the context.

### Importance guidelines for the C++ exploration agent:

| Importance | Guideline |
|---|---|
| 1.0 | Core to understanding the module's purpose. Removing this makes the diagram meaningless. |
| 0.7-0.9 | Important processing stage. Should appear in most diagrams. |
| 0.4-0.6 | Secondary feature. Include in detailed views, omit in overviews. |
| 0.1-0.3 | Minor or rarely-used feature. Only include in the most detailed diagrams. |

### Complexity budgets for the SVG rendering agent:

The rendering agent sums all node importance values and compares against a target budget:

| Context | Budget | Description |
|---|---|---|
| Module list thumbnail | 3-4 | Essential flow only. 4-6 nodes max. |
| Module documentation page | 7-10 | Full detail. All significant stages shown. |
| Overview/architecture diagram | 2-3 | Just input -> process -> output. |

To render at a given budget:
1. Sort nodes by importance (descending)
2. Accumulate importance values until the budget is reached
3. Include all nodes above the cutoff
4. Collapse excluded nodes into their neighbors or omit them
5. Remove edges that reference excluded nodes (unless they can be rerouted)

### Edges and groups do not have importance values

Edges inherit visibility from their connected nodes. Groups are shown if any of their member nodes are visible.

## Derivation Rules

### Description derivation

A technical description can be mechanically produced from the graph by enumerating:

1. **Input type**: What enters the module (MIDI event, audio signal, external modulation source)
2. **Processing chain**: The sequence of internal nodes along the main signal path
3. **Output type**: What leaves the module (audio, 0..1 modulation, MIDI events)
4. **Scope**: Whether processing is per-voice, monophonic, or uses shared resources
5. **External dependencies**: Any `external_input` nodes

Template: "[Module] receives [input type], processes it through [chain summary], and outputs [output type]. [Scope statement]. [External dependency statement if applicable]."

### seeAlso derivation (structural)

Cross-module relationships can be derived by comparing intermediate JSONs:

| Pattern | Relationship | Example |
|---|---|---|
| Module A has `external_input` that Module B produces | producer/consumer | MacroModulator consumes MacroModulationSource |
| Two modules have nearly identical graph topologies | alternatives | AHDSR vs FlexAHDSR vs SimpleEnvelope |
| Two modules reference the same `external_input` source | co-consumers | All Global*Modulator types reference GlobalModulatorContainer |
| Module A's output type matches Module B's input type in a typical chain | chain partners | Velocity (output: per_voice modulation) -> AHDSR AttackTimeModulation (input: VoiceStartModulator) |

Structural seeAlso entries use factual language:

```json
{ "id": "MacroModulationSource", "reason": "Produces the macro signal this module consumes" }
```

Practical seeAlso (from Phase 2a/2b/3) uses guidance language:

```json
{ "id": "MatrixModulator", "reason": "More flexible alternative for multi-source modulation" }
```

### signalFlow string derivation

Linearize the graph into arrow notation by following the main signal path (edges of type `signal`):

1. Start at the input `io` node (or `midi_event` / `external_input` if no io node)
2. Follow `signal` edges through the graph
3. At each node, emit its `label`
4. Annotate branches in parentheses: `feedback loop (LP -> HP -> gain)`
5. Note scope transitions: `Per voice: ...`
6. Note conditions: `(tempo-synced optional)`

Result: a single string suitable for the `signalFlow` field in `moduleList.json`.

### SVG rendering

The SVG rendering agent reads the intermediate JSON and makes autonomous layout decisions. It does NOT receive layout hints from the format. The agent should:

1. Apply the complexity budget to determine which nodes to include
2. Choose a layout direction based on graph structure (linear chains go horizontal, complex routing may go vertical or use a mixed layout)
3. Use HISE color palette for node types (MIDI = orange, audio = green, modulation = blue, etc.)
4. Use HISE-style icons where applicable
5. Draw group boundaries with the specified style
6. Keep text minimal - labels only, no explanatory prose in the diagram

## `signalFlow` field requirements by category

Based on the module's primary category tag, the `signalFlow` field (and therefore the intermediate JSON) is either required or optional:

| Category | Required? | What the signal flow describes |
|---|---|---|
| `oscillator` | yes | Synthesis algorithm, waveform generation |
| `sample_playback` | yes | Playback engine, streaming, looping |
| `container` | optional | Voice mixing, FM routing (if applicable) |
| `sequencing` | yes | Event generation, timing, sequence logic |
| `note_processing` | yes | Event transformation, what happens to incoming MIDI |
| `dynamics` | yes | Processing chain, stage order, sidechain paths |
| `filter` | yes | Filter topology, series/parallel, modulation points |
| `delay` | yes | Delay topology, feedback paths, filter placement |
| `reverb` | yes | Algorithm structure, pre/post processing |
| `mixing` | optional | Usually trivial, but include for mid/side or complex routing |
| `routing` | optional | Signal routing between source and destination |
| `input` | yes | Event-to-signal conversion, what's captured and how |
| `generator` | yes | Signal generation, envelope stages, oscillator type |
| `utility` | no | Mostly passthrough or non-audio |
| `custom` | no | User-defined, signal path depends on loaded network |

## Examples

Canonical, C++-verified examples live in `module_enrichment/phase1/` as the actual pipeline work products:

- **`Delay.json`** - Monophonic effect with feedback loops, conditional tempo sync, overlap dry/wet fader, vestigial parameters. Exercises: `feedback` edges, `decision` nodes with `condition`, `bypass` edges, `dashed_outline` groups, stereo channel separation.
- **`AHDSR.json`** - Per-voice envelope modulator with shared parameters and per-voice modulation chains. Exercises: `parameter` scope vs `per_voice` scope, `external_input` nodes, `polyphonic` and `shared_region` groups, `midi_event` triggers, `modulation` edges.
- **`MacroModulator.json`** - Monophonic time-variant modulator with external macro input, optional table lookup, and smoothing. Exercises: `external_input` from macro system, `table` nodes, `condition` for optional table, simple linear chain.
- **`ChannelFilter.json`** - MIDI processor that filters events by channel, with MPE mode. Exercises: `midi_event` input, `decision` nodes for branching logic, dual output paths (pass/ignore), no groups needed.
- **`WaveSynth.json`** - Polyphonic dual-oscillator sound generator with PolyBLEP synthesis. Exercises: `audio` nodes for oscillators, `polyphonic` group for per-voice processing, inherited modulation chains (gain, pitch, effects), independent osc2 pitch chain, `decision` node for hard sync, linear mix crossfade with audio-rate modulation, equal-power pan/balance stage, `condition` on EnableSecondOscillator.

These files are the single source of truth. Do not duplicate their content here - refer to them directly when implementing downstream tools (SVG renderer, derivation scripts, etc.).

## Guidelines for the C++ Exploration Agent

When producing the intermediate JSON from C++ source code:

0. **Log bugs to `module_enrichment/issues.md`**, not to the intermediate JSON. The `notes` field may mention vestigial or unimplemented features as factual DSP observations, but must not include bug details, line numbers, or fix suggestions. See the "Bug discovery policy" section in `module-enrichment.md` for the full policy.
1. **Follow the `processBlock` / `renderNextBlock` method** to trace the audio signal path.
2. **Follow `startNote` / `stopNote`** for voice lifecycle events.
3. **Look for internal buffers** (AudioSampleBuffer, delay lines, IR buffers) to identify `shared_resource` scope nodes.
4. **Look for `VoiceData` or per-voice state structs** to identify `per_voice` scope nodes.
5. **Map `setAttribute` parameter indices** to the `parameters` field on nodes.
6. **Check for conditional logic** (if/switch on parameter values) to create `condition` objects or `decision` nodes.
7. **Trace modulation chain connections** in `getChildProcessorChain` to find `external_input` nodes.
8. **Use short labels** - the label should be 1-3 words identifying the stage, not explaining it. Put explanations in `notes` or leave them for the prose.
9. **Set importance based on architectural significance**, not code complexity. A simple gain stage at the output might be importance 0.4, while a complex but rarely-used feature might be importance 0.3.
10. **Do not invent nodes for implementation details** that don't affect the conceptual signal flow. Internal buffer management, thread synchronization, and memory allocation are not signal flow stages.
