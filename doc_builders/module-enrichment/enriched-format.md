# Enriched JSON Format (Step 4)

**Purpose:** Define the signal-flow topology that the SVG renderer consumes. The enriched JSON places parameters at their point of action in the processing chain - like a hardware manual's block diagram, not a parameter list. This is the final data artifact of the pipeline. Step 5 (SVG rendering) is specified separately in `svg-signal-flow-renderer.md`.

**Input:** `module_enrichment/preliminary/{ModuleId}.json` + `module_enrichment/exploration/{ModuleId}.md` + `module_enrichment/base/moduleList.json`
**Output:** `module_enrichment/enriched/{ModuleId}.json`
**Renderer spec:** `module-enrichment/svg-signal-flow-renderer.md`

---

## What This Format Is

The enriched JSON is a **directed signal-flow graph** with three key properties:

1. **Parameters live at their point of action.** "Feedback" sits next to the feedback path, "Attack" sits on the attack stage. Parameters are not listed in a sidebar - they are placed on the processing nodes they control.

2. **The topology is fresh, not derived from the preliminary JSON.** The preliminary JSON groups data by source (moduleList.json fields). The enriched JSON groups data by signal flow (processing order). These are fundamentally different structures. Step 4 builds the enriched topology from the exploration findings, using the preliminary JSON only as a checklist to ensure nothing is missed.

3. **Self-contained for rendering.** The enriched JSON contains everything the SVG renderer needs to produce a diagram: nodes, edges, groups, parameter placements, layout hints. The renderer resolves parameter metadata (ranges, defaults, descriptions) from moduleList.json, but the topology itself is fully specified here.

---

## Schema

```json
{
  "moduleId": "string",
  "prettyName": "string",
  "type": "string",
  "subtype": "string",

  "io": {
    "audioIn": "string|null (stereo|mono|voice|null)",
    "audioOut": "string|null (stereo|mono|voice|null)",
    "midiIn": "string|null (noteOn+noteOff|noteOn|MIDI_in|null)",
    "modulationOut": "boolean|null",
    "fxChain": "string|null (constrainer type if present)"
  },

  "externalInputs": [
    { "id": "string", "label": "string (optional)" }
  ],

  "interfaces": ["string"],

  "processing": [
    {
      "id": "string",
      "label": "string (1-3 words)",
      "type": "string (node type enum)",
      "scope": "string (scope enum)",
      "importance": "number (0.0-1.0)",
      "detail": "string (optional, for visual modifier rules)",
      "cpuWeight": {
        "base": "string (cost tier enum)",
        "scaleFactor": {
          "parameter": "string",
          "description": "string"
        }
      },
      "condition": {
        "parameter": "string",
        "whenTrue": "string",
        "whenFalse": "string"
      }
    }
  ],

  "signalFlow": [
    {
      "from": "string (node id or io port)",
      "to": "string (node id or io port)",
      "type": "string (edge type enum)",
      "label": "string (optional)"
    }
  ],

  "parameterPlacements": [
    {
      "param": "string (parameter ID from moduleList.json)",
      "target": "string|array (processing node id, or array for fork)",
      "role": "string (what the parameter does at this node)",
      "composite": {
        "type": "string (modMultiply|tempoSyncMux)",
        "...": "type-specific fields"
      }
    }
  ],

  "groups": [
    {
      "id": "string",
      "label": "string",
      "nodes": ["string (processing node ids)"],
      "style": "string (group style enum)"
    }
  ],

  "omittedParameters": [
    {
      "param": "string (parameter ID)",
      "reason": "string (why excluded from diagram)"
    }
  ],

  "cpuProfile": {
    "baseline": "string (cost tier enum)",
    "polyphonic": "boolean",
    "scalingFactors": [
      {
        "parameter": "string",
        "impact": "string (cost tier enum)",
        "note": "string"
      }
    ]
  },

  "seeAlso": [
    {
      "id": "string (module ID)",
      "type": "string (seeAlso type enum)",
      "reason": "string"
    }
  ],

  "commonMistakes": [
    {
      "wrong": "string",
      "right": "string",
      "explanation": "string"
    }
  ],

  "customEquivalent": {
    "approach": "string (hisescript|scriptnode|snex)",
    "moduleType": "string",
    "complexity": "string (trivial|simple|medium|complex)",
    "description": "string",
    "snippetId": "string (optional)"
  },

  "llmRef": "string (multi-paragraph pre-synthesized reference text)",

  "layoutHints": {
    "direction": "string (default: RIGHT)",
    "feedbackLoops": "boolean",
    "compactGroups": "boolean"
  },

  "notes": "string (optional)"
}
```

