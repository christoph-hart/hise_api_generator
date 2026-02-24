# Scripting API Reference Enrichment Pipeline

**Purpose:** Produce a comprehensive `api_reference.json` that an MCP server uses to improve LLM-generated HiseScript code and that serves as a complete technical developer reference.

**Output Location:** `tools/api generator/enrichment/output/api_reference.json`

**Sub-phase details:** See `scripting-api-enrichment/phase0.md` through `phase4.md` for detailed per-phase instructions.

---

## Pipeline Overview

```
Phase 0: batchCreate.bat → xml/selection/*.xml → enrichment/base/*.json
       │   (batch script + Python, 100% mechanical)
       │
Phase 1: C++ source analysis + example synthesis
       │   Sub-agent  → ClassName/Readme.md (class-level artifact, durable)
       │              → ClassName/methods_todo.md (workbench: checklist + type map)
       │   Main agent → ClassName/methods.md (per-method output, fire-and-forget)
       │   Post-process → deduplicate, cross-ref, markdown → JSON
       │
Phase 2: Merge project analysis examples (mechanical merge)
       │
Phase 3: Merge manual markdown overrides (highest priority, mechanical merge)
       │
Phase 4: User-facing documentation authoring
       │   Agent-driven → phase4/auto/ClassName/*.md (LLM-generated userDocs)
       │   Human-edited → phase4/manual/ClassName/*.md (overrides auto)
       │
python api_enrich.py merge → output/api_reference.json
```

---

## Directory Structure

```
tools/api generator/
├── batchCreate.bat                           # existing, unchanged
├── xml/selection/                            # existing Doxygen XML output
├── api_enrich.py                             # CLI: phase0, prepare, merge
├── enrichment/
│   ├── base/                                 # Phase 0 output (JSON per class)
│   │   ├── Broadcaster.json
│   │   ├── Console.json
│   │   └── ...
│   ├── phase1/
│   │   ├── Broadcaster/
│   │   │   ├── Readme.md                     # Class-level artifact (durable, human-editable)
│   │   │   ├── methods_todo.md               # Workbench: progress checklist + forced type map
│   │   │   └── methods.md                    # Completed method analyses (append-only output)
│   │   ├── Console/
│   │   │   ├── Readme.md
│   │   │   ├── methods_todo.md
│   │   │   └── methods.md
│   │   └── ...
│   ├── phase1_scanned.txt                    # Diff manifest (ClassName.methodName per line)
│   ├── phase2/                               # Project example overrides
│   │   ├── Broadcaster/
│   │   │   └── addListener.md
│   │   └── ...
│   ├── phase3/                               # Manual markdown overrides
│   │   ├── Broadcaster/
│   │   │   ├── Readme.md                     # Override class-level fields
│   │   │   └── addListener.md                # Override specific method
│   │   └── ...
│   ├── phase4/                               # User-facing documentation (userDocs)
│   │   ├── auto/                             # LLM-generated userDocs
│   │   │   └── Console/
│   │   │       ├── Readme.md                 # Class-level prose
│   │   │       ├── print.md                  # Method-level prose
│   │   │       └── ...
│   │   └── manual/                           # Human-edited overrides (wins over auto)
│   │       └── Console/
│   │           └── print.md                  # Hand-tuned method doc
│   └── output/
│       └── api_reference.json                # Final merged output
```

---

## Output JSON Schema

