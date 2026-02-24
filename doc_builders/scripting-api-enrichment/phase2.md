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
**Call Scope:** safe | caution | unsafe | init | unknown
**Call Scope Note:** (optional -- explanation for caution tier or non-obvious classification)

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

Phase 2 also supports class-level overrides via `enrichment/phase2/ClassName/Readme.md`, which would override class-level fields using the same merge rules as Phase 3 (see `scripting-api-enrichment/phase3.md`). In practice, Phase 2 is primarily used for method-level example overrides.

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
