# Module Enrichment Pipeline

**Purpose:** Transform 79 HISE audio processor modules from basic C++-extracted metadata into rich documentation with signal flow diagrams, performance models, usage guidance, and LLM-optimized reference text. Consumed by the MCP server, docs site, and SVG renderer.

**Base data:** `module_enrichment/base/moduleList.json`
**Output location:** `module_enrichment/enriched/` (one JSON per module)
**Sub-phase details:**
- `module-enrichment/preliminary-format.md` - Steps 1-2: preliminary JSON + gap listing
- `module-enrichment/exploration-guide.md` - Step 3: C++ source exploration
- `module-enrichment/enriched-format.md` - Step 4: enriched JSON authoring
- `module-enrichment/svg-signal-flow-renderer.md` - Step 5: SVG rendering from enriched JSON

---

## Strategic Context: Modules vs. Scripting API

The module enrichment pipeline runs parallel to the scripting API enrichment pipeline (`scripting-api-enrichment.md`) but addresses a fundamentally different documentation surface.

| Dimension | Scripting API | Modules |
|-----------|---------------|---------|
| Unit of work | Method on a class | Audio processor |
| Source of truth | C++ method body + Doxygen | C++ `processBlock` + module metadata |
| Shape of knowledge | Parameter types, return values, thread safety | Signal flow topology, parameter interactions, CPU cost |
| Visual output | None (text only) | SVG signal flow diagrams |
| User question | "What does this method do?" | "How does this module process audio?" |
| Agent judgment | Low (mostly mechanical extraction) | High (topology authoring, parameter placement) |

### Why Two JSON Formats

A single enrichment pass cannot produce the final signal-flow topology because the preliminary data (parameters, mod chains, I/O) maps to a fundamentally different structure than the enriched output (a directed graph with parameters placed at their point of action). The preliminary JSON is an inventory organized by data source. The enriched JSON is a topology organized by signal flow. You cannot "fill in the gaps" of one to get the other - the structure itself changes.

---

## Pipeline Overview

```
moduleList.json (base data, 79 modules)
        |
  [Step 1] Agent creates preliminary JSON
        |    - Parameter grouping, composite blocks, I/O inference
        |    - Uses inference tables (type/subtype, category, interface)
        |    - Gate: Have I used ALL base JSON information?
        |
  [Step 2] Agent lists exploration gaps
        |    - Structured questions for C++ exploration
        |    - Written into preliminary JSON's gaps field
        |    - Gate: Are gaps specific enough?
        |
  [Step 3] Agent explores C++ source
        |    - Answers gap questions from processBlock/renderNextBlock
        |    - Writes exploration markdown
        |    - Flags base JSON issues in issues.md
        |    - Gate: ALL gaps answered? ALL issues flagged?
        |
  [Step 4] Agent authors enriched JSON
        |    - Fresh signal-flow topology
        |    - Parameters at point of action
        |    - Composite blocks carried forward
        |    - Gate: ALL parameters accounted for?
        |           ALL exploration answers incorporated?
        |           ALL interfaces accounted for?
        |
  [Step 5] Renderer produces SVG
        |    - Reads enriched JSON
        |    - Resolves metadata from moduleList.json
        |    - ELK layout + custom SVG rendering
        |    - Budget filter for complexity tiers
        v
  module_enrichment/enriched/{ModuleId}.json
  svg_renderer/output/{ModuleId}.svg
```

### Step summary

| Step | Agent type | Input | Output | Guide |
|------|-----------|-------|--------|-------|
| 1-2 | General | moduleList.json entry | `module_enrichment/preliminary/{ModuleId}.json` | `preliminary-format.md` |
| 3 | Explorer | Preliminary JSON + C++ source | `module_enrichment/exploration/{ModuleId}.md` | `exploration-guide.md` |
| 4 | General | Preliminary JSON + exploration markdown | `module_enrichment/enriched/{ModuleId}.json` | `enriched-format.md` |
| 5 | Automated | Enriched JSON + moduleList.json | `svg_renderer/output/{ModuleId}.svg` | `svg-signal-flow-renderer.md` |

---

## Directory Structure