---

## Field Reference

### Root Object

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `moduleId` | yes | string | Exact module ID from moduleList.json |
| `prettyName` | yes | string | Display name |
| `type` | yes | string | Processor type |
| `subtype` | yes | string | Processor subtype |
| `io` | yes | object | I/O configuration |
| `externalInputs` | if any | array | External signal sources (e.g., Host BPM) |
| `interfaces` | if any | array | Implemented processor interfaces with diagram relevance |
| `processing` | yes | array | Processing nodes in the signal flow |
| `signalFlow` | yes | array | Directed edges between nodes |
| `parameterPlacements` | yes | array | Parameters placed at their point of action |
| `groups` | if any | array | Visual grouping of related nodes |
| `omittedParameters` | if any | array | Parameters excluded from diagram with reasons |
| `cpuProfile` | yes | object | Module-level CPU performance model |
| `seeAlso` | yes | array | Cross-module relationships (2-8 entries) |
| `commonMistakes` | if any | array | Common usage mistakes (0-5 entries) |
| `customEquivalent` | if applicable | object | How to rebuild with custom modules |
| `llmRef` | yes | string | Pre-synthesized multi-paragraph reference text (see `module-enrichment.md` llmRef section) |
| `layoutHints` | no | object | Renderer layout preferences |
| `notes` | no | string | Free-form observations |

### io Object

| Field | Type | Description |
|-------|------|-------------|
| `audioIn` | string or null | `"stereo"`, `"mono"`, `"voice"`, or `null` |
| `audioOut` | string or null | `"stereo"`, `"mono"`, `"voice"`, or `null` |
| `midiIn` | string or null | `"noteOn+noteOff"`, `"noteOn"`, `"MIDI_in"`, or `null` |
| `modulationOut` | boolean or null | `true` for modulators, `null` otherwise |
| `fxChain` | string or null | FX chain constrainer type, or `null` if no FX chain |

The `io` fields define the module's boundary. The renderer creates I/O port nodes from these.

I/O ports referenced in `signalFlow` edges use dot notation:
- `audioIn.L`, `audioIn.R` for stereo audio input
- `audioOut.L`, `audioOut.R` for stereo audio output
- `audioIn` (without channel suffix) for mono or voice audio
- `midiIn` for MIDI input
- `modulationOut` for modulation output

### externalInputs

External signal sources not part of the module's own processing chain. Each entry becomes a node in the diagram.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | yes | string | Unique identifier (e.g., `"HostBPM"`) |
| `label` | no | string | Display label (defaults to id) |

Currently the only known external input is `"HostBPM"`, inferred from the presence of `tempoSyncIndex` on any parameter.

### interfaces

Array of interface names from moduleList.json that have diagram relevance (i.e., they map to nodes, not "skip" interfaces). The renderer uses this to validate that all relevant interfaces are represented in the processing nodes.

### Processing Nodes

Each node represents a distinct processing stage in the signal flow.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | yes | string | Unique node identifier |
| `label` | yes | string | Display label (1-3 words) |
| `type` | yes | NodeType | Visual and semantic type |
| `scope` | yes | Scope | Voice/threading context |
| `importance` | yes | number | 0.0-1.0 for complexity budget filtering |
| `detail` | no | string | Extra info for visual modifier rules (e.g., `"VoiceStartModulator"`) |
| `cpuWeight` | no | object | Per-node CPU cost assessment |
| `condition` | no | object | Parameter-dependent visibility/behavior |

#### NodeType Enum

| Value | Shape | Description |
|-------|-------|-------------|
| `io` | pill | Input/output port (auto-created from `io` fields) |
| `external_input` | rect, dashed left border | External signal source (Host BPM, global modulator) |
| `midi_event` | rounded rect | MIDI event source or sink |
| `audio` | rounded rect | Audio processing stage |
| `modulation` | rounded rect | Modulation signal processing |
| `filter` | rounded rect | Filter processing |
| `gain` | rounded rect | Gain/amplitude processing |
| `waveshaper` | rounded rect | Waveshaping/distortion |
| `delay_line` | rounded rect | Delay line read/write |
| `table` | rounded rect | Table/curve lookup |
| `parameter` | small rect | Explicit parameter node (rarely needed) |
| `decision` | diamond | Conditional branch point |

The renderer assigns colors per type. See `svg-signal-flow-renderer.md` for the color palette.

#### Scope Enum

| Value | Meaning | Visual treatment |
|-------|---------|-----------------|
| `per_voice` | Duplicated per voice, processes voice-level signal | Inside polyphonic group |
| `monophonic` | Single instance, processes summed/global signal | Outside polyphonic group |
| `shared_resource` | Single instance, accessed by all voices (e.g., lookup table) | Shared region style |
| `parameter` | Parameter value (not a processing node) | Minimal visual weight |

