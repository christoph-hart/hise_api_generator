# HSC Examples Phase 1 - Scenario Pass

**Purpose:** Propose real-world example scenarios for many scriptnode nodes. This phase decides what each example should teach, not how to build it.

**Batch mode:** Horizontal. Process many nodes at once, usually all nodes in a factory.

**Input:**
- `scriptnode_enrichment/output/{factory}/{node}.md`
- Optional: `scriptnode_enrichment/resources/usage_survey.md`

**Output:**
- `scriptnode_enrichment/hsc/phase1/{factory}.{node}.md`

**User gate:** The user approves, rejects, or edits the scenario before topology planning.

---

## Invocation Pattern

Example request:

```text
Please follow the guideline doc_builders/scriptnode-enrichment/hsc_examples/phase1.md for the nodes of the factory control.
```

For each target node, read its reference page and propose a practical project context. Do not write `.hsc` files and do not run HISE.

---

## Scenario Rules

1. The scenario must explain why this node exists in a real project.
2. Prefer minimal examples that demonstrate the node's core functionality.
3. Add support nodes only when they make the target node's behaviour understandable.
4. Use default stereo assumptions unless the node's purpose involves routing, channels, sidechains, multichannel processing, or channel-dependent behaviour.
5. If the real-world use case is unclear, mark `needs_user_input: true` and ask for context instead of inventing a weak scenario.
6. Avoid repetitive examples across neighbouring nodes in the same factory.

---

## Output Format

Write one file per node:

```text
scriptnode_enrichment/hsc/phase1/{factory}.{node}.md
```

Use this exact structure:

```markdown
# {factory}.{node} - HSC Scenario

## Node

- Factory path: `{factory}.{node}`
- Source page: `scriptnode_enrichment/output/{factory}/{node}.md`

## Scenario

- Title: {short title}
- Project context: {1-3 sentences}
- Teaching goal: {one sentence describing the behaviour the example demonstrates}

## Support Nodes

- Required: [{factory.node}, ...]
- Optional: [{factory.node}, ...]
- Rationale: {why support nodes are needed, or "None"}

## Assumptions

- Channels: {default stereo | multichannel required | unknown}
- Public control needed: {yes/no/unknown}
- Raw node values acceptable: {yes/no/unknown}

## User Input Needed

- Required: {true|false}
- Questions:
  - {question, or "None"}

## Notes For Phase 2

- {non-obvious scenario constraint}
```

---

## Batch Summary

After writing all artifacts, return a concise table:

```text
factory.node | scenario title | needs user input | main risk
```

Do not proceed to Phase 2 until the user approves or edits the scenarios.