```
tools/api generator/
  doc_builders/
    module-enrichment.md                      # This file (pipeline orchestrator)
    module-enrichment/
      preliminary-format.md                   # Steps 1-2 guide + schema
      exploration-guide.md                    # Step 3 guide
      enriched-format.md                      # Steps 4-5 guide + schema
      svg-signal-flow-renderer.md             # SVG renderer spec
    old/                                      # Superseded specs (reference only)
      module-enrichment.md
      module-enrichment/
        intermediate-format.md
        svg-signal-flow-renderer.md

  module_enrichment/
    base/
      moduleList.json                         # Phase 0 output: 79 modules, read-only
    preliminary/                              # Step 1-2 output
      {ModuleId}.json                         # One per module
    exploration/                              # Step 3 output
      {ModuleId}.md                           # One per module
    enriched/                                 # Step 4 output (final)
      {ModuleId}.json                         # One per module
    issues.md                                 # Sidecar: bugs found during exploration

  svg_renderer/
    src/
      render.ts                               # CLI entry point
      types.ts                                # TypeScript types (to be updated)
      rules.ts                                # Visual modifier rules
    output/
      {ModuleId}.svg                          # Step 5 output
      {ModuleId}_baseline.svg                 # Baseline SVGs (design reference)
    package.json
    tsconfig.json
```

---

## Base Data: moduleList.json

The base data is extracted mechanically from C++ source code by the Phase 0 tool. Each module entry contains:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Internal module ID (e.g., `"AHDSR"`, `"Delay"`) |
| `name` | string | Display name |
| `type` | string | Top-level type: `Modulator`, `SoundGenerator`, `Effect`, `MidiProcessor` |
| `subtype` | string | Specific subtype (see inference table below) |
| `category` | string | Comma-separated category tags |
| `description` | string | Short description from C++ metadata |
| `parameters` | array | Parameter definitions with id, name, range, default, description |
| `modulationChains` | array | Modulation chain definitions with cross-references |
| `interfaces` | array | Implemented processor interfaces |
| `hasChildren` | boolean | Whether the module hosts child processors |
| `hasFX` | boolean | Whether the module has an FX chain slot |
| `constrainer` | string | What types of child processors are allowed |
| `fx_constrainer` | string | What effects can go in the FX chain |

Each parameter may have:
- `chainIndex` linking it to a modulation chain
- `tempoSyncIndex` linking it to a tempo sync toggle parameter

Each modulation chain may have:
- `parameterIndex` linking it back to the parameter it modulates
- `constrainer` restricting what modulator types can be added

### Module counts

| Type/Subtype | Count |
|-------------|-------|
| Effect/MasterEffect | 18 |
| SoundGenerator/SoundGenerator | 14 |
| MidiProcessor/MidiProcessor | 12 |
| Modulator/EnvelopeModulator | 11 |
| Modulator/VoiceStartModulator | 9 |
| Modulator/TimeVariantModulator | 7 |
| Effect/VoiceEffect | 7 |
| Effect/MonophonicEffect | 1 |
| **Total** | **79** |

Of the 79 modules, 14 are in the `custom` category (user-defined signal paths). These get a brief structural diagram showing the callback/network slots rather than a fixed signal flow. Detailed treatment is deferred.

---

## Inference Tables

These tables define what can be mechanically inferred from moduleList.json fields without C++ exploration. Steps 1-2 use these tables to build the preliminary JSON.

### Type/Subtype Inference Table

| type/subtype | MIDI in | Voice context | Output | Audio in |
|---|---|---|---|---|
| Modulator/EnvelopeModulator | noteOn + noteOff | per-voice | modulation | none |
| Modulator/VoiceStartModulator | noteOn | per-voice | modulation | none |
| Modulator/TimeVariantModulator | none | monophonic | modulation | none |
| SoundGenerator/SoundGenerator | noteOn + noteOff | per-voice | audio L/R | none |
| Effect/MasterEffect | none | monophonic | audio L/R | audio L/R |
| Effect/VoiceEffect | none | per-voice | audio (voice) | audio (voice) |
| Effect/MonophonicEffect | none | monophonic | audio | audio |
| MidiProcessor/MidiProcessor | MIDI in | monophonic | MIDI out | none |

### Category Inference Table

