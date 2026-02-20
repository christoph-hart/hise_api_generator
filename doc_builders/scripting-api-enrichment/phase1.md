# Phase 1: C++ Source Analysis — Agent Instructions

Phase 1 is the core enrichment step. It reads C++ source code and produces structured documentation for each class. It runs in two stages with distinct execution models.

**Source isolation rule:** ALL information must be derived from C++ source code ONLY. Do NOT reference external documentation or the API reference itself. The only permitted external reference is the MCP `hisescript-style` resource for HiseScript syntax correctness in synthesized examples.

---

## Step A — Sub-agent (explore): Class-Level Analysis

**Execution model:** One sub-agent per class. Reads C++ source, produces two markdown files.

### Input

- The class header file (`.h`) — class declaration, inheritance chain, inner types, API method list
- The constructor in the `.cpp` file — `addConstant()` calls, `ADD_TYPED_API_METHOD_N` registrations
- Key implementation methods — for architectural understanding

### Output Files

Two files per class in `enrichment/phase1/ClassName/`:

1. **`Readme.md`** — Durable class-level artifact (human-editable, reusable as Phase 3 input)
2. **`methods_todo.md`** — Workbench: progress checklist + forced parameter type map

### Exploration Checklist

The sub-agent MUST perform ALL of the following:

1. **`brief`** — What does this class do? (~10-15 words, search-optimized)
2. **`purpose`** — Concise technical summary (2-5 sentences)
3. **`details`** — Full architecture analysis (only for classes that warrant it):
   - Internal type hierarchy (base classes, inner classes, listener/target patterns)
   - Messaging or processing modes
   - State management patterns
   - Metadata systems
   - Omit this section entirely for simple classes
4. **`obtainedVia`** — How do you get an instance? Search for factory methods, constructor registration, global variables
5. **`codeExample`** — Basic usage example synthesized from the class's API surface
6. **`alternatives`** — Related classes for similar tasks? Check sibling classes, related inheritance trees
7. **`relatedPreprocessors`** — Is the class gated by `#if` guards? (e.g., `USE_BACKEND`, `HISE_INCLUDE_LORIS`)
8. **`constants`** — Extract ALL `addConstant(name, value)` calls from the constructor. Record name, value, and infer type from the value
9. **`dynamicConstants`** — Document runtime-dependent constants (structure only, value=null)
10. **Trace class inheritance** — Identify interface compatibility patterns. For example, if the class derives from `WeakCallbackHolder::CallableObject`, it can be passed wherever a callback function is expected. Document these derived capabilities in `details`
11. **Forced parameter types** — Extract ALL `ADD_TYPED_API_METHOD_N` macro invocations from the constructor. Record the method name and the `VarTypes` per parameter. Write these into `methods_todo.md`
12. **Method checklist** — List ALL API methods (from the `// API Methods` section of the header) in `methods_todo.md` as unchecked items

### Readme.md Template

```markdown
# ClassName — Class Analysis

## Brief
~10-15 words. Search-optimized summary.

## Purpose
2-5 sentences. Concise technical summary.

## Details
Full structured technical reference. Architecture, internal patterns, modes,
inheritance-derived capabilities. Markdown with tables and headings.
(Omit this section entirely for simple classes.)

## obtainedVia
`Engine.createBroadcaster(defaultValues)` — or however the instance is obtained.

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
`USE_BACKEND`, `HISE_INCLUDE_LORIS`, etc. — or "None."
```

### methods_todo.md Template

```markdown
# ClassName — Method Workbench

## Progress
- [ ] methodA
- [ ] methodB
- [ ] methodC
- [ ] methodD
...

## Forced Parameter Types
| Method | Param 1 | Param 2 | Param 3 | Param 4 | Param 5 |
|--------|---------|---------|---------|---------|---------|
| methodA | Number | — | — | — | — |
| methodC | String | Function | — | — | — |
...

(Methods not listed here use plain ADD_API_METHOD_N — types must be inferred.)
```

---

## Step B — Main Agent: Sequential Method Analysis

After the sub-agent returns, the main agent processes methods one at a time.

### Context Loading

At the start of Step B, load:
- `enrichment/phase1/ClassName/Readme.md` — class context (CRITICAL)
- `enrichment/phase1/ClassName/methods_todo.md` — checklist + type map

### Per-Method Workflow

For each unchecked method in `methods_todo.md`:

1. **Check the forced type map.** If the method has forced types, use them as authoritative — no inference needed for those parameters.
2. **Read the method implementation** in the `.cpp` file.
3. **Produce the method entry:**
   - `signature` — full signature with VarTypes vocabulary
   - `returnType` — inferred from the implementation
   - `description` — what the method does
   - `parameters` — name, type (forced or inferred), forcedType flag, description, constraints
   - `realtimeSafe` — boolean or null, from implementation analysis
   - `pitfalls` — non-obvious behaviors (if any)
   - `examples` — synthesized code examples (apply the heuristics below)
   - `crossReferences` — related methods (if obvious; more added in post-process)
4. **Append** the method entry to `enrichment/phase1/ClassName/methods.md`
5. **Mark the method `[x]`** in `methods_todo.md`
6. **Write both files to disk immediately**

### Context Management

