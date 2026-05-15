# HSC Examples Phase 5 - Screenshot Pass

**Purpose:** Generate website screenshots outside the public `.hsc` scripts and record the asset-generation result.

**Batch mode:** Horizontal or small batches. This phase is mostly mechanical, but failed or visually poor screenshots may need to loop back to Phase 3 cosmetics.

**Input:**
- `scriptnode_enrichment/hsc/phase4/{factory}/{node}.hsc`
- `scriptnode_enrichment/hsc/phase3/{factory}/{node}.md`
- Live HISE reachable via `hise-cli`

**Output:**
- `scriptnode_enrichment/hsc/phase5/{factory}/{node}.png`

**User gate:** The user approves screenshots or requests cosmetic changes.

---

## Screenshot Rules

1. Do not add screenshot commands to public `.hsc` files.
2. Run the public `.hsc` in a controlled environment before taking the screenshot, unless the network is already known to be loaded.
3. Export screenshots to `scriptnode_enrichment/hsc/phase5/{factory}/{node}.png`.
4. Use 200% scale unless the user requests another scale.
5. Report image dimensions.
6. If the screenshot is too large or visually unfocused, loop back to Phase 3 to adjust folding/comments/layout.
7. Do not change topology in this phase unless the user explicitly approves a Phase 3 loopback.

---

## Command Pattern

The exact command may be shell CLI or internal mode grammar depending on the runner. The public `.hsc` must stay screenshot-free.

Preferred internal mode grammar after the example has been built:

```text
/dsp
cd {ModuleId}
screenshot scale 200% file "scriptnode_enrichment/hsc/phase5/{factory}/{node}.png"
/exit
```

Equivalent shell CLI pattern:

```text
hise-cli dsp screenshot --module {ModuleId} --scale 200% --output "scriptnode_enrichment/hsc/phase5/{factory}/{node}.png" --agent
```

Use the command form appropriate for the current automation environment.

---

## Batch Summary

After generating screenshots, return:

```text
factory.node | screenshot path | dimensions | success | loopback needed
```

If a screenshot fails, include the failing command and the exact error.