```json
{
  "version": "1.0",
  "generated": "<ISO date>",
  "classes": {
    "<ClassName>": {
      "description": {
        "brief": "~10-15 words (required)",
        "purpose": "2-5 sentences (required)",
        "details": "Full markdown technical reference (optional, null for simple classes)",
        "obtainedVia": "Engine.createBroadcaster(defaultValues) (required)",
        "minimalObjectToken": "bc",
        "codeExample": "// basic usage (required, must create a variable named minimalObjectToken)",
        "alternatives": "Related classes (optional, null if N/A)",
        "relatedPreprocessors": ["DEFINE_NAME"],
        "userGuidePage": null,
        "userDocs": "User-facing prose (from Phase 3/4, null if not yet authored)",
        "userDocOverride": false,
        "diagram": {
          "type": "topology",
          "description": "Plain text description of the diagram for LLM consumption"
        }
      },
      "category": "namespace|object|component|scriptnode",
      "constants": {
        "<name>": {
          "value": 0,
          "type": "int|double|String",
          "description": "What it represents",
          "group": "Optional grouping label",
          "source": "auto|project|manual"
        }
      },
      "dynamicConstants": {
        "<name>": {
          "value": null,
          "type": "object|int",
          "description": "Structure desc, runtime-dependent",
          "source": "auto|project|manual"
        }
      },
      "commonMistakes": [
        {
          "wrong": "Incorrect code or approach",
          "right": "Correct code or approach",
          "explanation": "Why the wrong version fails",
          "source": "auto|project|manual"
        }
      ],
      "methods": {
        "<methodName>": {
          "signature": "returnType methodName(Type1 param1, Type2 param2)",
          "returnType": "Integer|Double|Number|String|bool|Array|JSON|ScriptObject|Object|undefined",
          "description": "What this method does",
          "parameters": [
            {
              "name": "param1",
              "type": "Number",
              "forcedType": true,
              "description": "What this parameter does",
              "constraints": "Optional constraints (e.g., range, valid values)"
            }
          ],
          "callScope": "safe",
          "callScopeNote": null,
          "minimalExample": "bc.addListener(obj, \"prop\", sync, fn);",
          "crossReferences": ["OtherClass.method"],
          "pitfalls": [
            { "description": "Something non-obvious", "source": "auto|project|manual" }
          ],
          "examples": [
            {
              "title": "Example title",
              "code": "// HiseScript example",
              "context": "When/why to use this",
              "source": "auto|project|manual"
            }
          ],
          "userDocs": "User-facing method prose (from Phase 3/4, null if not yet authored)",
          "userDocOverride": false,
          "diagram": {
            "type": "timing",
            "description": "Plain text description of what the diagram shows"
          }
        }
      }
    }
  }
}
```

---

## Class Description Sub-fields

The class `description` object provides three tiers of detail, allowing the MCP server to serve different levels depending on the request:

| # | Field | Required? | Source | MCP Serving Tier | Description |
|---|-------|-----------|--------|------------------|-------------|
| 1 | `brief` | **Required** | Phase 1 | **Index/search** -- return across many classes | ~10-15 words. Search-optimized summary. Token-efficient class listings. |
| 2 | `purpose` | **Required** | Phase 1 | **Working context** -- return for the target class | 2-5 sentences. Concise technical summary -- what the class does, its role, key capabilities. |
| 3 | `details` | Optional | Phase 1 | **Deep reference** -- return for deep dives | Full structured technical reference. Architecture, internal patterns, modes, inheritance-derived capabilities. Markdown with tables and headings. `null` for simple classes where `purpose` says everything. |
| 4 | `obtainedVia` | **Required** | Phase 1 | **Working context** | How to get an instance in HiseScript (e.g., `Engine.createBroadcaster()`, global variable, `Content.addX()`). |
| 5 | `minimalObjectToken` | **Required** | Phase 1 | **Working context** | Short variable name used in method `minimalExample` one-liners (e.g., `Button1`, `bc`). Empty string for namespace classes. The class `codeExample` MUST create a variable with this name. |
| 6 | `codeExample` | **Required** | Phase 1 (overridable Phase 3) | **Working context** | Basic usage example showing the class in action. MUST create a variable named `minimalObjectToken` (for non-namespace classes). |
| 7 | `alternatives` | Optional | Phase 1 | **Working context** | Related classes for similar tasks. `null` if N/A. |
| 8 | `relatedPreprocessors` | Optional | Phase 1 | **Deep reference** | C++ `#define` macros that gate this class's availability (e.g., `USE_BACKEND`, `HISE_INCLUDE_LORIS`). Array of strings. |
| 9 | `userGuidePage` | Deferred | -- | -- | Link to a user guide page. Not in MVP -- placeholder for later. |
| 10 | `userDocs` | Optional | Phase 3/4 | **Web display** | User-facing prose for the class overview. Flat string, scripter-friendly language. `null` if not yet authored. Priority: Phase 4 manual > Phase 3 raw docs > Phase 4 auto. |
| 11 | `userDocOverride` | Auto | Phase 3/4 | -- | `true` if `userDocs` came from `phase4/manual/` or Phase 3 raw docs, `false` if from `phase4/auto/` or absent. |
| 12 | `diagram` | Optional | Phase 1 (overridable Phase 3) | **Deep reference** + **Web display** | Diagram specification for visual rendering. Contains `type` (timing\|topology\|sequence\|state) and `description` (plain text for LLM consumption). `null` if no diagram needed. SVGs rendered in Phase 4. |

---

## Per-Method Fields