| Category | Inference for diagram |
|----------|----------------------|
| `input` | Module reads from a specific MIDI value source (velocity, CC, key, pitch wheel) |
| `note_processing` | MIDI event transformation (MIDI in -> transform -> MIDI out) |
| `sequencing` | Temporal/pattern behavior, may generate MIDI events |
| `container` + `hasChildren: true` | Child module slots with constrainer-defined types |
| `delay` | Delay-line topology with potential feedback paths |
| `dynamics` | Gain/compression processing chain |
| `filter` | Filter topology with frequency/resonance modulation points |
| `reverb` | Reverb algorithm structure |
| `routing` | Signal routing emphasis (send/receive, channel mapping) |
| `oscillator` | Periodic waveform output (also applies to modulators like LFO) |
| `sample_playback` | Sample streaming, looping, pitch shifting |
| `mixing` | Signal combination (usually simple, may have mid/side) |
| `utility` | Mostly passthrough or non-audio (often no signal flow diagram needed) |
| `custom` | Show callbacks/network slots as nodes (framework, not fixed signal path) |
| `generator` | Signal generation, envelope stages |

### Interface-to-Node Mapping

Interfaces declared in moduleList.json map to specific node types in the signal flow diagram.

| Interface | Diagram representation |
|-----------|----------------------|
| `TableProcessor` | Lookup table node in signal path |
| `SliderPackProcessor` | Slider pack / step sequencer node |
| `AudioSampleProcessor` | Audio sample resource node |
| `SlotFX` | Hot-swappable effect slot node |
| `DisplayBufferSource` | Display buffer (UI communication point, not in signal path) |
| `RoutingMatrix` | Skip - inferred from type/subtype |
| `Sampler` | Skip - single-consumer, redundant with module identity |
| `WavetableController` | Skip - single-consumer, redundant |
| `MidiPlayer` | Skip - single-consumer, redundant |

### Composite Block Patterns

Two reusable sub-graph patterns appear across multiple modules. The agent identifies these in Step 1 and carries them through to the enriched JSON.

**modMultiply** - Parameter modulated by a modulation chain:
- Trigger: Parameter has a `chainIndex` linking it to a modulation chain
- Rendering: `[Param] -> (*) <- [ModChain]` with constrainer-derived icon
- Icon selection: If the mod chain's `constrainer` contains `VoiceStartModulator`, use pulse icon (`"pulse"` in JSON, rendered as SVG symbol `icon-voice-start`). Otherwise use sine icon (`"sine"` in JSON, rendered as SVG symbol `icon-sine`).
- The modulation chain's `parameterIndex` links back to confirm the cross-reference.

**tempoSyncMux** - Time parameter with tempo sync option:
- Trigger: Parameter has a `tempoSyncIndex` pointing to a toggle parameter
- Rendering: `[Param] -> [TempoSync] <- [Host BPM]` as an inline trapezoid node
- Host BPM is an implicit external input inferred from the presence of `tempoSyncIndex`
- Only 3 parameters across all 79 modules use this pattern (Delay: DelayTimeLeft, DelayTimeRight; LFO: Frequency)

### Standalone Modulation Chains

All modulation chains with `modulationMode: "pitch"` (15 total across all modules) have no `parameterIndex` - they modulate an implicit base pitch rather than a named parameter. These are rendered as standalone modulation inputs feeding into the voice's pitch calculation, not as modMultiply composites.

Similarly, `Gain Modulation` chains at `chainIndex:1` with `parameterIndex:0` follow a base-class pattern on nearly all SoundGenerators. These are standard modMultiply blocks.

Four modulation chains across all modules are disabled. These should be rendered differently (grayed out) or omitted entirely based on agent judgment.

---

## Gate Conditions Overview

Every step ends with a gate checklist that must be satisfied before proceeding. Gates prevent incomplete work from cascading into downstream steps.

| Step | Gate | Key check |
|------|------|-----------|
| 1 | Completeness | Have I used ALL information available in the base JSON entry? |
| 2 | Specificity | Are gap questions specific enough for targeted C++ exploration? |
| 3 | Coverage | Have I answered ALL gap questions? Flagged ALL description issues? |
| 4 | Accountability | Are ALL parameters accounted for (placed, consumed by composite, or explicitly omitted with reason)? Are ALL exploration answers incorporated (or stated why not)? Are ALL interfaces accounted for? |
| 5 | Visual quality | Is the SVG legible at 800px? Are all nodes and edges present? Do composites render inline? |

Full gate checklists are in each step's sub-document.

---

## Batching Strategy

Process modules in seeAlso clusters so cross-module relationships can be identified during production:

| Batch | Modules | Rationale |
|-------|---------|-----------|
| Envelopes (pilot) | AHDSR, FlexAHDSR, SimpleEnvelope, TableEnvelope | Nearly identical topologies, good for format validation |
| Time modulators | LFO, ConstantModulator, RandomModulator, ArrayModulator | Monophonic signal generators, varying complexity |
| Voice start | Velocity, KeyNumber, PitchWheel, Aftertouch | MIDI-to-modulation converters, simple graphs |
| Global routing | GlobalModulatorContainer, GlobalVoiceStart*, GlobalTimeVariant*, GlobalEnvelope* | Producer/consumer chain, tests external_input nodes |
| Delays | Delay, Chorus, PhaseFX | Shared delay-line topology with variations |
| Filters | PolyphonicFilter, CurveEq, HarmonicFilter | Different filter topologies |
| Dynamics | Dynamics, SimpleGain, RouteFX, SendFX | Gain/routing effects |
| Samplers | StreamingSampler, Looper | Complex shared_resource + per_voice interaction |
| Containers | SynthChain, SynthGroup, GlobalModulatorContainer | Structural modules, test hasChildren |
| MIDI processors | Arpeggiator, TransposerMidiProcessor, ChannelFilter, ChannelRouter, ReleaseTrigger | Event transformation patterns |
| Custom | ScriptSynth, ScriptFX, Hardcoded* | Dynamic modules - show framework slots, defer internals |

Start with the **Envelopes** pilot batch. AHDSR already has baseline SVGs and exploration notes, providing immediate format validation. The four envelope modules should produce structurally similar graphs, validating cross-module consistency.

### Which modules need signal flow exploration

Not all 79 modules need C++ exploration. Based on category:

| Category | C++ exploration? | Rationale |
|----------|-----------------|-----------|
| `oscillator`, `generator` | yes | Synthesis algorithm, waveform generation |
| `sample_playback` | yes | Playback engine, streaming, looping |
| `filter`, `delay`, `reverb` | yes | DSP topology, feedback paths, modulation points |
| `dynamics` | yes | Processing chain, stage order, sidechain paths |
| `input` | yes | Event-to-signal conversion logic |
| `note_processing`, `sequencing` | yes | Event transformation, timing logic |
| `container` | optional | Voice mixing, FM routing (if applicable) |
| `routing`, `mixing` | optional | Usually trivial; include for mid/side or complex routing |
| `utility` | no | Mostly passthrough or non-audio |
| `custom` | no | User-defined signal path depends on loaded network |

---

## Enriched Output Fields

The enriched JSON (produced in Step 4) is fully specified in `enriched-format.md`. This section documents the additional cross-cutting fields that appear in the final enriched output but are not part of the signal-flow topology.

### seeAlso (2-8 entries per module)

Each entry: `{id, type, reason}`. Relationship types:

| Type | Meaning | Reciprocal | Primary source |
|------|---------|-----------|---------------|
| `alternative` | Different module, similar purpose | `alternative` (symmetric) | Step 3 (similar topology) |
| `source` | Produces signal/data this module needs | `target` | Step 3 (external_input nodes) |
| `target` | Consumes signal/data this module produces | `source` | Step 3 (external_input nodes) |
| `companion` | Commonly used together, no signal dependency | `companion` (symmetric) | Deferred (Phase 2a) |
| `ui_component` | FloatingTile or editor tied to this module | (none) | Step 3 (C++ `createEditor()`) |
| `upgrade` | Replaces or extends this module's functionality | (none, directional) | Step 3 + documentation |
| `disambiguation` | Easily confused with this module | `disambiguation` (symmetric) | Documentation + judgment |
| `scriptnode` | Equivalent scriptnode node wrapping the same DSP | `scriptnode` (symmetric) | C++ factory registry |

**Source/target examples:**

| Source module | Target module | What flows |
|---------------|---------------|-----------|
| GlobalModulatorContainer | GlobalVoiceStart/TimeVariant/EnvelopeModulator | Modulation values |
| MacroModulationSource | MacroModulator | Macro control values |
| SendFX | SendContainer | Audio signal (send bus) |

**UI component discovery:** Inspect `createEditor()` for FloatingTile content types (e.g., `AhdsrEnvelopePanel`, `SampleMapEditor`, `WaveformDisplay`).

**Scriptnode equivalents:** Known pairs include FlexAHDSR / `envelope.flex_ahdsr`, SimpleReverb / `fx.reverb`, PhaseFX / `fx.phase_delay`, Chorus / `fx.chorus`, PolyphonicFilter / `filters.*`.

### cpuProfile

Two-level CPU performance model. Hardware-independent, relative to "a simple gain multiply."