**The parameter-to-per_voice bridge:** A parameter has `scope: "parameter"` (single value from the UI), but when it feeds into a per-voice processing node through a modulation chain, the modulation chain bridges the scope - the parameter value becomes per-voice by multiplication with a per-voice modulator output. This is the fundamental mechanism that makes HISE's polyphonic modulation work.

#### Condition Object

For nodes whose behavior depends on a parameter value:

| Field | Type | Description |
|-------|------|-------------|
| `parameter` | string | Parameter ID that controls this node |
| `whenTrue` | string | Label or behavior when parameter is nonzero/enabled |
| `whenFalse` | string | Label or behavior when parameter is zero/disabled |

#### cpuWeight Object

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `base` | yes | CostTier | Inherent cost: `negligible`, `low`, `medium`, `high`, `very_high` |
| `scaleFactor` | no | object | Parameter that multiplies cost |
| `scaleFactor.parameter` | yes (if scaleFactor) | string | Parameter ID |
| `scaleFactor.description` | yes (if scaleFactor) | string | How the parameter affects cost |

### signalFlow Edges

Directed connections between processing nodes.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `from` | yes | string | Source node id or I/O port |
| `to` | yes | string | Target node id or I/O port |
| `type` | yes | EdgeType | Connection semantics |
| `label` | no | string | Edge annotation |

#### EdgeType Enum

| Value | Line style | Description |
|-------|-----------|-------------|
| `signal` | solid | Main audio/modulation signal path |
| `feedback` | dashed | Feedback loop (rendered as back-edge by ELK) |
| `bypass` | dotted | Bypass/dry path |
| `modulation` | solid, different color | Modulation control signal |
| `sidechain` | dash-dot | Sidechain input |

### parameterPlacements

The core differentiator of this format. Parameters are placed at the processing node they control, not in a list.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `param` | yes | string | Parameter ID from moduleList.json |
| `target` | yes | string or array | Processing node id(s) this parameter controls |
| `role` | yes | string | What the parameter does at this node (free-form, concise) |
| `composite` | no | object | Composite block wrapping this parameter |

#### target as Array (Fork Pattern)

When a parameter controls multiple processing nodes, `target` is an array:

```json
{
  "param": "DecayCurve",
  "target": ["D", "R"],
  "role": "curve"
}
```

This means the Decay Curve parameter affects both the Decay and Release stages.

#### Composite Sub-Object

Two composite types carry through from the preliminary JSON:

**modMultiply:**
```json
{
  "type": "modMultiply",
  "chainName": "Gain Modulation",
  "chainIndex": 1,
  "constrainer": "VoiceStartModulator",
  "icon": "pulse"
}
```

The renderer draws: `[Param] -> (*) <- [ModChain]` with the specified icon.

**tempoSyncMux:**
```json
{
  "type": "tempoSyncMux",
  "syncParam": "TempoSync",
  "externalInput": "HostBPM"
}
```

The renderer draws: `[Param] -> [TempoSync mux] <- [Host BPM]` as an inline trapezoid.

### omittedParameters

Parameters from moduleList.json that are deliberately excluded from the diagram.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `param` | yes | string | Parameter ID |
| `reason` | yes | string | Why it's excluded |

Valid reasons:
- `"vestigial"` - Parameter exists in code but has no effect (flagged in issues.md)
- `"internal"` - Implementation detail not relevant to signal flow understanding
- `"consumed_by_composite"` - Parameter is part of a composite block (e.g., the TempoSync toggle is consumed by the tempoSyncMux composite, not placed independently)
- `"config"` - One-time configuration, not a signal flow control (rare)

### groups

Visual containers for related processing nodes.

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | yes | string | Unique group identifier |
| `label` | yes | string | Display label |
| `nodes` | yes | array | Processing node ids contained in this group |
| `style` | yes | GroupStyle | Visual treatment |

#### GroupStyle Enum

| Value | Visual treatment | When to use |
|-------|-----------------|-------------|
| `polyphonic` | Stacked/doubled border | Per-voice processing region |
| `shared_region` | Solid border, distinct background | Shared resources (lookup tables, buffers) |
| `dashed_outline` | Dashed border | Logical grouping (e.g., "AHDSR Envelope" around A/H/D/S/R stages) |
| `compound` | Solid border, label | Compound processing block (e.g., "Envelope" wrapping all stages) |

### cpuProfile

Module-level CPU performance summary, derived from the per-node cpuWeight values.