| Field | Type | Required? | Description |
|-------|------|-----------|-------------|
| `signature` | String | **Required** | Full signature with types: `returnType methodName(Type1 param1, Type2 param2)` |
| `returnType` | String | **Required** | Return type using the VarTypes vocabulary. `undefined` for methods that return nothing. |
| `description` | String | **Required** | What this method does. |
| `parameters` | Array | **Required** | Array of parameter objects (see below). |
| `callScope` | String\|null | **Required** | Where this method can be called. One of: `"safe"` (anywhere, including audio thread), `"caution"` (audio thread OK with caveats -- see `callScopeNote`), `"unsafe"` (runtime only, not audio thread), `"init"` (onInit only -- runtime call throws script error), `null` (unknown -- treat as unsafe). |
| `callScopeNote` | String\|null | Optional | Explanation for `"caution"` tier or other non-obvious classification. Most important for `"caution"` methods where it provides concrete guidance. `null` when the classification is self-evident. |
| `minimalExample` | String | **Required** | One-liner method call with realistic arguments (e.g., `Button1.setValue(0.5);`). Written with `{obj}` placeholder in source; merge script substitutes the class's `minimalObjectToken`. |
| `crossReferences` | Array of Strings | Optional | Related methods in the format `ClassName.methodName`. |
| `pitfalls` | Array | Optional | Non-obvious behaviors or gotchas. Each entry: `{ description, source }`. |
| `examples` | Array | Optional | Code examples. Each entry: `{ title, code, context, source }`. |
| `userDocs` | String\|null | Optional | User-facing method prose from Phase 3/4. `null` if not yet authored. Priority: Phase 4 manual > Phase 3 raw docs > Phase 4 auto. |
| `userDocOverride` | boolean | Auto | `true` if `userDocs` came from `phase4/manual/` or Phase 3 raw docs, `false` otherwise. |
| `diagram` | Object\|null | Optional | Diagram specification: `{ type, description }`. `type` is one of `timing`, `topology`, `sequence`, `state`. `description` is plain text for LLM consumption. SVGs rendered in Phase 4. `null` if no diagram needed. |

### Parameter Object

| Field | Type | Required? | Description |
|-------|------|-----------|-------------|
| `name` | String | **Required** | Parameter name. |
| `type` | String | **Required** | Parameter type using VarTypes vocabulary. |
| `forcedType` | boolean | **Required** | `true` if extracted from `ADD_TYPED_API_METHOD_N` (authoritative). `false` if inferred by the agent. |
| `description` | String | **Required** | What this parameter does. |
| `constraints` | String | Optional | Valid ranges, accepted values, format requirements. |

### callScope Determination

The `callScope` field classifies where a method can be called, from most restricted to most free:

**`"init"`** -- Can only be called during `onInit`. The runtime enforces this -- calling at runtime throws a script error via `interfaceCreationAllowed()` or equivalent guard. Thread safety is irrelevant. Examples: `setTableMode()`, `setTableColumns()`, `setTableCallback()`.

**`"unsafe"`** -- Can be called at runtime but NOT from the audio thread. The method allocates on the heap, acquires locks, mutates ValueTree properties with change notifications, blocks, or does I/O. Call from timer callbacks, UI handlers, or other non-audio contexts. Examples: `sendData()`, component property setters via `set()`, `setLocalLookAndFeel()`.

**`"caution"`** -- Can be called from the audio thread, but with caveats described in `callScopeNote`. Sub-categories:
- **Performance-sensitive:** Lock-free but iterates over user-sized data. Fine for small collections; may need caching in tight loops. Example: `Array.indexOf()`.
- **Backend-only allocation:** Allocates in HISE IDE builds (`USE_BACKEND=1`) but compiled out or becomes a no-op in exported plugins. Fine for debugging on the audio thread since the allocation won't exist in production. Example: `Console.print()`.
- **Context-dependent:** Safe in some modes but not others. Example: `ScriptedViewport.setValue()` is safe in list mode but allocates in table MultiColumnMode.

**`"safe"`** -- No allocations, no locks, no unbounded work, no context restrictions. Call anywhere: `onInit`, runtime callbacks, audio thread, MIDI callbacks. Examples: `Math.max()`, simple cached getters, `GlobalCable.getValue()`.

**`null` (unknown)** -- Cannot be determined from the source code. Consumers should treat as `"unsafe"`.

#### Classification Rules

1. **Init-only enforcement:** If the C++ implementation checks `interfaceCreationAllowed()` or equivalent and throws a script error at runtime, classify as `"init"` regardless of what the method does internally.

2. **ValueTree property mutation:** Methods that call ValueTree set/change with notifications are `"unsafe"` -- even without explicit heap allocation, the notification chain involves string lookups, var comparisons, and potential undo-manager operations.

