# Phase 3: Manual Markdown Overrides

Phase 3 is the highest-priority layer. It provides manually authored or edited documentation that overrides all prior phases. This is the final editorial pass.

---

## Source Directory

```
enrichment/phase3/ClassName/Readme.md        # Class-level overrides
enrichment/phase3/ClassName/methodName.md    # Method-specific overrides
```

The folder structure mirrors Phase 1. Using `Readme.md` for class-level overrides allows directly pulling in existing documentation from docs.hise.dev, which uses the same filename convention.

---

## Class-Level Override Format

`enrichment/phase3/ClassName/Readme.md` uses the same format as Phase 1's Readme.md:

```markdown
# ClassName -- Class Analysis

## Brief
~10-15 words. Search-optimized summary.

## Purpose
2-5 sentences. Concise technical summary.

## Details
Full structured technical reference.
(Omit to keep Phase 1's details unchanged.)

## obtainedVia
`Engine.createSomething()`

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
// Manually crafted usage example
```

## Alternatives
Related classes, or "None."

## Related Preprocessors
`USE_BACKEND`, etc. -- or "None."
```

All sections are optional -- only include sections you want to override.

---

## Method Override Format

`enrichment/phase3/ClassName/methodName.md` uses the same format as Phase 1's method entries:

```markdown
## methodName

**Signature:** `returnType methodName(Type1 param1, Type2 param2)`
**Return Type:** `String`
**Realtime Safe:** true | false | null

**Description:**
Manually written description overriding Phase 1.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| param1 | Number | yes | Corrected description | 0-127 |

**Pitfalls:**
- A manually documented gotcha.

**Cross References:**
- `OtherClass.relatedMethod`

**Example:**
```javascript
// Manually crafted example
```
```

All fields are optional -- only include fields you want to override.

---

## Merge Rules

### Class-Level Fields (Last-Writer-Wins)

Phase 3 overrides all prior phases for these fields:

| Field | Merge Behavior |
|-------|---------------|
| `description.brief` | Replaces Phase 1 value |
| `description.purpose` | Replaces Phase 1 value |
| `description.details` | Replaces Phase 1 value |
| `description.obtainedVia` | Replaces Phase 1 value |
| `description.codeExample` | Replaces Phase 1 value |
| `description.alternatives` | Replaces Phase 1 value |
| `description.relatedPreprocessors` | Replaces Phase 1 value |
| `constants.*` | Last-writer-wins per constant |
| `dynamicConstants.*` | Last-writer-wins per constant |

### Class-Level Fields (Merged Union)

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `commonMistakes` | Added to Phase 1 + Phase 2 entries | `"manual"` |

### Method-Level Fields (Last-Writer-Wins)

| Field | Merge Behavior |
|-------|---------------|
| `description` | Replaces all prior |
| `signature` | Replaces all prior |
| `returnType` | Replaces all prior |
| `parameters` | Replaces all prior |
| `realtimeSafe` | Replaces all prior |
| `examples` | **Entire array replaced** |

### Method-Level Fields (Merged Union)

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `pitfalls` | Added to Phase 1 + Phase 2 entries | `"manual"` |
| `crossReferences` | Merged, deduplicated | -- |

### Source Tags

All Phase 3 contributions are tagged with `"source": "manual"`:

```json
{
  "pitfalls": [
    { "description": "...", "source": "auto" },
    { "description": "...", "source": "project" },
    { "description": "Manually added note.", "source": "manual" }
  ]
}
```

---

## Common Workflows

### 1. Edit Phase 1 Output for Clarity

```
1. Copy enrichment/phase1/Broadcaster/Readme.md
      → enrichment/phase3/Broadcaster/Readme.md
2. Edit for clarity, fix errors, add detail
3. Run: python api_enrich.py merge
```

### 2. Import Existing docs.hise.dev Documentation

```
1. Copy the markdown source from docs.hise.dev for the class
      → enrichment/phase3/ClassName/Readme.md
2. Ensure the section headings match the template format
3. Run: python api_enrich.py merge
```

### 3. Override a Specific Method

```
1. Create enrichment/phase3/ClassName/methodName.md
2. Write only the fields you want to override
3. Run: python api_enrich.py merge
```

### 4. Add a Common Mistake

```
1. Edit enrichment/phase3/ClassName/Readme.md
2. Add a row to the ## Common Mistakes table
3. Run: python api_enrich.py merge
   (The new mistake is ADDED to existing ones, not replacing them)
```
