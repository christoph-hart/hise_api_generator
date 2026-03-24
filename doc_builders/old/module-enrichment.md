# Module Enrichment Pipeline

**Purpose:** Produce enriched module documentation for the 79 HISE audio processors - technical descriptions, signal flow diagrams, common mistakes, cross-references, and LLM-optimized reference text - following the same phased pattern established by the scripting API enrichment.

**Output Location:** `tools/api generator/module_enrichment/output/moduleList.json` (enriched)

**Sub-phase details:** See `module-enrichment/` for per-phase instructions and supporting specifications:

- `module-enrichment/intermediate-format.md` - Signal flow intermediate JSON specification (Phase 1 output format)
- `module-enrichment/svg-signal-flow-renderer.md` - SVG diagram rendering tool specification
- (Additional per-phase docs to be created as phases are implemented)

---

## Strategic Context: Modules vs. Scripting API

The scripting API enrichment pipeline documents *methods* (function signatures, parameters, return values, thread safety). The module enrichment pipeline documents *audio processors* (signal flow, DSP topology, performance characteristics, modulation routing).

These are complementary datasets:
- The scripting API tells the LLM *how to control* modules (`Synth.getEffect("id").setAttribute(...)`)
- The module documentation tells the LLM *what the module does* (signal architecture, parameter semantics, when to use it vs. alternatives)

The two pipelines share a common pattern (phased enrichment with C++ exploration, real-world data, and LLM synthesis) but differ in their intermediate representations and source exploration strategies.

### Key Differences from Scripting API Enrichment

| Aspect | Scripting API | Module Enrichment |
|--------|--------------|-------------------|
| Unit of enrichment | Method (function signature) | Module (audio processor) |
| Source truth | C++ `ScriptingApi.cpp` | Scattered across C++ processor classes |
| Intermediate format | None needed (methods are self-contained) | Signal flow JSON (`intermediate-format.md`) |
| Real-world data | Not used | 14 project analysis |
| seeAlso derivation | Manual during enrichment | Partially automated via graph comparison |
| Visual output | None | SVG diagrams |
| `callScope` equivalent | Thread safety (`safe` / `audio-only` / etc.) | Scope (`per_voice` / `monophonic` / `shared_resource`) |

---

## Pipeline Overview

```
Phase 0: C++ extraction -> module_enrichment/base/moduleList.json
       |   (existing, complete for all 79 modules)
       |
Phase 1: C++ signal flow exploration
       |   Agent-driven -> module_enrichment/phase1/ModuleId.json (intermediate JSONs)
       |   Guided by intermediate-format.md
       |
Phase 2a: Real-world project analysis (14 HISE projects)
       |   Agent-driven -> module_enrichment/phase2a/ModuleId-usage.json
       |
Phase 2b: Documentation salvage (hise_documentation repo)
       |   Agent-driven -> module_enrichment/phase2b/ModuleId-docs.json
       |
Phase 3: LLM enrichment (synthesis of all sources)
       |   Agent-driven -> module_enrichment/phase3/ModuleId-enriched.json
       |
Phase 4: Human review
       |   Approve / edit / reject -> merge into output
       |
module_enrichment/output/moduleList.json (enriched)
+ module_enrichment/phase1/*.json (intermediate JSONs, retained)
+ svg_renderer/output/*.svg (diagrams)
```

```
                     Sources
                    /   |   \
                   /    |    \
            C++ code  Projects  Docs
               |        |       |
               v        v       v
         Phase 1    Phase 2a  Phase 2b
         Signal     Usage     Prose
         flow       patterns  salvage
               \       |       /
                \      |      /
                 v     v     v
                  Phase 3
                LLM Enrichment
                     |
                     v
                  Phase 4
                Human Review
                     |
                     v
              moduleList.json (enriched)
              + intermediate JSONs
              + SVG diagrams
```

---

## Directory Structure

