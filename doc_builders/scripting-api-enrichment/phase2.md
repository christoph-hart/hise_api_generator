# Phase 2: Project Example Extraction

Phase 2 provides real-world usage examples and project context extracted from actual HISE projects. It has two stages:

1. **External extraction** (private repo) - an extraction agent reads Phase 1 output, searches real project codebases, anonymizes examples, and writes raw output to `enrichment/phase2/ClassName/`.
2. **Test metadata enrichment** (this pipeline) - the pipeline agent adds slugs, test metadata, setup scripts, and test-only markers to the extracted examples, then validates them.

The extraction pipeline and project source code are maintained outside this repo for proprietary reasons. **Do not fabricate Phase 2 content.** Hallucinated "project context" passes as grounded evidence when it isn't - the `"source": "project"` tag in the JSON means "extracted from a real codebase," not "plausible-sounding."

---

## Pipeline Gate

After Phase 1 completes, check whether `enrichment/phase2/ClassName/` exists for **every class** in the current batch.

- **All directories exist** -> proceed to test metadata enrichment (below), then Phase 3 and Phase 4a.
- **Any directory missing** -> **STOP.** Report which classes need Phase 2 extraction and wait. Do not proceed with any class in the batch until all directories exist.

Directory existence is the signal. If the directory exists (even empty), extraction is complete for that class. The user will launch the extraction agent separately and tell you when to resume.

---

## Test File Authoring

Once Phase 2 files exist, the pipeline agent converts testable examples to `.hsc` test files. This is a **combined pass covering both Phase 1 and Phase 2 examples** for the target class — not just Phase 2 files. Phase 1 examples in `phase1/ClassName/methods.md` and Phase 2 examples in `phase2/ClassName/*.md` are all candidates.

Follow `style-guide/scripting-api/hsc-test-format.md` for the full file format, region sentinels, assertion verbs, and worked examples.

### Per-method workflow

For each method file in `enrichment/phase2/ClassName/`:

1. **Skip class-level Readme.md** — Project Context and Common Mistakes are not example-bearing.

2. **Analyze each example for testability.** Ask: can this run standalone against a HISE playground without external resources?
   - **Testable:** Self-contained, deterministic, no external files/MIDI/hardware.
   - **Not testable:** Requires audio files, DAW interaction, MIDI controllers, or project-specific resources. Leave it as a ```` ```javascript:slug ```` block in the .md source.

3. **For testable examples**, create `enrichment/tests/{Class}/{method}/{slug}.hsc`:
   - Slug = kebab-case, unique within method (e.g. `track-velocity-per-note`).
   - Header block with health check + `playground open` + `/builder reset` (boilerplate, identical for every test).
   - Setup region: `/builder add` and/or `/ui add` lines for required modules and components, OR inline HiseScript when the setup pattern can't be expressed in mode commands (e.g. loops with computed names).
   - Example region: the canonical HiseScript code, verbatim from the .md source — visible on the website.
   - Test region: any test-only invocation (callback trigger, test-side mutation), followed by `/compile` and `/expect` / `/expect-logs` / `/expect-compile throws` assertions.
   - For UI control callbacks, use `/ui set Name.value <v>` in the test region to fire the callback via the REST API path (script-side `setValue` doesn't trigger callbacks during onInit).
   - For async behavior, insert `/wait <ms>ms` before the relevant assertion.

4. **Run the test:**
    ```bash
    hise-cli --run ./enrichment/tests/{Class}/{method}/{slug}.hsc --verbose
    ```
    Iterate until all assertions pass.

5. **Run the full test suite** before committing:
    ```bash
    python run_all_tests.py
    ```

### What NOT to change

- Do not rewrite the example code beyond what's needed for testability. The examples were extracted from real projects — preserve their patterns, variable names, and structure.
- Do not add examples. Phase 2 content comes from the extraction agent only.
- Do not modify the class-level Readme.md (Project Context, Common Mistakes).
- Do not duplicate testable examples — when a `.hsc` file exists, the corresponding `javascript:slug` block has already been stripped from the .md source. The `.hsc` is the single source of truth.

---

## Source Directory

```
enrichment/phase2/ClassName/Readme.md        # Class-level project context
enrichment/phase2/ClassName/methodName.md    # Method examples + pitfalls
```

One file per method. Only methods that have project examples need files here - this directory is sparse.

---

## Method File Format

Method files contain examples (non-testable only — testable ones live in `enrichment/tests/`), optional pitfalls, and optional cross-references. They do NOT contain structured override fields (signature, parameters, description, callScope).

```markdown
## methodName