See `module-enrichment.md` section "cpuProfile" for the full specification including cost tier definitions and derivation rules.

### seeAlso

Cross-module relationships. See `module-enrichment.md` section "seeAlso" for the full taxonomy (8 relationship types with reciprocal rules).

Within a batch, ensure symmetric relationships are consistent: if module A lists module B as `alternative`, module B must list module A as `alternative`.

### commonMistakes

See `module-enrichment.md` section "commonMistakes" for format and sourcing rules.

### customEquivalent

See `module-enrichment.md` section "customEquivalent" for the full specification.

### layoutHints

Optional renderer preferences. These are hints, not commands - the renderer may override them.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `direction` | string | `"RIGHT"` | ELK layout direction (`RIGHT` for L-to-R signal flow) |
| `feedbackLoops` | boolean | `false` | Hint that the graph has feedback (renderer enables back-edge routing) |
| `compactGroups` | boolean | `false` | Hint to minimize group spacing |

---

## Complexity Budget and Importance

Each processing node has an `importance` value from 0.0 to 1.0. The SVG renderer uses this for multi-resolution rendering:

| Budget tier | Threshold | Use case |
|-------------|-----------|----------|
| `overview` | >= 0.8 | Tooltip, quick reference (3-5 nodes) |
| `thumbnail` | >= 0.5 | Documentation sidebar (5-10 nodes) |
| `documentation` | >= 0.0 | Full documentation page (all nodes) |

### Importance Assignment Guidelines

| Node role | Importance range | Rationale |
|-----------|-----------------|-----------|
| I/O ports | 1.0 | Always visible - define module boundary |
| Main signal path stages | 0.7 - 0.9 | Core processing chain |
| Primary modulation inputs | 0.5 - 0.7 | Key control points |
| Secondary modulation, conditional branches | 0.3 - 0.5 | Visible at documentation level |
| Implementation detail nodes | 0.1 - 0.2 | Only in full documentation view |

When the renderer filters nodes by budget:
- Edges connected to filtered-out nodes are removed
- Groups containing no visible nodes after filtering are removed
- Composite blocks on filtered-out parameters are removed

---

## Step 4: Author Enriched JSON

### Inputs

- `module_enrichment/preliminary/{ModuleId}.json` - checklist of all parameters and mod chains
- `module_enrichment/exploration/{ModuleId}.md` - signal path findings, gap answers
- `module_enrichment/base/moduleList.json` - metadata for cross-referencing

### Procedure

1. **Build the processing chain.** Using the exploration markdown's Signal Path and Processing Chain Detail sections, create the `processing` nodes array. Each significant processing stage becomes a node. Order matters - the signal flow should read left-to-right when rendered.

2. **Connect the processing chain.** Create `signalFlow` edges that trace the signal from input to output. Mark feedback paths with `type: "feedback"`. Mark bypass paths with `type: "bypass"`.

3. **Place parameters at their point of action.** For each parameter from the preliminary JSON, determine which processing node it controls and create a `parameterPlacements` entry. The `role` field should be a concise description of what the parameter does at that node (e.g., `"delay_time"`, `"gain"`, `"frequency"`, `"curve"`).

4. **Carry composite blocks forward.** For each composite block identified in the preliminary JSON (modMultiply, tempoSyncMux), include it in the corresponding `parameterPlacements` entry's `composite` field.

5. **Account for all parameters.** Every parameter from the preliminary JSON must appear in exactly one of:
   - `parameterPlacements` (placed on a processing node)
   - `omittedParameters` (excluded with a reason)
   - Consumed by a composite block (the sync toggle parameter is consumed by tempoSyncMux)

6. **Define groups.** If the exploration reveals logical groupings of processing stages (e.g., all AHDSR envelope stages), wrap them in a `groups` entry with an appropriate style.

7. **Assign importance.** Give each processing node an importance value following the guidelines above. Consider the complexity budget tiers - would the diagram still make sense at the `overview` tier (only nodes >= 0.8)?

8. **Assess CPU profile.** Roll up per-node cpuWeight values into the module-level cpuProfile.

9. **Write seeAlso entries.** Based on the exploration findings and the seeAlso taxonomy in `module-enrichment.md`, identify 2-8 cross-module relationships. Within a batch, coordinate with other modules for symmetric relationships.

10. **Write commonMistakes.** Based on exploration findings, identify 0-5 common usage mistakes. Reference observable behavior, not implementation details.

11. **Assess customEquivalent.** If applicable, determine the simplest approach to reproduce this module's behavior using a custom module.

12. **Set layout hints.** If the module has feedback loops, set `feedbackLoops: true`. Otherwise, defaults are usually fine.