```
tools/api generator/
├── doc_builders/
│   ├── module-enrichment.md                      # This file (orchestrator guide)
│   └── module-enrichment/                        # Sub-phase details and specs
│       ├── intermediate-format.md                # Signal flow JSON specification
│       └── svg-signal-flow-renderer.md           # SVG rendering tool specification
├── module_enrichment/                            # Work product directory
│   ├── issues.md                                 # Bugs discovered during C++ exploration (sidecar)
│   ├── base/                                     # Phase 0 output (tracked)
│   │   └── moduleList.json                       # C++-extracted metadata, all 79 modules
│   ├── phase1/                                   # Phase 1 intermediate JSONs (tracked)
│   │   ├── AHDSR.json
│   │   ├── Delay.json
│   │   └── ...
│   ├── phase2a/                                  # Phase 2a usage summaries (tracked)
│   │   ├── AHDSR-usage.json
│   │   └── ...
│   ├── phase2b/                                  # Phase 2b documentation extracts (tracked)
│   │   ├── AHDSR-docs.json
│   │   └── ...
│   ├── phase3/                                   # Phase 3 enriched output (tracked, pre-review)
│   │   ├── AHDSR-enriched.json
│   │   └── ...
│   ├── resources/                                # Supporting data and guidelines
│   │   └── ...
│   └── output/                                   # Final merged JSON (gitignored, regenerated)
│       └── moduleList.json
├── svg_renderer/                                 # SVG rendering tool (Node.js/TypeScript)
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   ├── test-data/
│   └── output/                                   # Generated SVGs (gitignored)
│       ├── AHDSR.svg
│       ├── Delay.svg
│       └── ...
```

---

## Current State: Phase 0

`module_enrichment/base/moduleList.json` contains C++-extracted metadata for all 79 modules:

| Field | Source | Example |
|-------|--------|---------|
| `id` | C++ class registration | `"AHDSR"` |
| `prettyName` | C++ `getName()` | `"AHDSR Envelope"` |
| `description` | Hand-written (basic) | One sentence |
| `type` | C++ base class | `"Modulator"`, `"Effect"`, `"MidiProcessor"`, `"SoundGenerator"` |
| `subtype` | C++ intermediate class | `"EnvelopeModulator"`, `"MasterEffectProcessor"` |
| `category` | Tag array (1-2 tags) | `["generator"]`, `["routing", "mixing"]` |
| `builderPath` | Builder API path | `"b.Modulators.AHDSR"` |
| `hasChildren` | Accepts child modules | `true` / `false` |
| `hasFX` | Has internal FX chain | `true` / `false` |
| `metadataType` | `"static"` or `"dynamic"` | Static = C++ parameters, Dynamic = scriptnode network |
| `parameters[]` | C++ `setAttribute` enum | Index, id, description, type, range, default, mode, unit |
| `modulation[]` | C++ modulation chains | Chain index, constrainer, mode |
| `interfaces[]` | C++ interface implementations | `"RoutingMatrix"`, `"TableProcessor"`, etc. |

**Module counts by type:** 27 Modulators, 26 Effects, 14 Sound Generators, 12 MIDI Processors.

**Module counts by category:** routing (19), custom (14), generator (9), note_processing (9), oscillator (6), input (6), mixing (6), utility (6), sequencing (4), container (4), dynamics (4), filter (4), delay (3), reverb (2), sample_playback (2).

---

## Target State: Enriched

Each module gains these fields:

```json
{
  "id": "Delay",
  "prettyName": "Stereo Delay",
  "description": "Stereo delay with independent L/R times, filtered feedback, and optional tempo sync.",

  "signalFlow": "Input -> delay line L/R (tempo-synced optional) -> feedback loop (LP -> HP -> gain) -> dry/wet mix -> Output",

  "cpuProfile": {
    "baseline": "medium",
    "polyphonic": false,
    "scalingFactors": []
  },

  "commonMistakes": [
    {
      "wrong": "Setting feedback to 1.0 for infinite repeats",
      "right": "Keep feedback below 0.95 to prevent runaway gain",
      "explanation": "The filters in the feedback path add gain at resonance. Combined with feedback at 1.0, this causes the signal to grow exponentially."
    }
  ],

  "seeAlso": [
    { "id": "Chorus", "type": "alternative", "reason": "Uses modulated delay lines for pitch variation instead of filtered feedback" },
    { "id": "PhaseFX", "type": "alternative", "reason": "Uses allpass delay chains for phase-based effects" }
  ],

  "customEquivalent": {
    "approach": "scriptnode",
    "moduleType": "HardcodedFX",
    "complexity": "medium",
    "description": "Recreate with fx.delay in a scriptnode network for custom feedback filtering or modulated delay times"
  },

  "llmRef": "Delay\nStereo delay effect...\n\n...(multi-paragraph technical reference)..."
}
```

