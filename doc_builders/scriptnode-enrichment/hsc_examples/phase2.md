# HSC Examples Phase 2 - Topology Planning Pass

**Purpose:** Convert approved scenarios into deterministic graph plans. This phase decides the network topology, builder setup, public parameters, locked build values, friction comments, and visual focus before live CLI construction.

**Batch mode:** Horizontal. Process many approved Phase 1 artifacts at once.

**Input:**
- `scriptnode_enrichment/hsc/phase1/{factory}/{node}.md`
- `scriptnode_enrichment/output/{factory}/{node}.md`

**Output:**
- `scriptnode_enrichment/hsc/phase2/{factory}/{node}.md`

**User gate:** The user approves topology, channel assumptions, public controls, and visual focus before live CLI work.

---

## Planning Rules

1. Use `CamelCase` for module IDs.
2. Use `snake_case` for network IDs.
3. Keep the graph minimal. Add only nodes required to demonstrate the target node.
4. Use as many channels as necessary, but only plan non-default routing when it is relevant to the node. Record channel and routing requirements under `Builder Setup`.
5. Public/root parameters should expose raw target-node values with sensible narrowed ranges.
6. Prefer `connect ... matched` whenever possible. Narrow the target parameter range first if needed.
7. Identify default-value sets that should be omitted from the final command sequence.
8. Identify friction-point comments where the graph design is non-obvious.
9. Plan screenshot cosmetics: main node accent colour, relevant support nodes dim colour, utility nodes folded.
10. Record deterministic pre-build requirements in `Builder Setup`: host/module context, host-side prerequisites, channel/routing setup, and any builder-only environment steps. Use `Script FX` as the default host context unless the example specifically requires another host type.
11. Record exact static facts the builder must not improvise in `Locked Build Values`: formulas, non-default support-node modes, fixed indices, startup rates, and visual-verification defaults. These are discovered constraints of the node/example, not optional user choices.
12. If a branch inherits or duplicates signal that should not remain audible, explicitly plan how it is cleared, replaced, or kept intentionally empty.
13. Use `Open Questions` only for unresolved user decisions or truly unknown external setup. Do not place known setup steps or locked values there.

---

## Friction-Point Comment Rules

Phase 2 must identify comments for decisions that are not obvious from commands alone.

Section roles:
- `Builder Setup` = host context plus any additional prerequisites before graph construction.
- `Locked Build Values` = exact node-defined values or settings that Phase 3 must reproduce without improvisation.
- `Friction Comments To Weave In` = explanatory comments for the final public artifact, not setup instructions.
- `Open Questions` = unresolved items only.

Use comments for:
- Non-default host/module routing.
- Non-default channel counts.
- Channel isolation topology such as `container.multi`.
- Sidechain, send/receive, matrix routing, or other topology nodes whose purpose is not visually obvious.
- Hidden control-path containers such as `container.mod_chain`.
- Public parameter range narrowing before `matched` connections.
- Intentionally empty branches.
- Explicit signal disposal such as branch-initial `math.clear`.
- Widened parameter ranges.

Do not comment:
- Obvious parameter values.
- Basic `add` commands unless the node's role is non-obvious.
- Default values that will be intentionally omitted.

---

## Output Format

Write one file per node:

```text
scriptnode_enrichment/hsc/phase2/{factory}/{node}.md
```

Use this exact structure:

```markdown
# {factory}.{node} - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/{factory}/{node}.md`
- Reference: `scriptnode_enrichment/output/{factory}/{node}.md`

## Naming

- Module ID: `{CamelCase}`
- Network ID: `{snake_case}`

## Graph Plan

```text
{root}
  {node tree}
```

## Builder Setup

- Host context: {Script FX | Script Envelope | HISE global mod setup}
- Additional builder steps:
  - {step, or "None"}
- Channel/routing setup:
  - Required channels: {description}
  - Module routing: {default | matrix}
  - Master routing: {default | matrix}
  - Channel-specific comments needed: [{comment summary}, ...]

## Public Parameters

- {MacroName} -> {TargetNode}.{Parameter} matched
- Target range before connection: `{range}`
- Macro range: `{range}`
- Default: `{value}`

## Defaults To Omit

- `{Node.Param}` default `{value}`

## Locked Build Values

- `{Node.Property}` = `{value}`
- `Code` = `{exact string}`
- {or "None"}

## Friction Comments To Weave In

- Before `{command/topic}`: {comment text}

## Cosmetic Plan

- Main node: `{NodeId}`
- Accent colour: `0xAARRGGBB`
- Supporting relevant nodes: [`NodeId`, ...]
- Supporting colour: `0xAARRGGBB`
- Folded nodes: [`NodeId`, ...]
- Nodes that must stay visible: [`NodeId`, ...]

## Open Questions

- {question, or "None"}. Only unresolved items belong here.
```

---

## Batch Summary

After writing all artifacts, return a concise table:

```text
factory.node | module/network | channels | public controls | open questions
```

Do not proceed to Phase 3 until the user approves or edits the topology plans.