**Node-level** (in enriched JSON processing nodes):

| Field | Type | Description |
|-------|------|-------------|
| `cpuWeight.base` | enum | Inherent cost tier: `negligible`, `low`, `medium`, `high`, `very_high` |
| `cpuWeight.scaleFactor` | object | Optional. Parameter that multiplies cost. |
| `cpuWeight.scaleFactor.parameter` | string | Parameter ID from moduleList.json |
| `cpuWeight.scaleFactor.description` | string | How the parameter affects CPU cost |

**Base cost tiers:**

| Tier | Examples |
|------|----------|
| `negligible` | Parameter read, bypass check, simple decision |
| `low` | Gain multiply, simple mix, table lookup |
| `medium` | Biquad filter, delay line read/write, envelope calculation |
| `high` | Multi-mode filter, FFT-based processing, per-sample nonlinearity |
| `very_high` | Convolution, large FFT, heavy oversampling |

**Module-level** (rolled up in enriched output):

| Field | Type | Description |
|-------|------|-------------|
| `baseline` | enum | Overall CPU cost at default settings (same tier enum) |
| `polyphonic` | boolean | Per-voice (true) or per-buffer (false) |
| `scalingFactors` | array | Parameters that significantly increase CPU beyond baseline. Each entry: `{parameter, impact, note}` |

**Derivation:**
- `baseline`: highest `cpuWeight.base` among nodes on the main signal path
- `polyphonic`: from the module's subtype, confirmed by per_voice scope nodes
- `scalingFactors`: collected from all nodes with `cpuWeight.scaleFactor` entries. The node-level `scaleFactor.description` field becomes the module-level `note` field; `impact` is the cost tier of the scaling effect.

### commonMistakes (0-5 entries per module)

Each entry: `{wrong, right, explanation}`.

Sources: documentation warnings, C++ gotchas from Step 3, general audio anti-patterns. Explanations must reference observable behavior ("causes clicks", "wastes CPU"), never implementation details. Skip modules where no meaningful mistakes exist.

### customEquivalent

Guides users to rebuild stock module behavior using custom modules.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `approach` | enum | yes | `hisescript`, `scriptnode`, or `snex` |
| `moduleType` | string | yes | Custom module type to host the reproduction |
| `complexity` | enum | yes | `trivial`, `simple`, `medium`, `complex` |
| `description` | string | yes | One sentence explaining the approach |
| `snippetId` | string | no | ID into the snippet database |

| Approach | When to use | Host module types |
|----------|-------------|-------------------|
| `hisescript` | Simple callback logic, event processing, table lookups | ScriptVoiceStartModulator, ScriptTimeVariantModulator, ScriptEnvelopeModulator, ScriptProcessor |
| `scriptnode` | DSP chains, effects with routing, node graph flexibility | HardcodedFX, HardcodedSynth, HardcodedTimeVariantModulator, etc. |
| `snex` | Per-sample math, waveshaping formulas, custom filter topologies | Any Hardcoded* module with a SNEX node |

Skip for: `custom` category (already custom), containers, routing, utility.

### llmRef (multi-paragraph reference)

Pre-synthesized text blob served verbatim by the MCP server. Fixed section order:

```
ModuleName (type/subtype)

[1-2 sentence overview]

Signal flow:
  [arrow notation derived from enriched JSON topology]

CPU: [baseline tier], [polyphonic/monophonic]
  [scaling factors if any]

Parameters:
  [grouped by function, with practical notes]
  [include default values and typical ranges]

When to use:
  [practical guidance]

Common mistakes:
  [summary of commonMistakes entries]

Custom equivalent:
  [approach] via [moduleType]: [description]

See also:
  [type] ModuleName - reason
```

---

## Complexity Budget

The enriched JSON includes an `importance` value (0.0-1.0) on each processing node, enabling multi-resolution SVG rendering from a single data source.

| Budget tier | Target use | Importance threshold | Typical node count |
|-------------|-----------|---------------------|-------------------|
| `overview` | Tooltip, quick reference | >= 0.8 | 3-5 nodes |
| `thumbnail` | Documentation sidebar | >= 0.5 | 5-10 nodes |
| `documentation` | Full documentation page | >= 0.0 (all nodes) | 8-20 nodes |

The SVG renderer filters nodes by budget before layout. Edges connected to filtered-out nodes are also removed. Groups containing no visible nodes after filtering are removed.