### Enriched field definitions

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `description` | string | Derived from intermediate format, refined by LLM | 1-3 sentence technical description. Replaces the Phase 0 one-liner. |
| `signalFlow` | string | Derived from intermediate format | Arrow notation showing the main signal path. |
| `cpuProfile` | object | Derived from intermediate format | `{baseline, polyphonic, scalingFactors[]}`. See CPU Performance Model below. |
| `commonMistakes` | array | Real-world projects + docs + LLM synthesis | `{wrong, right, explanation}` triples. Same format as scripting API. |
| `seeAlso` | array | Structural derivation + practical guidance | `{id, type, reason}` triples. See Phase 3 seeAlso taxonomy. |
| `customEquivalent` | object | Phase 1 (C++ analysis) + snippet database | How to rebuild this module using custom modules. See Phase 3 customEquivalent. |
| `llmRef` | string | LLM synthesis of all sources | Multi-paragraph reference text served verbatim by the MCP server. |

### Fields NOT included

- **`scriptReference`**: Deterministic from `type` + existing scripting API. `Modulator` -> `Synth.getModulator("id")`, `Effect` -> `Synth.getEffect("id")`, etc. Computed at query time by the MCP server.
- **SVG file paths**: SVGs are generated as separate artifacts for the documentation website, not embedded in the JSON.
- **`signalFlowIntermediate`**: Stored as separate files in `module_enrichment/phase1/`, not inline in the output JSON.

---

## CPU Performance Model

CPU cost is a first-class concern. Users need to understand which modules are expensive, which parameters blow up the CPU budget, and when to prefer a monophonic variant over a polyphonic one.

### Node-level: `cpuWeight` in the intermediate format

Each node in the intermediate JSON (see `module-enrichment/intermediate-format.md`) gains an optional `cpuWeight` field:

```json
{
  "id": "unisono_duplication",
  "label": "Unisono",
  "type": "audio",
  "scope": "per_voice",
  "importance": 0.8,
  "cpuWeight": {
    "base": "low",
    "scaleFactor": {
      "parameter": "UnisonoVoiceAmount",
      "description": "Each unisono voice duplicates the full voice rendering pipeline"
    }
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `cpuWeight.base` | enum | Inherent cost tier: `negligible`, `low`, `medium`, `high`, `very_high` |
| `cpuWeight.scaleFactor` | object | Optional. Parameter that multiplies the cost. |
| `cpuWeight.scaleFactor.parameter` | string | Parameter ID from `moduleList.json` |
| `cpuWeight.scaleFactor.description` | string | How the parameter affects CPU cost |

**Base cost tiers** (hardware-independent, relative to a simple gain multiply):

| Tier | Examples |
|------|----------|
| `negligible` | Parameter read, bypass check, simple decision |
| `low` | Gain multiply, simple mix, table lookup |
| `medium` | Biquad filter, delay line read/write, envelope calculation |
| `high` | Multi-mode filter, FFT-based processing, per-sample nonlinearity |
| `very_high` | Convolution, large FFT, heavy oversampling |

### Module-level: `cpuProfile` in the enriched output

```json
{
  "cpuProfile": {
    "baseline": "medium",
    "polyphonic": true,
    "scalingFactors": [
      {
        "parameter": "UnisonoVoiceAmount",
        "impact": "high",
        "note": "Each unisono voice duplicates the full voice rendering pipeline"
      }
    ]
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `baseline` | enum | Overall CPU cost at default settings: `negligible` / `low` / `medium` / `high` / `very_high` |
| `polyphonic` | boolean | Per-voice (true) or per-buffer (false). If polyphony is not required, prefer the monophonic variant. |
| `scalingFactors` | array | Parameters that significantly increase CPU cost beyond baseline |

### Derivation

- `baseline`: highest `cpuWeight.base` among nodes on the main signal path
- `polyphonic`: from the module's `subtype`, confirmed by `per_voice` scope nodes in the intermediate JSON
- `scalingFactors`: collected from all nodes with `cpuWeight.scaleFactor` entries

---

## Phase 1: C++ Signal Flow Exploration

**Input:** HISE C++ source code (at `../../` relative to this directory)

**Output:** One intermediate JSON per module in `module_enrichment/phase1/`

**Format:** See `module-enrichment/intermediate-format.md`

### What the agent does

1. Locate the module's C++ class using the `id` from `module_enrichment/base/moduleList.json`
2. Trace the signal path through `processBlock` / `renderNextBlock` / `calculateBlock`
3. Trace voice lifecycle through `startNote` / `stopNote` (for per-voice modules)
4. Map `setAttribute` parameter indices to the parameter IDs in `moduleList.json`
5. Identify scope (`shared_resource`, `per_voice`, `monophonic`, `parameter`)
6. Identify external inputs (modulation chains via `getChildProcessorChain`)
7. Identify conditional behavior (parameter-dependent logic)
8. Assess CPU cost per node (`cpuWeight`)
9. Inspect the editor body / `createEditor()` for FloatingTile content types (-> `ui_component` seeAlso)
10. Assess custom equivalent feasibility
11. Produce the intermediate JSON

### Bug discovery policy

During C++ exploration, agents will encounter bugs, vestigial code, and inconsistencies. These must NOT be included in the intermediate JSON or any documentation output. Instead:

1. **Log bugs to `module_enrichment/issues.md`** using the same format as `enrichment/issues.md` (type, severity, location, observed, expected).
2. **Note vestigial/unimplemented features in `notes`** only as factual observations about the DSP path (e.g., "LowPassFreq parameter is defined but not applied in applyEffect()"). This tells downstream agents to exclude the feature from descriptions. Do not mention bug details, line numbers, or fixes.
3. **Never mention bugs, fixes, or code-level issues in documentation outputs** (`description`, `commonMistakes`, `llmRef`, etc.). Users should not see implementation bugs in their documentation.

The rationale: bugs are transient and will be fixed. Documentation is long-lived. Mixing bug reports into documentation creates maintenance burden and confuses users. The `issues.md` sidecar file gives the maintainer a clean list of actionable items discovered as a byproduct of the enrichment work.

### Batching strategy

Process modules in seeAlso clusters so cross-module relationships can be identified during production:

| Batch | Modules | Rationale |
|-------|---------|-----------|
| Envelopes | AHDSR, FlexAHDSR, SimpleEnvelope, TableEnvelope | Nearly identical topologies, good for format validation |
| Time modulators | LFO, ConstantModulator, RandomModulator, ArrayModulator | Monophonic signal generators, varying complexity |
| Voice start | Velocity, KeyNumber, PitchWheel, Aftertouch | MIDI-to-modulation converters, simple graphs |
| Global routing | GlobalModulatorContainer, GlobalVoiceStart*, GlobalTimeVariant*, GlobalEnvelope* | Producer/consumer chain, tests external_input nodes |
| Delays | Delay, Chorus, PhaseFX | Shared delay-line topology with variations |
| Filters | PolyphonicFilter, CurveEq, HarmonicFilter | Different filter topologies |
| Dynamics | Dynamics, SimpleGain, RouteFX, SendFX | Gain/routing effects |
| Samplers | StreamingSampler, Looper | Complex shared_resource + per_voice interaction |
| Containers | SynthChain, SynthGroup, GlobalModulatorContainer | Structural modules, test hasChildren |
| MIDI processors | Arpeggiator, TransposerMidiProcessor, ChannelFilter, ChannelRouter, ReleaseTrigger | Event transformation patterns |
| Custom | ScriptSynth, ScriptFX, Hardcoded* | Dynamic modules with scriptnode/compiled networks |

### Pilot batch

Start with **Envelopes** (AHDSR, FlexAHDSR, SimpleEnvelope, TableEnvelope):
- Well-understood modules with clear signal flows
- AHDSR already has a worked example in `module-enrichment/intermediate-format.md`
- Good test of whether the format captures per-voice modulation chains correctly
- The four modules should produce structurally similar graphs, validating the seeAlso derivation rules

### Which modules get intermediate JSONs

Not all 79 modules need signal flow exploration. Based on category:

| Category | Required? | Rationale |
|----------|-----------|-----------|
| `oscillator` | yes | Synthesis algorithm, waveform generation |
| `sample_playback` | yes | Playback engine, streaming, looping |
| `container` | optional | Voice mixing, FM routing (if applicable) |
| `sequencing` | yes | Event generation, timing, sequence logic |
| `note_processing` | yes | Event transformation |
| `dynamics` | yes | Processing chain, stage order, sidechain paths |
| `filter` | yes | Filter topology, modulation points |
| `delay` | yes | Delay topology, feedback paths, filter placement |
| `reverb` | yes | Algorithm structure |
| `mixing` | optional | Usually trivial, include for mid/side or complex routing |
| `routing` | optional | Signal routing between source and destination |
| `input` | yes | Event-to-signal conversion |
| `generator` | yes | Signal generation, envelope stages |
| `utility` | no | Mostly passthrough or non-audio |
| `custom` | no | User-defined, signal path depends on loaded network |

---

## Phase 2a: Real-World Project Analysis

**Input:** 14 HISE projects (submodules in the master repo)

**Output:** Per-module usage summaries in `module_enrichment/phase2a/`

### What the agent does

1. Scan all `.hip` / `.xml` preset files across the 14 projects
2. For each module instance found, record:
   - Module type, all non-default parameter values
   - Parent module, sibling modules, position in the module tree
3. Aggregate across projects:
   - Parameter histograms (median, p10, p90, outliers)
   - Co-occurrence matrix
   - Chain position patterns

### Output format

```json
{
  "moduleId": "AHDSR",
  "instanceCount": 47,
  "projectCount": 14,
  "parameterDistributions": {
    "Attack": { "median": 15.0, "p10": 1.0, "p90": 200.0, "outliers": [5000.0] },
    "Sustain": { "median": -6.0, "p10": -24.0, "p90": 0.0 }
  },
  "coOccurrence": [
    { "module": "Velocity", "count": 38, "relationship": "sibling in gain mod chain" },
    { "module": "StreamingSampler", "count": 42, "relationship": "parent sound generator" }
  ],
  "commonConfigurations": [
    { "description": "Pad envelope", "Attack": 500, "Decay": 1000, "Sustain": -6, "Release": 800, "frequency": 8 },
    { "description": "Pluck envelope", "Attack": 1, "Decay": 200, "Sustain": -100, "Release": 50, "frequency": 23 }
  ]
}
```

### Privacy and licensing

The 14 projects are all owned by or contributed with permission from the HISE author. No third-party project data is used. The analysis extracts aggregate statistics only.

---

## Phase 2b: Documentation Salvage

**Input:** `hise_documentation` GitHub repo (markdown files)

**Output:** Per-module documentation extracts in `module_enrichment/phase2b/`

### Coverage assessment

| Coverage level | Count | Examples |
|----------------|-------|---------|
| Substantial (multi-page) | ~5 | StreamingSampler (timestretching, HLAC, release start), MatrixModulator |
| Medium (1 page with detail) | ~10 | AHDSR, Delay, PolyphonicFilter, SimpleEnvelope |
| Frontmatter only (title + 1 line) | ~50+ | Most modulators, many effects |
| No docs at all | ~10 | Some routing modules, newer additions |

### What the agent does

1. Match documentation files to module IDs
2. Extract structured content:
   - Warnings and caveats -> `commonMistakes` candidates
   - "How to use" sections -> `llmRef` source material
   - Cross-references to other modules -> `seeAlso` candidates
   - Parameter-specific documentation -> enriched parameter descriptions
3. Flag conflicts between docs and C++ behavior (docs may be outdated)

### Handling sparse documentation

For the ~50 modules with frontmatter-only docs:
- Phase 1 provides the structural understanding
- Phase 2a provides practical context
- The LLM synthesizes these into documentation even without existing prose
- The `llmRef` clearly indicates when content is derived rather than from official docs

---

## Phase 3: LLM Enrichment

**Input:** All Phase 1 + 2a + 2b outputs for a batch of modules

**Output:** Enriched fields per module in `module_enrichment/phase3/`

### Knowledge sources (in priority order)

| Priority | Source | What it provides | Hallucination risk |
|----------|--------|-----------------|-------------------|
| 1 | Phase 1 intermediate JSON | Signal architecture, parameter mapping, scope | None (ground truth) |
| 2 | Phase 2b documentation | HISE-specific prose, warnings, workflows | Low (may be outdated) |
| 3 | Phase 2a project analysis | Real-world usage patterns, typical values | None (statistical) |
| 4 | Generic DSP knowledge | Purpose, acoustic behavior, typical use cases | Low - gated by Phase 1 |

**How generic DSP knowledge is applied:**

Generic DSP knowledge fills gaps where HISE-specific documentation is sparse. This is safe because the intermediate format from Phase 1 anchors everything to the actual C++ implementation. Generic knowledge explains *why* a module works the way it does and *when* to use it, not to invent features that don't exist.

- Explaining acoustic behavior (confirmed by Phase 1 graph structure)
- Parameter guidance (applied to specific parameters Phase 1 identified)
- Use case framing (helps users choose between modules)
- Performance intuition (general DSP facts about algorithmic cost)

**What generic DSP knowledge must NOT do:**

- Claim features not present in the intermediate JSON
- Describe a signal path that differs from the Phase 1 graph
- Invent parameter interactions not supported by the C++ implementation
- Suggest workarounds that depend on unverified module behavior

### Enriched field specifications

#### `description` (1-3 sentences)

Derived from the intermediate format, then refined:
- Input type + processing chain + output type + scope
- Key distinguishing features
- One sentence on when/why you'd use it

#### `commonMistakes` (0-5 entries)

Each: `{wrong, right, explanation}`. Sourced from documentation warnings, unusual parameter distributions, C++ gotchas, and general audio anti-patterns. Explanations reference observable behavior ("causes clicks", "wastes CPU"), not implementation details.

#### `seeAlso` (2-8 entries)

Each: `{id, type, reason}`. Relationship types:

| Type | Meaning | Reciprocal | Primary source |
|------|---------|-----------|---------------|
| `alternative` | Different module, similar purpose | `alternative` (symmetric) | Phase 1 (similar topology) |
| `source` | Produces signal/data this module needs | `target` | Phase 1 (external_input nodes) |
| `target` | Consumes signal/data this module produces | `source` | Phase 1 (external_input nodes) |
| `companion` | Commonly used together, no signal dependency | `companion` (symmetric) | Phase 2a (co-occurrence) |
| `ui_component` | FloatingTile or editor tied to this module | (none) | Phase 1 (C++ editor body) |
| `upgrade` | Replaces or extends this module's functionality | (none, directional) | Phase 2b + Phase 1 |
| `disambiguation` | Easily confused with this module | `disambiguation` (symmetric) | Phase 2b + Phase 2a |
| `scriptnode` | Equivalent scriptnode node wrapping the same DSP | `scriptnode` (symmetric) | C++ factory registry |

**Source/target examples:**

| Source module | Target module | What flows |
|---------------|---------------|-----------|
| GlobalModulatorContainer | GlobalVoiceStart/TimeVariant/EnvelopeModulator | Modulation values |
| MacroModulationSource | MacroModulator | Macro control values |
| SendFX | SendContainer | Audio signal (send bus) |

**UI component discovery:** Inspect `createEditor()` for FloatingTile content types (e.g., `AhdsrEnvelopePanel`, `SampleMapEditor`, `WaveformDisplay`).

**Scriptnode equivalents:** Known pairs include FlexAHDSR / `envelope.flex_ahdsr`, SimpleReverb / `fx.reverb`, PhaseFX / `fx.phase_delay`, Chorus / `fx.chorus`, PolyphonicFilter / `filters.*`. Cross-pipeline linkage: reciprocal entries on the scriptnode side will be added when the scriptnode enrichment pipeline runs.

#### `customEquivalent`

Guides users to rebuild stock module behavior using custom modules for full customization.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `approach` | enum | yes | `hisescript`, `scriptnode`, or `snex` |
| `moduleType` | string | yes | Custom module type to host the reproduction |
| `complexity` | enum | yes | `trivial`, `simple`, `medium`, `complex` |
| `description` | string | yes | One sentence explaining the approach |
| `snippetId` | string | no | ID into the snippet database for a working reproduction |
| `code` | string | no | Inline code for trivial/simple cases |

**Approaches:**

| Approach | When to use | Host module types |
|----------|-------------|-------------------|
| `hisescript` | Simple callback logic, event processing, table lookups | ScriptVoiceStartModulator, ScriptTimeVariantModulator, ScriptEnvelopeModulator, ScriptProcessor |
| `scriptnode` | DSP chains, effects with routing, node graph flexibility | HardcodedFX, HardcodedSynth, HardcodedTimeVariantModulator, etc. |
| `snex` | Per-sample math, waveshaping formulas, custom filter topologies | Any Hardcoded* module with a SNEX node |

**Which modules get `customEquivalent`:**
- **Skip**: `custom` category (already custom), containers, routing, utility
- **Include**: most leaf-level audio processors, modulators, and effects (~40-50 modules)

#### `llmRef` (multi-paragraph reference)

Verbatim text served by the MCP server. Structure:

```
ModuleName (type/subtype)

[1-2 sentence overview]

Signal flow:
  [arrow notation from intermediate format]

CPU: [baseline tier], [polyphonic/monophonic]
  [scaling factors if any]

Parameters:
  [grouped by function, with practical notes]
  [include default values and typical ranges from Phase 2a]

When to use:
  [practical guidance]

Common mistakes:
  [summary of commonMistakes entries]

Custom equivalent:
  [approach] via [moduleType]: [description]

See also:
  [type] ModuleName - reason
```

### Batch processing

Process modules in the same batches as Phase 1. The enrichment agent for a batch receives all intermediate JSONs, usage data, documentation extracts, and the full `moduleList.json` for cross-referencing. This ensures internally consistent seeAlso entries.

---

## Phase 4: Human Review

Every enriched module goes through human review before merging.

### Review checks

1. **Technical accuracy**: Does the signal flow description match the C++ implementation?
2. **commonMistakes validity**: Are the mistakes real? Are the fixes correct?
3. **seeAlso usefulness**: Do cross-references help users find the right module?
4. **llmRef quality**: Clear, accurate, concise, no hallucination?
5. **Parameter descriptions**: Better than the C++ tooltips?

### Review workflow

1. Agent produces a batch of enriched modules in `module_enrichment/phase3/`
2. Human reviews each module: approve / edit / reject
3. Approved modules are merged into `module_enrichment/output/moduleList.json`
4. Rejected modules get feedback and re-enter Phase 3

---

## Integration with MCP Server

Once enriched data is merged, the MCP server (`tools/mcp_server/`) needs updates to serve it:

1. **`query_module_parameter`** - Returns enriched parameter descriptions, mode, unit
2. **`list_module_types`** - Returns modules grouped by category with descriptions
3. **`search_hise` (modules domain)** - Indexes enriched descriptions, categories, seeAlso
4. **New: `query_module`** - Class-level query returning full module info, serves `llmRef` verbatim
5. **`explore_hise`** - Extended to include module relationships

---

## Session Prompts

Copy-paste these into an agent session to run the enrichment pipeline:

### Phase 1: Single module

```
Follow tools/api generator/doc_builders/module-enrichment.md. Run Phase 1 (C++ exploration) for AHDSR.
```

### Phase 1: Batch

```
Follow tools/api generator/doc_builders/module-enrichment.md. Run Phase 1 for the Envelopes batch (AHDSR, FlexAHDSR, SimpleEnvelope, TableEnvelope).
```

### SVG rendering

```
Follow tools/api generator/doc_builders/module-enrichment/svg-signal-flow-renderer.md. Render SVGs for all intermediate JSONs in module_enrichment/phase1/.
```

---

## Open Questions

1. **Intermediate JSON storage**: Stored as separate files in `module_enrichment/phase1/`, not inline in the output JSON. This avoids bloating the output but means the MCP server loads them on demand if needed.

2. **Dynamic (scriptnode) modules**: Their signal flow depends on the loaded network. Current approach: skip them (document the container, not the content). The `custom` category description already explains this.

3. **Enrichment depth for utility modules**: Modules like `EmptyFX` and `DebugLogger` have trivial signal paths. Proposal: minimal enrichment (description + seeAlso only, no intermediate JSON, no SVG).

4. **Pilot batch validation**: Validate Phase 1 alone first with the envelope batch before committing to Phases 2-3, since the intermediate format is the biggest unknown.