3. **Dispatch pattern:** When a method's own code path is lock-free and allocation-free but it dispatches/broadcasts to external targets, listeners, or callbacks, classify based on the method's own behavior. Target/listener behavior is the target's responsibility.

4. **USE_BACKEND exception:** Methods that allocate only in backend builds (`USE_BACKEND=1`) but are compiled out in exported plugins are `"caution"`, not `"unsafe"`. The allocation won't exist in production code.

5. **Subclass override:** If a subclass overrides a base method with different callScope characteristics, the subclass Phase 1 specifies the overridden value. The merge picks up the subclass value (last-writer-wins).

### Example Synthesis Heuristics

**NEEDS example:**
- Callback/function parameter
- JSON/object parameter with a schema the caller must know
- Non-obvious return structure (e.g., returns an object with specific properties)
- Multi-step workflow (method must be called in a specific sequence)
- Ambiguous method name that doesn't clearly convey usage

**SKIP example:**
- Simple getter returning a primitive value
- Simple setter with an obvious parameter
- Boolean query (e.g., `isBypassed()`)
- Self-explanatory signature where the description suffices

---

## Type System

### VarTypes Reference

Parameter and return types use HISE's `VarTypeChecker::VarTypes` names directly. This is a bitflag-based type system where composite types are bitwise ORs of their constituents.

| Type Name | Meaning | Bitflag | Composition |
|-----------|---------|---------|-------------|
| `Integer` | int, int64, bool | 1 | -- |
| `Double` | double | 2 | -- |
| `Number` | int or double | 3 | Integer \| Double |
| `String` | string | 4 | -- |
| `Colour` | hex string or numeric colour | 7 | String \| Number |
| `Array` | array | 8 | -- |
| `IndexOrArray` | single index or array of indices | 9 | Array \| Integer |
| `Buffer` | audio buffer | 16 | -- |
| `AudioData` | array or audio buffer | 24 | Array \| Buffer |
| `ObjectWithLength` | string, array, or buffer | 28 | String \| Array \| Buffer |
| `JSON` | plain JSON/dynamic object | 32 | -- |
| `ScriptObject` | any scripting API object | 64 | -- |
| `Object` | JSON or scripting API object | 96 | JSON \| ScriptObject |
| `Function` | callable function/lambda | 128 | -- |
| `ComplexType` | any non-numeric type | 252 | String \| Array \| Buffer \| JSON \| ScriptObject \| Function |
| `NotUndefined` | anything except undefined | 255 | ComplexType \| Number |

### Type Sources

**Authoritative (forcedType: true):** Methods registered with `ADD_TYPED_API_METHOD_N` macros in the C++ constructor/registration code. The macro arguments specify exact `VarTypes` per parameter. Extracted during Phase 1 class-level analysis from the same constructor code that contains `addConstant()` calls.

**Inferred (forcedType: false):** Methods registered with plain `ADD_API_METHOD_N` macros. The Phase 1 agent infers parameter types from the C++ implementation (how the `var` parameter is used -- `isString()`, `isArray()`, `getDynamicObject()`, etc.). Uses the same VarTypes vocabulary.

**Return types:** Always inferred from the implementation. Not covered by the typed macro system.

### Source C++ Reference

The type enforcement system lives in:
- **Macro definitions:** `hi_scripting/scripting/api/ScriptMacroDefinitions.h`
- **Type enum:** `hi_scripting/scripting/engine/JavascriptApiClass.h` (`VarTypeChecker::VarTypes`)
- **Runtime checking:** `hi_scripting/scripting/engine/JavascriptApiClass.cpp` (`VarTypeChecker::getType()`, `checkType()`)

Type enforcement is active in the HISE IDE (`USE_BACKEND`) and stripped from exported plugins. The `forcedType` flag in the API reference indicates which parameters have authoritative type information.

---

## Merge Rules

When multiple phases provide data for the same field, these rules determine the final value:

### Last-Writer-Wins Fields (Phase 3 > Phase 2 > Phase 1 > Phase 0)

- `description.brief`
- `description.purpose`
- `description.details`
- `description.obtainedVia`
- `description.codeExample`
- `description.alternatives`
- `description.relatedPreprocessors`
- `description.minimalObjectToken`
- `description.diagram` (entire object replaced)
- `methods.*.description`
- `methods.*.minimalExample`
- `methods.*.diagram` (entire object replaced)
- `methods.*.examples` (entire array replaced)
- `constants.*` (per constant, entire entry replaced)
- `dynamicConstants.*` (per constant, entire entry replaced)

### Merged Union Fields (all sources combined, tagged)

