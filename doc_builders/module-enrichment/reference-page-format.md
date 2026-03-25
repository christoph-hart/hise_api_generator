# Reference Page Format (Step 4)

**Purpose:** Author a complete module reference page as MDC markdown. The page combines interactive pseudo-code, parameter tables, modulation chain tables, and prose into a single document rendered by Nuxt.js with custom Vue components. This is the final deliverable of the enrichment pipeline.

**Input:** `module_enrichment/exploration/{ModuleId}.json` (graph) + `module_enrichment/exploration/{ModuleId}.md` (findings) + `module_enrichment/base/moduleList.json`
**Output:** `module_enrichment/pages/{ModuleId}.md`
**Design reference:** `module_enrichment/resources/reference/` (5 HTML prototypes)

---

## What This Format Is

The reference page is an **MDC markdown file** - standard markdown extended with Vue component blocks using Nuxt Content's `::component` syntax. The page is rendered by a Nuxt.js docs site with three custom components:

1. **`::signal-path`** - Interactive pseudo-code with glossary-based syntax highlighting and hover tooltips
2. **`::parameter-table`** - Grouped parameter display with ranges, defaults, and descriptions
3. **`::modulation-table`** - Modulation chain listing with scope and constrainer info

Regular markdown handles the rest: frontmatter metadata, headings, prose paragraphs, screenshots, and notes.

---

## Page Template

Every module reference page follows this structure:

```markdown
---
title: Module Display Name
moduleId: ModuleId
type: Effect|Modulator|SoundGenerator|MidiProcessor
subtype: MasterEffect|EnvelopeModulator|VoiceStartModulator|...
tags: [category tags from moduleList.json]
builderPath: b.Effects.Delay
screenshot: /modules/moduleid.png
cpuProfile:
  baseline: low|medium|high|very_high
  polyphonic: true|false
  scalingFactors: []
seeAlso:
  - { id: ModuleId, type: alternative|scriptnode|ui_component|..., reason: "..." }
commonMistakes:
  - { wrong: "...", right: "...", explanation: "..." }
customEquivalent:
  approach: hisescript|scriptnode|snex
  moduleType: "..."
  complexity: trivial|simple|medium|complex
  description: "..."
---

# Module Display Name

![Module screenshot](/modules/moduleid.png)

[1-2 paragraphs of overview prose. What the module does, when to use it,
key characteristics. Written for HISEScript developers - no C++ internals.]

## Signal Path

::signal-path
---
glossary:
  parameters:
    ParamName:
      desc: "What this parameter controls"
      range: "0 - 100%"
      default: "50%"
  functions:
    funcName:
      desc: "What this processing step does"
  modulations:
    ModChainName:
      desc: "What this modulation chain scales"
      scope: "per-voice"
---

` `` [pseudo-code language marker not needed]
// Module Name - brief description
// [input type] in -> [output type] out

callbackOrFlow() {
    // pseudo-code here
}
` ``

::

## Parameters

::parameter-table
---
groups:
  - label: Group Name
    params:
      - { name: ParamName, desc: "Description", range: "min - max unit", default: "value" }
---
::

## Modulation Chains

::modulation-table
---
chains:
  - { name: ChainName, desc: "What it scales", scope: "per-voice", constrainer: "VoiceStartModulator" }
---
::

## Notes

[Implementation observations in regular markdown. Vestigial parameters,
non-obvious behaviours, practical tips. No C++ internals.]

## See Also

- **Scriptnode:** `equivalent.node` - description of the equivalent
- **UI Component:** `FloatingTileName` - what it displays
- **Alternative:** ModuleName - how it differs
```

### Section Rules

- **Frontmatter** is required. All structured metadata lives here (seeAlso, cpuProfile, commonMistakes, customEquivalent).
- **Overview prose** is required. 1-2 paragraphs.
- **Signal Path** is required for all modules except containers and custom-category modules.
- **Parameters** is required if the module has parameters.
- **Modulation Chains** is required if the module has modulation chains. Omit the section entirely if there are none.
- **Notes** is optional. Include only if there are non-obvious behaviours worth documenting.
- **See Also** is required. At least 2 entries per module.

---

## Prose Authoring Rules

### Audience

HISEScript developers who have no knowledge of C++ internals. They want to understand what a module does, how its parameters interact, and what to watch out for.

### What to Include

- What the module does in practical terms
- How the signal flows through it (the pseudo-code covers this visually; the prose provides context)
- Parameter interactions and non-obvious behaviours
- When to use this module vs alternatives
- Practical limitations

