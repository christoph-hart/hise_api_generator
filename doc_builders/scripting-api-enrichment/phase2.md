# Phase 2: Project Example Overrides

Phase 2 provides real-world usage examples extracted from project analysis datasets. These are examples from actual HISE projects that demonstrate how methods are used in practice.

---

## Source Directory

```
enrichment/phase2/ClassName/methodName.md
```

One file per method override. Only methods that have project examples need files here -- this directory is sparse.

---

## File Format

Each method override file uses the same format as a single method entry in Phase 1's `methods.md`:

```markdown
## methodName

**Signature:** `returnType methodName(Type1 param1, Type2 param2)`
**Return Type:** `String`
**Call Scope:** safe | warning | unsafe | init | unknown
**Call Scope Note:** (optional -- explanation for warning tier or non-obvious classification)

**Description:**
What this method does (if overriding Phase 1's description).

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| param1 | Number | yes | What it does | 0-127 |

**Pitfalls:**
- A real-world gotcha discovered in project analysis.

**Cross References:**
- `OtherClass.relatedMethod`

**Example:**
```javascript
// Real-world usage from project analysis
// Title: Practical use of methodName
const var bc = Engine.createBroadcaster({...});
bc.methodName(...);
```
```

All fields are optional -- only include fields you want to override or add.

---

## Merge Rules

When Phase 2 data exists for a method:

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `description` | Last-writer-wins (replaces Phase 1) | -- |
| `signature` | Last-writer-wins | -- |
| `returnType` | Last-writer-wins | -- |
| `parameters` | Last-writer-wins | -- |
| `callScope` | Last-writer-wins | -- |
| `callScopeNote` | Last-writer-wins | -- |
| `examples` | **Last-writer-wins** (entire array replaced) | `"project"` |
| `pitfalls` | **Merged union** (added to Phase 1 pitfalls) | `"project"` |
| `crossReferences` | **Merged union** (deduplicated) | -- |

Phase 2 also supports a class-level `Readme.md` — see **Class-Level Project Context** below.

### Source Tags

All Phase 2 contributions are tagged with `"source": "project"` in the output JSON:

```json
{
  "examples": [
    {
      "title": "Broadcaster listener pattern",
      "code": "...",
      "context": "From a real synthesizer project",
      "source": "project"
    }
  ],
  "pitfalls": [
    {
      "description": "Must call removeListener before deleting...",
      "source": "project"
    }
  ]
}
```

---

## When to Use Phase 2

Phase 2 is populated by:

1. **Automated project analysis** -- scanning HISE project codebases for API usage patterns
2. **Curated real-world examples** -- hand-picked examples from production projects that demonstrate best practices or common patterns

Phase 2 examples have higher practical value than Phase 1's synthesized examples because they come from working code. When Phase 2 provides examples for a method, they replace Phase 1's examples entirely.

---

## Class-Level Project Context

Phase 2 can also provide a class-level `Readme.md` that adds project-derived context to the merged JSON. Unlike method overrides (which replace Phase 1 data), the class-level `Readme.md` populates a **separate `projectContext` field** — it does not override Phase 1's `brief`, `purpose`, or `details`.

### Source File

```
enrichment/phase2/ClassName/Readme.md
```

### Format

The file uses the same `## Heading` structure as Phase 1's `Readme.md` (parsed by the shared `parse_readme_md()` function) but contains a `## Project Context` section with structured sub-sections:

```markdown
# ClassName -- Project Context

## Project Context

### Real-World Use Cases
- **Use case name (ProjectName)**: What the project builds with this class,
  how it fits into the architecture, and why this class was chosen.

### Complexity Tiers
1. **Tier name** (most common): Which methods are needed. Brief description.
2. **Next tier**: Additional methods. Brief description.
3. **Advanced tier**: Full feature set. Brief description.

### Practical Defaults
- Most common configuration choice, backed by project adoption data.
- Another practical default with evidence.

### Integration Patterns
- `ClassName.method()` → `OtherClass.method()` — when this pattern is used.

## Common Mistakes
| Wrong | Right | Explanation |
|-------|-------|-------------|
| Project-discovered mistake | Correct approach | Why, grounded in evidence |
```

### Sub-Section Rules

All four sub-sections within `## Project Context` are optional.

- **Real-World Use Cases**: Every bullet must name a specific analyzed project. No generic examples.
- **Complexity Tiers**: Numbered 1-N, simplest to most complex. Names specific methods per tier.
- **Practical Defaults**: Every claim cites project evidence ("N of 13 projects use X").
- **Integration Patterns**: Method-to-method connections across classes, observed in project code.

### Merge Behavior

| Field | Target in JSON | Merge Behavior | Tag |
|-------|---------------|---------------|-----|
| `## Project Context` | `description.projectContext` | **Additive** (new field, no override chain) | `"project"` |
| `## Common Mistakes` | `commonMistakes[]` | **Merged union** (added to Phase 1 mistakes) | `"project"` |

The `projectContext` field is Phase 2-exclusive — it does not exist in Phase 1 (C++ analysis has no project awareness) and Phase 3 does not override it. It serves as input for Phase 4 when writing user-facing documentation, providing the "how it's actually used" perspective alongside Phase 1's "what it does technically."