- `commonMistakes` -- entries from all phases, each tagged with `source`
- `methods.*.pitfalls` -- entries from all phases, each tagged with `source`
- `methods.*.crossReferences` -- all references combined, deduplicated

### Source Tagging

All enrichment data is tagged with its origin:
- `"auto"` -- Phase 1 (AI-synthesized from C++ source analysis)
- `"project"` -- Phase 2 (extracted from project analysis datasets)
- `"manual"` -- Phase 3 (manually authored overrides)

---

## Feedback Loop Prevention

**CRITICAL:** The API reference and MCP style guides are complementary, non-overlapping resources. They must not feed into each other.

- **Phase 1 class analysis (sub-agent):** Derive everything from C++ source code ONLY. Do NOT reference MCP resources, existing documentation websites, or the API reference itself.
- **Phase 1 method analysis (main agent):** May reference the MCP `hisescript-style` resource for HiseScript **syntax correctness only** (e.g., correct `inline function` syntax, proper `var` vs `const var` usage). Do NOT use it to derive API behavior or semantics.
- **MCP style guides** (`hisescript-style`, `graphics-api-style`, `scriptpanel-style`): These provide coding patterns and best practices. They reference the API but do not define it.
- **api_reference.json**: Defines what the API does. It is the authoritative source for method signatures, parameter types, and behavioral documentation.

---

## Phase 0: Doxygen XML → Base JSON

### Steps

1. Run `batchCreate.bat > NUL 2>&1` -- Runs Doxygen, copies/renames XML into `xml/selection/`, runs ApiExtractor + BinaryBuilder
2. Run `python api_enrich.py phase0` -- Parses the XML into base JSON

### Output

`enrichment/base/ClassName.json` -- one file per class

### What Phase 0 Extracts (Mechanically)

- Method names and signatures
- Return types (C++ types, to be mapped in Phase 1)
- Parameter names and C++ types
- Doxygen `@brief` descriptions (the one-line `/** */` comments from the header)
- Class category (derived from the `batchCreate.bat` rename mappings)

### What Phase 0 Does NOT Extract

- Constants -- requires reading constructor code (Phase 1)
- Forced parameter types -- requires reading `ADD_TYPED_API_METHOD_N` macros (Phase 1)
- `callScope` -- requires analyzing method implementations (Phase 1)
- Examples -- requires synthesis (Phase 1)
- `details` -- requires deep C++ source analysis (Phase 1)

### Category Mapping

Derived from `batchCreate.bat`. Each class is categorized as one of:

| Category | Description |
|----------|-------------|
| `namespace` | Global API namespaces (e.g., `Engine`, `Synth`, `Console`, `Math`) |
| `object` | Object types returned by API calls (e.g., `AudioFile`, `Broadcaster`, `MidiList`) |
| `component` | UI components created via `Content.addX()` (e.g., `ScriptButton`, `ScriptSlider`) |
| `scriptnode` | ScriptNode DSP classes |

The exact class-to-category mapping table is maintained in `scripting-api-enrichment/phase0.md`.

---

## Phase 1: C++ Source Analysis

Phase 1 is the core enrichment step. It reads C++ source code and produces structured documentation. It runs in two stages with distinct execution models.

Detailed agent instructions: `scripting-api-enrichment/phase1.md`

### Step A -- Sub-agent (explore): Class-Level Analysis

**Spawned by:** The main agent, one sub-agent per class.

**Reads:**
- The class header file (`.h`) -- class declaration, inheritance chain, inner types, API method list
- The constructor in the `.cpp` file -- `addConstant()` calls, `ADD_TYPED_API_METHOD_N` registrations
- Key implementation methods -- for architectural understanding

**Produces two files:**

#### `enrichment/phase1/ClassName/Readme.md`

The durable class-level artifact. Human-editable, reusable as Phase 3 input. Contains:

```markdown
# ClassName -- Class Analysis

## Brief
~10-15 words. Search-optimized summary.

## Purpose
2-5 sentences. Concise technical summary.

## Details
Full structured technical reference. Architecture, internal patterns, modes,
inheritance-derived capabilities. Markdown with tables and headings.
(Omit this section entirely for simple classes.)

## obtainedVia
`Engine.createBroadcaster(defaultValues)` -- or however the instance is obtained.

## Constants
| Name | Value | Type | Description | Group |
|------|-------|------|-------------|-------|
| ... | ... | ... | ... | ... |

## Dynamic Constants
| Name | Type | Description |
|------|------|-------------|
| ... | ... | ... |

## Common Mistakes
| Wrong | Right | Explanation |
|-------|-------|-------------|
| ... | ... | ... |

## codeExample
```javascript
// Basic usage example
```

## Alternatives
Related classes for similar tasks, or "None."

## Related Preprocessors
`USE_BACKEND`, `HISE_INCLUDE_LORIS`, etc. -- or "None."
```