### What to Strip

These must NEVER appear in the reference page prose. They are C++ implementation details.

- **C++ class names** - e.g. `HardcodedScriptProcessor`, `EnvelopeModulator`, `MasterEffectProcessor`
- **C++ type names** - e.g. `juce::BigInteger`, `AudioSampleBuffer`, `DynamicObject`
- **C++ method names** - e.g. `setInternalAttribute()`, `processBlock()`, `applyEffect()`
- **Assertion macros** - e.g. `jassertfalse`, `JUCE_ASSERT`
- **Source code references** - e.g. "defined in DelayEffect.cpp line 142"
- **Implementation mechanisms** - e.g. "uses a 1024-sample crossfade in the DelayLine class"

### Translation Table

| Exploration finding (C++ aware) | Reference page prose |
|---|---|
| "Implemented as HardcodedScriptProcessor with scripting callbacks" | "A built-in MIDI processor" |
| "Uses juce::BigInteger bitmask for channel range" | "Checks the message channel against the allowed range" |
| "Message.ignoreEvent(true) flags the message" | "Non-matching messages are silently skipped by downstream processors" |
| "overlap fader (scriptnode::faders::overlap)" | "Uses an overlap fader for dry/wet mixing" |
| "1024-sample crossfade in DelayLine" | "Crossfades when delay time changes to prevent clicks" |
| "expRamp uses exponential coefficients, not lookup tables" | "All curve shapes use exponential ramps" |
| "VoiceData struct stores per-voice state" | "Each voice maintains its own envelope state" |
| "Dispatched via MessageManager::callAsync" | *(omit - not relevant to module behaviour)* |

### Vestigial Parameters

Vestigial parameters (defined but non-functional) should be noted factually in the parameter table description: "This parameter has no effect." Do not reference C++ line numbers, fix suggestions, or bug analysis. The Notes section may add a brief mention: "The `EcoMode` parameter is vestigial - downsampling is now controlled globally."

### Tone

- **Direct and practical.** Explain what the module does, not how it is implemented.
- **Concise.** Avoid filler words and unnecessary qualifications.
- **British English** throughout (behaviour, normalised, serialised, etc.).
- **No marketing language.** No "powerful", "flexible", "easy-to-use".
- **Scale to module complexity.** Simple modules (ChannelFilter) get brief prose. Complex modules (AHDSR, WaveSynth) get fuller explanations.

### Bug Discovery Policy

Implementation bugs must NOT appear in the reference page. See `exploration-guide.md` section "Bug Discovery Policy" for the full policy. Report bugs in `module_enrichment/issues.md` only.

---

## Pseudo-Code Authoring

### Purpose

The pseudo-code is a visual explanation of the module's internal signal path. It is NOT executable code and should not be mistaken for a real API. It exists to communicate the processing logic more concisely than prose.

The `::signal-path` component renders a subtle label: "Pseudo-code - hover highlighted terms for details" to make this clear.

### Deriving from Graph JSON

The graph JSON from Step 3 (`module_enrichment/exploration/{ModuleId}.json`) is the structured source for pseudo-code. The transformation:

1. **Walk the graph** from input nodes to output nodes following signal-flow edges.
2. **High-importance nodes** (>= 0.7) become code statements or expressions.
3. **Medium-importance nodes** (0.3-0.7) may become comments or be folded into adjacent statements.
4. **Low-importance nodes** (< 0.3) are typically omitted.
5. **Decision nodes** become `if/else` blocks.
6. **Feedback edges** become explicit loop patterns (write then read).
7. **Groups** may become logical sections separated by blank lines or comments.

### Style

- Use C/JS-style syntax: curly braces, dot notation, semicolons optional
- Use natural, descriptive names - not C++ method names
- Comments use `//` and describe what a section does, not how
- Indentation is 4 spaces
- Keep it short: 5-25 lines for most modules

### Callback Framing

Callback-style framing is **optional** - use it when it clarifies the execution model:

| Situation | Approach |
|-----------|----------|
| Audio processor with continuous input | `process(left, right) { ... }` |
| Envelope with distinct note-on/off phases | `onNoteOn() { ... }` / `onNoteOff() { ... }` |
| MIDI processor filtering events | `onMidiEvent(message) { ... }` |
| Simple modulator with no event trigger | Flat flow without a wrapper function |

Do not invent callback names that imply a real API. If wrapping in a function name feels forced, use a flat flow with a comment header instead.