### Key Design Principle

**"Read like a hardware manual's block diagram."**

The enriched JSON should produce a diagram where:
- A user can trace the signal from input to output
- Each parameter label appears next to the processing stage it controls
- The spatial layout communicates the processing order
- Composite blocks (mod multiply, tempo sync) appear inline at their point of action
- Groups provide visual context without cluttering the signal path

If you find yourself listing parameters in a column on the left side of the diagram, you're building a parameter list, not a signal flow diagram. Revisit the topology.

### Step 4 Gate Checklist

Before declaring the enriched JSON complete, verify:

- [ ] **Parameter accountability:** Every parameter from the preliminary JSON appears in exactly one of: `parameterPlacements`, `omittedParameters`, or consumed by a composite. No parameter is unaccounted for.
- [ ] **Exploration incorporation:** Every gap answer from the exploration markdown has been incorporated into the topology (or there is an explicit note explaining why a finding was not incorporated).
- [ ] **Interface coverage:** Every interface listed in the preliminary JSON with a diagram role (not "skip") is represented by a processing node or noted in `omittedParameters` with a reason.
- [ ] **Signal completeness:** There is a connected path from every input (audioIn, midiIn) to at least one output (audioOut, modulationOut). No processing node is an orphan (disconnected from both input and output).
- [ ] **Composite consistency:** Every composite block from the preliminary JSON appears in the corresponding `parameterPlacements` entry. The composite's referenced parameters (syncParam, chainName) exist in moduleList.json.
- [ ] **Scope correctness:** Nodes inside polyphonic groups have `scope: "per_voice"`. Nodes outside polyphonic groups have `scope: "monophonic"` or `scope: "shared_resource"`.
- [ ] **Importance sanity:** I/O ports have importance 1.0. No importance value is outside 0.0-1.0. The `overview` tier (>= 0.8) produces a meaningful diagram (at least input -> main stage -> output).
- [ ] **cpuProfile derivation:** `baseline` matches the highest cpuWeight.base on the main signal path. `polyphonic` matches the module's subtype. `scalingFactors` includes all nodes with cpuWeight.scaleFactor.
- [ ] **seeAlso completeness:** At least 2 entries. Within a batch, symmetric relationships are consistent.
- [ ] **No bugs in documentation:** commonMistakes and notes do not reference implementation bugs, line numbers, or fix suggestions.

---

## Category-Specific Topology Patterns

Different module categories tend to produce characteristic topologies. These patterns are guides, not templates - actual modules may deviate.

### Envelope Pattern (EnvelopeModulators)

```
midiIn(noteOn) -> Attack -> Hold -> Decay -> Sustain -> Release -> modulationOut
                                                           ^
                                              midiIn(noteOff)
```

- Each stage is a processing node with the corresponding parameter placed on it
- Retrigger behavior may add a decision node before Attack
- Curve parameters fork to multiple stages (e.g., DecayCurve targets both Decay and Release)
- Gain modulation chain creates a modMultiply on the output
- Group: all stages in a `compound` group labeled with the envelope name

### Effect Pattern (MasterEffects, VoiceEffects)

```
audioIn -> [processing stages] -> mix -> audioOut
    |                              ^
    +---- bypass ------------------+
```

- Processing stages ordered by `applyEffect()` execution order
- Dry/wet mix node near the output with `Mix` parameter
- Feedback paths marked with `type: "feedback"` edges
- Tempo-synced time parameters wrapped in tempoSyncMux composites

### Oscillator/SynthGenerator Pattern (SoundGenerators)

```
midiIn(noteOn) -> pitch -> oscillator -> [optional processing] -> gain -> audioOut
                    ^                                               ^
              [pitch mod]                                     [gain mod]
```

- Pitch modulation chain is standalone (modulates implicit base pitch)
- Gain modulation chain is a modMultiply on the gain node
- Multi-oscillator modules have parallel paths that merge
- FX chain slot appears after the main signal path
- Polyphonic group wraps everything from pitch to gain

### MIDI Processor Pattern

```
midiIn -> [event read] -> [transform] -> [event write] -> midiOut
```

- Processing nodes represent event transformation steps
- Parameters control the transformation logic
- No audio path, no modulation output
- Typically simple topologies with 3-5 nodes

### Custom Category Pattern

```
[callback/network slot] -> [framework I/O]
```

- Show available callback slots or scriptnode network slots as placeholder nodes
- Framework-provided I/O (audio, MIDI, modulation) shown as boundary ports
- No internal signal flow - the user defines it
- Importance: all nodes at 0.8+ (the diagram is already minimal)
- Detailed internal treatment is deferred