#### `enrichment/phase1/ClassName/methods_todo.md`

The workbench file. Contains the progress checklist and forced parameter type map:

```markdown
# ClassName -- Method Workbench

## Progress
- [ ] methodA
- [ ] methodB
- [ ] methodC
- [ ] methodD
...

## Forced Parameter Types
| Method | Param 1 | Param 2 | Param 3 | Param 4 | Param 5 |
|--------|---------|---------|---------|---------|---------|
| methodA | Number | -- | -- | -- | -- |
| methodC | String | Function | -- | -- | -- |
...

(Methods not listed here use plain ADD_API_METHOD_N -- types must be inferred.)
```

### Sub-agent Exploration Checklist

The sub-agent must perform all of the following during class-level analysis:

1. **`brief`** -- What does this class do? (~10-15 words)
2. **`purpose`** -- Concise technical summary (2-5 sentences)
3. **`details`** -- Full architecture analysis (only for classes that warrant it):
   - Internal type hierarchy (e.g., base classes, inner classes, listener/target patterns)
   - Messaging or processing modes
   - State management patterns
   - Metadata systems
4. **`obtainedVia`** -- How do you get an instance? Search for factory methods, constructor registration, global variables.
5. **`codeExample`** -- Basic usage example synthesized from the class's API surface.
6. **`alternatives`** -- Related classes for similar tasks? Check sibling classes, related inheritance trees.
7. **`relatedPreprocessors`** -- Is the class gated by `#if` guards? (e.g., `USE_BACKEND`, `HISE_INCLUDE_LORIS`)
8. **`constants`** -- Extract all `addConstant(name, value)` calls from the constructor. Record name, value, and infer type from the value.
9. **`dynamicConstants`** -- Document runtime-dependent constants (structure only, value=null).
10. **Trace class inheritance** -- Identify interface compatibility patterns. For example, if the class derives from `WeakCallbackHolder::CallableObject`, it can be passed wherever a callback function is expected. Document these derived capabilities in `details`.
11. **Forced parameter types** -- Extract all `ADD_TYPED_API_METHOD_N` macro invocations from the constructor. Record the method name and the `VarTypes` per parameter. Write these into `methods_todo.md`.
12. **Method checklist** -- List all API methods (from the `// API Methods` section of the header) in `methods_todo.md` as unchecked items.

**Source isolation rule:** The sub-agent must derive ALL information from C++ source code only. Do NOT reference external documentation, MCP resources, or existing API reference files.

### Step B -- Main Agent: Sequential Method Analysis

After the sub-agent returns, the main agent processes methods one at a time.

**Loads at the start of Step B:**
- `enrichment/phase1/ClassName/Readme.md` -- class context (CRITICAL)
- `enrichment/phase1/ClassName/methods_todo.md` -- checklist + type map

**For each unchecked method:**

1. Check the forced type map in `methods_todo.md`. If the method has forced types, use them as authoritative -- no inference needed for those parameters.
2. Read the method implementation in the `.cpp` file.
3. Produce the method entry:
   - `signature` -- full signature with VarTypes
   - `returnType` -- inferred from the implementation
   - `description` -- what the method does
   - `parameters` -- name, type (forced or inferred), forcedType flag, description, constraints
   - `callScope` -- string tier or null, from implementation analysis
   - `callScopeNote` -- explanation string for non-obvious classifications (especially `"caution"`)
   - `pitfalls` -- non-obvious behaviors (if any)
   - `examples` -- synthesized code examples (apply the heuristics above)
   - `crossReferences` -- related methods (if obvious at this point; more added in post-process)
4. Append the method entry to `enrichment/phase1/ClassName/methods.md`
5. Mark the method `[x]` in `methods_todo.md`
6. Write both files to disk immediately

**The method analysis context is expendable.** After writing to disk, the agent does not need to retain any per-method details in its context window. Only the class-level context (`Readme.md`) and the workbench (`methods_todo.md`) are essential.

**HiseScript syntax reference:** The agent may consult the MCP `hisescript-style` resource to ensure synthesized code examples use correct HiseScript syntax. This is the ONLY external reference permitted during method analysis, and it must be used for syntax correctness only -- not for API behavior.

### Method Output Format (methods.md)

Each method entry in `methods.md` uses this markdown format:

```markdown
## methodName

**Signature:** `returnType methodName(Type1 param1, Type2 param2)`
**Return Type:** `Integer`
**Call Scope:** safe | caution | unsafe | init | unknown
**Call Scope Note:** (optional -- explanation for caution tier or non-obvious classification)

**Description:**
What this method does.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| param1 | Number | yes | What it does | 0-127 |
| param2 | Function | no | Callback | Must have 2 args |

**Pitfalls:**
- Something non-obvious about this method.

**Cross References:**
- `ClassName.relatedMethod`

**Example:**
```javascript
// Example title
// Example code here
```
```

### Compaction Recovery

The main agent's context window may be compacted automatically during long sessions. The pipeline is designed to survive this:

**After compaction, the agent MUST:**
1. Re-read `enrichment/phase1/ClassName/Readme.md` -- the class-level context
2. Re-read `enrichment/phase1/ClassName/methods_todo.md` -- to find the first unchecked method
3. Do NOT re-read `enrichment/phase1/ClassName/methods.md` -- completed methods are on disk, no need to burn context

**The compaction summary should convey:** "Processing methods for ClassName. Class context is in `Readme.md`. Progress is in `methods_todo.md`. Reload both and continue from the first unchecked method."

### Resumability

The `methods_todo.md` file makes any session fully resumable from disk. A fresh session can:

1. Read `Readme.md` -- get the full class context
2. Read `methods_todo.md` -- see the checklist and type map
3. Find the first `- [ ]` entry -- resume from there

No conversation history, task IDs, or special recovery instructions needed. The state is entirely on disk.

### Step C -- Post-Process

After all methods for a class are complete, run the post-process step:

1. **Deduplication:** Review class `details` for content that overlaps with individual method docs. Replace verbose method descriptions in `details` with cross-references to the method entries (e.g., "See `addListener()` for the full listener registration API").

2. **Cross-reference injection:** Add `crossReferences` between related methods:
   - Deprecated methods → their replacements (e.g., `sendMessage` → `sendSyncMessage`, `sendAsyncMessage`)
   - Symmetric pairs (e.g., `setBypassed` ↔ `isBypassed`)
   - Related attach/add pairs (e.g., `attachToComponentValue` pairs with `addComponentValueListener`)

3. **Markdown → JSON transformation:** Parse `Readme.md` and `methods.md` into the output JSON schema. Produce `enrichment/phase1/ClassName.json`.

4. **Update diff manifest:** Add `ClassName.methodName` entries to `enrichment/phase1_scanned.txt` for all processed methods.

---

## Phase 2: Project Example Merge

### Source

`enrichment/phase2/ClassName/methodName.md` -- one file per method override.

### Content

Real-world usage examples extracted from project analysis datasets. These are examples from actual HISE projects that demonstrate how methods are used in practice.

### Merge Rules

- `examples`: last-writer-wins (Phase 2 replaces Phase 1 examples entirely)
- `pitfalls`: merged union, each entry tagged `"source": "project"`
- `commonMistakes`: merged union, each entry tagged `"source": "project"`
- `crossReferences`: merged union, deduplicated

Detailed format spec: `scripting-api-enrichment/phase2.md`

---

## Phase 3: Manual Markdown Overrides

### Source

- `enrichment/phase3/ClassName/Readme.md` -- overrides class-level fields
- `enrichment/phase3/ClassName/methodName.md` -- overrides a specific method

The folder structure mirrors Phase 1. Using `Readme.md` for class-level overrides allows directly pulling in existing documentation from docs.hise.dev, which uses the same filename convention in its markdown source.

### Content

Manually authored or edited markdown. Supports two formats:

1. **Structured format** (same as Phase 1): uses `**Signature:**`, `**Description:**`, etc. Overrides specific fields.
2. **Raw docs format** (from existing docs.hise.dev): loose prose + code blocks. Automatically split into `userDocs` (prose) and `examples` (code blocks). Doc-site links converted to cross-references. Images stripped.

Common workflows:

- Copy `phase1/ClassName/Readme.md`, edit for clarity, place in `phase3/ClassName/Readme.md`
- Pull existing docs.hise.dev markdown for a class, place as `phase3/ClassName/Readme.md`
- Pull existing docs.hise.dev method page, drop as `phase3/ClassName/methodName.md` -- prose becomes `userDocs`, code blocks become `examples`
- Write a targeted method override for a specific method

### Merge Rules