### Glossary

The glossary is the key to the interactive highlighting. Every term that should be highlighted in the pseudo-code must appear in exactly one glossary category:

| Category | Colour | What to include | Tooltip shows |
|----------|--------|----------------|---------------|
| `parameters` | Blue (#4a9eff) | Module parameters from moduleList.json that appear in the pseudo-code | desc, range, default |
| `functions` | Orange (#f97316) | Non-obvious processing operations (not simple assignments or arithmetic) | desc |
| `modulations` | Green (#90FFB1) | Modulation chain names that appear as multipliers in the pseudo-code | desc, scope |

**Glossary key rules:**
- Keys must be valid identifiers (no spaces, no special characters)
- Keys must be unique across all three categories
- Use the exact parameter ID from moduleList.json for parameters
- Use the exact modulation chain name for modulations
- For functions, use the name as it appears in the pseudo-code

**What NOT to glossary-highlight:**
- Local variables (e.g. `wetL`, `attackTime`)
- Literal values
- Standard operators and keywords (`if`, `else`, `return`)
- Simple arithmetic operations

---

## Parameter Table

The `::parameter-table` component renders a grouped table with columns: Parameter, Description, Range, Default.

### Grouping

Group parameters by function, not by parameter index. Good group labels:
- "Envelope" (Attack, Hold, Decay, Sustain, Release)
- "Delay Time" (DelayTimeLeft, DelayTimeRight, TempoSync)
- "Feedback" (FeedbackLeft, FeedbackRight)
- "Curve Shape" (AttackCurve, DecayCurve)
- "Voice Mode" (Monophonic, Retrigger)

If a group of parameters is vestigial, label the group accordingly: "Filtering (Vestigial)".

### Data Source

Parameter metadata comes from `moduleList.json`. The agent resolves ranges, defaults, and descriptions. Descriptions should be rewritten for the user audience (strip C++ internals).

### Range Formatting

| Parameter type | Range format |
|---------------|-------------|
| Slider (ms) | `0 - 20000 ms` |
| Slider (%) | `0 - 100%` |
| Slider (Hz) | `20 - 20000 Hz` |
| Slider (dB) | `-100 - 0 dB` |
| Slider (0-1) | `0.0 - 1.0` |
| Button | `On / Off` |
| Discrete | `1 - 16` |
| ComboBox | List the items: `Sine, Triangle, Saw, Square, Noise` |

### Default Formatting

- Numeric defaults: use the unit (`20 ms`, `30%`, `0.5`)
- Button defaults: `On` or `Off`
- Dynamic defaults: `(dynamic)` if the default depends on runtime state

---

## Modulation Chains Table

The `::modulation-table` component renders a table with columns: Chain, Description, Scope, Constrainer.

Include all modulation chains from moduleList.json that are not disabled. For disabled chains, omit them or note in the Notes section why they are disabled.

---

## See Also Section

The See Also section uses regular markdown (no custom component). It surfaces cross-module relationships discovered during C++ exploration.

### Required relationship types

| Type | When to include | Format |
|------|----------------|--------|
| `scriptnode` | Module has a scriptnode equivalent | `**Scriptnode:** \`node.name\` - brief description` |
| `ui_component` | Module has a dedicated FloatingTile | `**UI Component:** \`TileName\` - what it displays` |
| `alternative` | Similar module with different tradeoffs | `**Alternative:** ModuleName - how it differs` |
| `upgrade` | Newer module that replaces this one | `**Upgrade:** ModuleName - what it adds` |

### Optional relationship types

| Type | When to include |
|------|----------------|
| `source` / `target` | Producer/consumer relationship (e.g. GlobalModulatorContainer -> GlobalVoiceStartModulator) |
| `companion` | Commonly used together |
| `disambiguation` | Easily confused with another module |

### Discovery

See `module-enrichment.md` section "seeAlso" for the full relationship taxonomy with reciprocals, primary sources, source/target examples, and known scriptnode equivalent pairs.

---

## Cross-Cutting Fields

These fields live in the frontmatter YAML and are consumed by the Nuxt.js site for sidebar display, search, and LLM serving.

### cpuProfile

Hardware-independent performance model. See `module-enrichment.md` section "cpuProfile" for tier definitions.

### commonMistakes

Array of `{wrong, right, explanation}` entries. Curate from exploration findings. Explanations must reference observable behaviour ("causes clicks", "wastes CPU"), never implementation details.

### customEquivalent

How to rebuild the module using custom modules. See `module-enrichment.md` section "customEquivalent".

### llmRef

Pre-synthesised text blob for the MCP server. Written as a separate field in the frontmatter with fixed section order. See `module-enrichment.md` section "llmRef".

---

## Step 4: Author Reference Page

### Inputs

- `module_enrichment/exploration/{ModuleId}.json` - graph topology (nodes, edges, groups)
- `module_enrichment/exploration/{ModuleId}.md` - exploration findings (signal path, gap answers)
- `module_enrichment/base/moduleList.json` - parameter metadata

### Procedure

1. **Set up frontmatter.** Extract moduleId, prettyName, type, subtype, category, builderPath from moduleList.json. Set screenshot path.

2. **Write overview prose.** 1-2 paragraphs explaining what the module does. Use the exploration markdown's Signal Path section as source. Strip all C++ internals per the translation table.

3. **Write pseudo-code.** Walk the graph JSON from input to output. Transform high-importance nodes into code statements. Use the callback framing table to choose an appropriate wrapper (or none).

4. **Build glossary.** For each parameter, function, and modulation chain referenced in the pseudo-code, add a glossary entry. Resolve parameter metadata (desc, range, default) from moduleList.json. Rewrite descriptions for the user audience.

5. **Build parameter table.** Group all parameters from moduleList.json semantically. Rewrite descriptions. Format ranges and defaults per the tables above.

6. **Build modulation chains table.** List all non-disabled modulation chains with descriptions, scope, and constrainer type.

7. **Write notes.** Include any non-obvious behaviours from the exploration findings. Note vestigial parameters factually. No C++ internals.

8. **Write See Also.** Surface scriptnode equivalents, UI components, alternatives, and other relationships from the exploration.

9. **Build cross-cutting fields.** Write cpuProfile, commonMistakes, customEquivalent, llmRef into the frontmatter.

10. **Editorial review.** Re-read the entire page. Check for C++ leakage, redundancy between prose and pseudo-code, missing parameters, broken glossary references.

### Step 4 Gate Checklist

Before declaring the reference page complete:

- [ ] **Parameter accountability:** Every parameter from moduleList.json appears in the parameter table. Parameters referenced in pseudo-code have glossary entries.
- [ ] **Modulation chain coverage:** Every non-disabled modulation chain is in the modulation table. Chains referenced in pseudo-code have glossary entries.
- [ ] **Pseudo-code completeness:** The main signal path from input to output is covered. All high-importance nodes from the graph JSON are represented.
- [ ] **Glossary consistency:** Every highlighted term in the pseudo-code has a glossary entry. No glossary entry is unused. No collisions between categories.
- [ ] **No C++ leakage:** No C++ class names, method names, type names, assertions, or source references in prose, pseudo-code, or table descriptions.
- [ ] **See Also completeness:** At least 2 entries. Scriptnode equivalent included if one exists. UI component included if a FloatingTile exists.
- [ ] **Prose quality:** British English. No marketing language. No filler. Descriptions lead with what the module does, not how it is implemented.
- [ ] **Exploration incorporation:** All relevant findings from the exploration markdown are reflected in the page (prose, pseudo-code, notes, or see-also).

---

## Category-Specific Patterns

Different module categories produce characteristic reference pages. These are guides, not templates.

### Envelope Modules

- Pseudo-code uses `onNoteOn()` / `onNoteOff()` framing
- Parameters grouped by stage (Envelope, Curve Shape, Voice Mode)
- Modulation chains table is usually substantial (one chain per stage)
- See Also typically includes scriptnode equivalent and AhdsrEnvelopePanel

### Audio Effects

- Pseudo-code uses `process(left, right)` framing
- Feedback loops shown explicitly in pseudo-code
- Dry/wet mix as final operation
- Vestigial filter parameters noted if present
- TempoSync noted in parameter groups

### Sound Generators

- Pseudo-code uses `process(left, right)` framing
- Multi-oscillator modules show parallel paths merging
- Waveform type tables may be needed (e.g. WaveSynth waveform icons)
- Modulation chains for pitch and gain

### MIDI Processors

- Pseudo-code uses `onMidiEvent(message)` framing or flat flow
- No audio path, no modulation output
- Parameters are typically simple (channel numbers, transpose amounts)
- Notes section may explain event handling (ignore vs destroy)

### Time-Variant Modulators

- Flat flow or event-driven framing depending on the trigger
- Simple parameter set
- May have no modulation chains