The per-method analysis context is **expendable**. After writing to disk, the agent does not need to retain any per-method details in its context window. Only the class-level context (`Readme.md`) and the workbench (`methods_todo.md`) are essential.

### HiseScript Syntax Reference

The agent may consult the MCP `hisescript-style` resource to ensure synthesized code examples use correct HiseScript syntax. This is the ONLY external reference permitted during method analysis. Use it for **syntax correctness only** — not for API behavior or semantics.

### VarTypes Vocabulary

Parameter and return types must use these names:

| Type Name | Meaning | Bitflag |
|-----------|---------|---------|
| `Integer` | int, int64, bool | 1 |
| `Double` | double | 2 |
| `Number` | int or double | 3 |
| `String` | string | 4 |
| `Colour` | hex string or numeric colour | 7 |
| `Array` | array | 8 |
| `IndexOrArray` | single index or array of indices | 9 |
| `Buffer` | audio buffer | 16 |
| `AudioData` | array or audio buffer | 24 |
| `ObjectWithLength` | string, array, or buffer | 28 |
| `JSON` | plain JSON/dynamic object | 32 |
| `ScriptObject` | any scripting API object | 64 |
| `Object` | JSON or scripting API object | 96 |
| `Function` | callable function/lambda | 128 |
| `ComplexType` | any non-numeric type | 252 |
| `NotUndefined` | anything except undefined | 255 |

**For return types:** Use `undefined` for methods that return nothing (void in C++).

### Type Inference Rules

For methods registered with plain `ADD_API_METHOD_N` (no forced types):

1. Look at how the `var` parameter is used in the implementation
2. `isString()` / `toString()` → `String`
3. `isArray()` / `getArray()` → `Array`
4. `getDynamicObject()` → `JSON`
5. `isInt()` / `isInt64()` / `(int)` cast → `Integer`
6. `isDouble()` / `(double)` cast → `Double`
7. Numeric operations without specific type → `Number`
8. `isBool()` → `Integer` (booleans are Integer in VarTypes)
9. Function parameters (callbacks) → `Function`
10. If multiple types are accepted (e.g., `isString()` or `isArray()`), use the appropriate composite type

### realtimeSafe Determination

Examine the C++ implementation for:
- Memory allocations (heap allocations, `String` operations, `Array::add`)
- Lock acquisitions (mutex, critical section, `ScopedLock`)
- Unbounded iteration
- I/O operations
- Any operation that could block

Set to `true` if the method is clearly safe. Set to `false` if it clearly isn't. Set to `null` if uncertain. Consumers treat `null` as "assume not safe."

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

### methods.md Output Format

Each method entry uses this format:

```markdown
## methodName

**Signature:** `returnType methodName(Type1 param1, Type2 param2)`
**Return Type:** `Integer`
**Realtime Safe:** true | false | null

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

---

## Compaction Recovery

The main agent's context window may be compacted automatically during long sessions. The pipeline is designed to survive this.

**After compaction, the agent MUST:**
1. Re-read `enrichment/phase1/ClassName/Readme.md` — the class-level context
2. Re-read `enrichment/phase1/ClassName/methods_todo.md` — to find the first unchecked method
3. Do NOT re-read `enrichment/phase1/ClassName/methods.md` — completed methods are on disk, no need to burn context

**The compaction summary should convey:** "Processing methods for ClassName. Class context is in `Readme.md`. Progress is in `methods_todo.md`. Reload both and continue from the first unchecked method."

---

## Resumability

The `methods_todo.md` file makes any session fully resumable from disk. A fresh session can:

1. Read `Readme.md` — get the full class context
2. Read `methods_todo.md` — see the checklist and type map
3. Find the first `- [ ]` entry — resume from there

No conversation history, task IDs, or special recovery instructions needed. The state is entirely on disk.

---

## Step C — Post-Process

After all methods for a class are complete:

### 1. Deduplication

Review class `details` for content that overlaps with individual method docs. Replace verbose method descriptions in `details` with cross-references to the method entries (e.g., "See `addListener()` for the full listener registration API").

### 2. Cross-Reference Injection

Add `crossReferences` between related methods:
- Deprecated methods → their replacements (e.g., `sendMessage` → `sendSyncMessage`, `sendAsyncMessage`)
- Symmetric pairs (e.g., `setBypassed` ↔ `isBypassed`)
- Related attach/add pairs (e.g., `attachToComponentValue` pairs with `addComponentValueListener`)

### 3. Markdown → JSON Transformation

Parse `Readme.md` and `methods.md` into the output JSON schema. This is done by `api_enrich.py merge` — no manual step needed. The merge command reads the markdown files and produces `enrichment/output/api_reference.json`.

### 4. Update Diff Manifest

Add `ClassName.methodName` entries to `enrichment/phase1_scanned.txt` for all processed methods.

---

## Session Prompts

### Single class (most common)

```
Follow tools/api generator/doc_builders/scripting-api-enrichment.md. Run phase0, then run phase1 for Console.
```

### Resume interrupted class

```
Follow tools/api generator/doc_builders/scripting-api-enrichment.md. Resume phase1 for Broadcaster.
```

### Post-process only

```
Follow tools/api generator/doc_builders/scripting-api-enrichment.md. Run post-process for Broadcaster.
```