- `description` sub-fields (`brief`, `purpose`, `details`, `obtainedVia`, `codeExample`, `diagram`): last-writer-wins (Phase 3 overrides all prior phases)
- `examples`: last-writer-wins (Phase 3 replaces entirely)
- `userDocs`: Phase 3 raw docs format extracts `userDocs` from prose. Priority: Phase 4 manual > Phase 3 > Phase 4 auto.
- `pitfalls`: merged union, each entry tagged `"source": "manual"`
- `commonMistakes`: merged union, each entry tagged `"source": "manual"`
- `crossReferences`: merged union, deduplicated (raw docs link conversion adds entries)
- `constants` / `dynamicConstants`: last-writer-wins per constant
- `diagram`: last-writer-wins (entire object replaced)

Detailed format spec: `scripting-api-enrichment/phase3.md`

---

## Phase 4: User-Facing Documentation Authoring

Phase 4 transforms the raw C++ analysis (Phases 1-3) into scripter-friendly documentation. It runs after merge, one class at a time, because the authoring agent benefits from seeing the complete merged API surface before writing user-facing prose. Phase 4 also renders SVG diagrams for methods/classes that have a `diagram` specification.

Detailed authoring guidelines: `scripting-api-enrichment/phase4.md`

### Source

Two-tier directory structure with manual overrides winning:

```
enrichment/phase4/auto/ClassName/     # LLM-generated userDocs + auto SVGs
enrichment/phase4/manual/ClassName/   # Human-edited overrides (wins over auto)
```

### File Format

- **Class-level:** `Readme.md` -- starts with `# ClassName` heading, followed by prose paragraphs.
- **Method-level:** `methodName.md` -- bare prose, no heading. File stem must match the method name (case-insensitive matching is applied during merge).
- **Diagrams:** `methodName.svg` or `Readme.svg` -- SVG diagram rendered from the `diagram` field. Manual SVGs in `phase4/manual/` override auto-generated ones.

### JSON Fields

| Field | Level | Type | Description |
|-------|-------|------|-------------|
| `userDocs` | Class + Method | String\|null | Flat prose string for end-user display. `null` if not yet authored. |
| `userDocOverride` | Class + Method | boolean | `true` if sourced from `phase4/manual/` or Phase 3 raw docs, `false` if from `phase4/auto/` or absent. |

### Merge Rules

- For `userDocs`: Phase 4 manual > Phase 3 raw docs > Phase 4 auto
- `phase4/manual/` wins over `phase4/auto/` (per file, case-insensitive filename matching)
- Phase 4 does NOT override any Phase 1-3 fields -- it adds `userDocs` / `userDocOverride` and renders SVG diagrams

### Preview Output

`python api_enrich.py preview ClassName` generates:

- `ClassName_review.html` -- always generated; shows raw C++ analysis (purpose, details, description) for factual review
- `ClassName.html` -- generated only when userDocs exist; shows the user-facing documentation with auto/manual source badges

### Progress Tracking

`python api_enrich.py prepare` reports Phase 4 status by comparing files in `phase4/auto/` and `phase4/manual/` against the class's method list. No separate tracking file is needed.

---

## Diff Mechanism

`enrichment/phase1_scanned.txt` tracks which methods have been processed by Phase 1.

**Format:** One `ClassName.methodName` entry per line.

**Usage:**
- `python api_enrich.py prepare` reads the base JSON and the scanned file, prints the worklist of unprocessed methods grouped by class.
- Delete a line to force rescan of that specific method.
- Delete all lines for a class to force full rescan of that class.
- The file is updated automatically during the Phase 1 post-process step.

---

## CLI Tool: api_enrich.py

### Subcommands

#### `phase0`

```
batchCreate.bat > NUL 2>&1
python api_enrich.py phase0
```

Regenerates Doxygen XML via `batchCreate.bat`, then parses all XML files in `xml/selection/` and produces base JSON files in `enrichment/base/`. Fully mechanical, no AI involvement. The batch script output is redirected to NUL to keep the agent context clean.

#### `prepare`

```
python api_enrich.py prepare
```

Reads `enrichment/base/*.json` and `enrichment/phase1_scanned.txt`. Prints the worklist of classes and methods that still need Phase 1 processing. Also reports Phase 4 (userDocs) status for all enriched classes.

#### `merge`

```
python api_enrich.py merge
```

Reads all phases (base → phase1 → phase2 → phase3 → phase4) and produces `enrichment/output/api_reference.json`. Applies merge rules as specified above.

#### `preview`

```
python api_enrich.py preview [ClassName]
```

Generates HTML preview pages from `api_reference.json`. If a class name is given, generates only that class; otherwise generates pages for all enriched classes.

For each class, produces:
- `ClassName_review.html` -- raw C++ analysis (always generated for enriched classes)
- `ClassName.html` -- user-facing userDocs view (generated only if any Phase 4 userDocs exist for the class)

Output: `enrichment/output/preview/`