**Examples:**

```javascript:slug-name
// Title: What this example demonstrates
// Context: When/why you'd use this pattern
//
// Non-testable: requires <reason — audio file / hardware / DAW>
const var obj = Engine.createSomething();
obj.methodName(args);
```

**Pitfalls:**
- A real-world gotcha discovered in project analysis.

**Cross References:**
- `$API.OtherClass.relatedMethod$`
```

All sections are optional except `**Examples:**` (when non-testable examples exist). Testable examples live in `enrichment/tests/{Class}/{method}/*.hsc` — they are auto-discovered by `api_enrich.py merge` and rendered as ```` ```hsc ```` fenced blocks alongside the .md `javascript:slug` blocks.

---

## Class-Level Readme Format

`enrichment/phase2/ClassName/Readme.md` provides project-derived context. It populates a separate `projectContext` field in the JSON - it does not override Phase 1's `brief`, `purpose`, or `details`.

```markdown
# ClassName -- Project Context

## Project Context

### Real-World Use Cases
- **Use case name**: What kind of plugin builds with this class,
  how it fits into the architecture, and why this class was chosen.

### Complexity Tiers
1. **Tier name** (most common): Which methods are needed. Brief description.
2. **Next tier**: Additional methods. Brief description.

### Practical Defaults
- Most common configuration choice, backed by project adoption data.

### Integration Patterns
- `ClassName.method()` -> `OtherClass.method()` - when this pattern is used.

## Common Mistakes
| Wrong | Right | Explanation |
|-------|-------|-------------|
| Project-discovered mistake | Correct approach | Why |
```

All four sub-sections within `## Project Context` are optional.

- **Real-World Use Cases**: Describe use case archetypes without identifying specific projects.
- **Complexity Tiers**: Numbered 1-N, simplest to most complex. Names specific methods per tier.
- **Practical Defaults**: State as direct expert recommendations.
- **Integration Patterns**: Method-to-method connections across classes, observed in project code.

---

## Merge Rules

Phase 2 contributes examples, pitfalls, cross-references, project context, and common mistakes. It does not override structural method fields (signature, parameters, description, callScope).

### Method-level

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `examples` | **Last-writer-wins** (replaces Phase 1 array) | `"project"` |
| `pitfalls` | **Merged union** (added to Phase 1 pitfalls) | `"project"` |
| `crossReferences` | **Merged union** (deduplicated) | -- |

### Class-level

| Field | Target in JSON | Merge Behavior | Tag |
|-------|---------------|---------------|-----|
| `## Project Context` | `description.projectContext` | **Additive** (Phase 2-exclusive field) | `"project"` |
| `## Common Mistakes` | `commonMistakes[]` | **Merged union** (added to Phase 1 mistakes) | `"project"` |

The `projectContext` field is Phase 2-exclusive. It does not exist in Phase 1 and is not overridden by later phases. It serves as input for Phase 4a when writing user-facing documentation.

---

## Test Format Reference

See `style-guide/scripting-api/hsc-test-format.md` for:
- When to test (testable vs non-testable distinction, callback testability table)
- `.hsc` file structure (region sentinels, header boilerplate)
- Setup translation (`/ui add`, `/builder add`, fallback to inline HiseScript)
- Assertion verbs (`/expect ... is`, `contains`, `logs`, `throws`, `/expect-compile`, `/expect-logs`)
- Trigger patterns (`/ui set`, `Console.testCallback`, transport handler)
- Verification strategy (integration tests, configuration chains, async + audio caveats)