Importance assignment guidelines:
- I/O nodes: 1.0 (always visible)
- Main signal path nodes: 0.7-0.9
- Modulation/control inputs: 0.4-0.6
- Secondary paths, conditional branches: 0.2-0.4
- Implementation detail nodes: 0.1 (documentation-only)

---

## Session Launcher Templates

Each step is launched as an agent session. The sub-documents are self-contained instruction manuals. These templates are the launcher prompts.

### Steps 1-2: Preliminary JSON

```
Process module "{ModuleId}" through Steps 1-2 of the module enrichment pipeline.

Read the guide: doc_builders/module-enrichment/preliminary-format.md
Read the base data entry for {ModuleId} from: module_enrichment/base/moduleList.json
Read the inference tables in: doc_builders/module-enrichment.md (Inference Tables section)

Output: module_enrichment/preliminary/{ModuleId}.json

Follow the gate checklists at the end of each step.
```

### Step 3: C++ Exploration

```
Explore the C++ source for module "{ModuleId}".

Read the guide: doc_builders/module-enrichment/exploration-guide.md
Read the preliminary JSON: module_enrichment/preliminary/{ModuleId}.json
Explore the C++ source at the repository root.

Output: module_enrichment/exploration/{ModuleId}.md
Issues: append to module_enrichment/issues.md

Follow the gate checklist. Answer ALL gap questions from the preliminary JSON.
```

### Step 4: Enriched JSON

```
Author the enriched JSON for module "{ModuleId}".

Read the guide: doc_builders/module-enrichment/enriched-format.md
Read the preliminary JSON: module_enrichment/preliminary/{ModuleId}.json
Read the exploration markdown: module_enrichment/exploration/{ModuleId}.md
Read the base data for metadata resolution: module_enrichment/base/moduleList.json

Output: module_enrichment/enriched/{ModuleId}.json

Follow the gate checklist. Account for ALL parameters.
```

### Step 5: SVG Rendering

```
Render SVG for module "{ModuleId}".

npx tsx src/render.ts ../module_enrichment/enriched/{ModuleId}.json output/{ModuleId}.svg

Run from: tools/api generator/svg_renderer/
```

### Batch processing

For a batch, process all modules in the batch through Steps 1-2 together, then Step 3 together, then Step 4 together. This ensures cross-module consistency within the seeAlso cluster.

---

## Feedback Loop Prevention

- Steps 1-2 use ONLY moduleList.json and the inference tables in this document. Never reference enriched output, exploration markdown, or SVG output.
- Step 3 uses ONLY the preliminary JSON and C++ source code. Never reference enriched output or previous exploration markdown for other modules (cross-contamination).
- Step 4 uses the preliminary JSON, exploration markdown, and moduleList.json. Never reference SVG output or other modules' enriched JSONs (except within a batch for seeAlso cross-referencing).
- Step 5 is automated and reads only enriched JSON + moduleList.json.

---

## Deferred Work

### Phase 2a: Real-World Project Analysis

Scanning 14 HISE projects for parameter histograms, co-occurrence matrices, and common configurations. This would feed `companion` seeAlso entries and "typical ranges" in llmRef. Not yet started; deferred until the core pipeline (Steps 1-5) is validated on the pilot batch.

### Phase 2b: Documentation Salvage

Extracting prose from the `hise_documentation` GitHub repo. Coverage is sparse (only ~5 modules have substantial docs, ~10 medium, ~50+ frontmatter only). Deferred until core pipeline validation.

### SVG Renderer Update

The existing renderer (`svg_renderer/src/`) currently consumes the old intermediate JSON format. It needs updating to consume the new enriched JSON format. The visual design system (colors, shapes, edge styles) is preserved. See `svg-signal-flow-renderer.md` for the updated spec.

---

## Open Questions

1. **Importance calibration:** Should importance values be assigned during Step 4 (agent judgment) or derived mechanically from the graph topology (e.g., nodes on the shortest path from input to output get higher importance)?

2. **seeAlso batch consistency:** When processing a batch, should the agent produce seeAlso entries for all modules in the batch simultaneously, or produce them per-module and reconcile at the end?

3. **Custom category depth:** The 14 custom modules show callback/network slots as nodes. How much internal structure should be shown? Just the slot types, or also the available callback signatures?

4. **cpuProfile validation:** The hardware-independent tier system is inherently subjective. Should we validate tiers against actual profiling data, or accept expert judgment?
