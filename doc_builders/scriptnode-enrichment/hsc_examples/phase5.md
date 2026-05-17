# HSC Examples Phase 5 - MCP / Website Example Authoring Pass

**Purpose:** Turn generated draft references into concise authored MCP references and website metadata sources. Screenshots are no longer a tracked phase artifact; `hsc_pipeline.py publish` generates screenshots directly into `scriptnode_enrichment/hsc/output/` as disposable build artifacts.

**Batch mode:** Small batches or single-node authoring. This phase is editorial and should be reviewed for relevance, concision, and search quality.

**Input:**
- `scriptnode_enrichment/hsc/phase1/{factory}/{node}.md`
- `scriptnode_enrichment/hsc/phase2/{factory}/{node}.md`
- `scriptnode_enrichment/hsc/phase3/{factory}/{node}.md`
- `scriptnode_enrichment/hsc/phase4/{factory}/{node}.hsc`
- Draft generated on demand with `hsc_pipeline.py draft-llmref --node {factory.node}`

**Output:**
- `scriptnode_enrichment/hsc/phase5/{factory}/{node}.llm.md`

**User gate:** The user approves the authored MCP reference before publish packaging.

---

## Workflow

1. Generate a draft into the current authoring context:

```bash
python scriptnode_enrichment/hsc/resources/hsc_pipeline.py draft-llmref --node dynamics.gate
```

2. Rewrite the draft into the concise Phase 5 format below.
3. Write the authored reference to `scriptnode_enrichment/hsc/phase5/{factory}/{node}.llm.md`.
4. Run publish after approval:

```bash
python scriptnode_enrichment/hsc/resources/hsc_pipeline.py publish --node dynamics.gate
```

`publish` runs the Phase 4 `.hsc`, waits for UI readiness, captures the screenshot into `scriptnode_enrichment/hsc/output/{factory}/{node}.png`, then writes website/MCP JSON using the authored Phase 5 reference.

---

## File Format

Every Phase 5 file must use YAML frontmatter followed by a concise Markdown body.

````markdown
---
id: dynamics.gate.noise-layer-gate
node: dynamics.gate
domain: scriptnode
category: dsp-network
title: Noise layer gate from split signal
summary: Uses dynamics.gate as an analysis branch to open a generated noise texture while dry audio passes unchanged.
useCase: Use this when you need an input-driven gate control signal that modulates a separate texture or effect branch.
difficulty: intermediate
networkName: noise_layer_gate
moduleType: ScriptFX
moduleId: NoiseLayerGate
tags:
  - gate
  - noise-layer
aliases:
  - gated noise layer
  - gate modulation to gain
relatedNodes:
  - dynamics.gate
  - container.split
parameters:
  GateThreshold: Controls when SelfGate opens from the duplicate analysis branch.
---

scriptnode example: dynamics.gate

Noise layer gate from split signal.
Use this to derive a gate control signal from the input while keeping dry audio untouched.

Graph:
```text
noise_layer_gate
  TextureSplit          container.split
```

Host:
  Module: `NoiseLayerGate`
  Type: `ScriptFX`
  Network: `noise_layer_gate`
  Routing: default stereo
  Builder setup:
    - `add ScriptFX as "NoiseLayerGate"`
    - `set NoiseLayerGate.network "noise_layer_gate"`

Support nodes:
  Required: `container.split`, `core.gain`, `core.oscillator`
  Optional: `container.fix16_block`, `filters.svf_eq`

Key rules:
  - Keep the dry path separate because `dynamics.gate` has no analysis-only `ProcessSignal` switch.

Public controls:
  - `GateThreshold` -> `SelfGate.Threshhold`, matched, `-48..-18`, default `-30`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
```
````

---

## Frontmatter Rules

1. `id` must be stable and allow multiple examples per node: `{factory.node}.{short-slug}`.
2. `node` is the primary Scriptnode factory path, eg `dynamics.gate`. Every example has exactly one primary node.
3. `domain` should be `scriptnode` and `category` should be `dsp-network`.
4. `summary` and `useCase` should be prose-first and semantic-search friendly.
5. `difficulty` should be `beginner`, `intermediate`, or `advanced`.
6. `networkName`, `moduleType`, and `moduleId` should match the authored HSC example.
7. `tags` should include user intent words, sound/design terms, and routing concepts.
8. `aliases` should include common user query phrases and alternate names for the example's technique.
9. `relatedNodes` must include the primary node and important helper nodes that are useful lookup targets.
10. `parameters` should describe public controls and non-obvious internal targets that matter for search or correct construction.

---

## Body Rules

1. Keep the body concise and agent-facing.
2. Keep `Graph` fenced as `text`; indentation is semantically meaningful.
3. Include `Host` with module type, module ID, network ID, routing notes, and behaviorally important builder setup.
4. Include `Support nodes` as lookup references.
5. Use one `Key rules` section. Fold construction rules, common mistakes, important defaults, reusable trace caveats, and non-obvious support-node rationale into it.
6. Keep `Public controls` as one line per control.
7. Keep the `HISE CLI build commands` block complete and executable.
8. Do not include the full `.hsc` script in the Markdown body. `publish` packages it separately for the website runner.

---

## Remove From Draft

Delete or rewrite anything that is only internal provenance:

- screenshot layout notes
- colour-only notes
- folding notes unless they affect runtime behavior
- `Verified connections`
- raw trace values
- validation transcripts
- `Intentional defaults omitted` as a standalone section
- `Pipeline-Only Commands`
- approval/status notes
- full HSC script

If a default, trace caveat, or support-node rationale is behaviorally important, rewrite it as a concise `Key rules` bullet.

---

## Publish Output

`hsc_pipeline.py publish` consumes the authored Phase 5 reference and writes gitignored build artifacts:

- `scriptnode_enrichment/hsc/output/{factory}/{node}.json`
- `scriptnode_enrichment/hsc/output/{factory}/{node}.llm.md`
- `scriptnode_enrichment/hsc/output/{factory}/{node}.png`

The JSON includes the Phase 5 frontmatter, authored body, synthesized semantic `text`, Phase 3 CLI command list, Phase 4 `.hsc` script, and screenshot filename. The semantic `text` is generated from high-signal frontmatter fields only: title, primary node, summary, use case, related nodes, tags, aliases, and parameter names.
