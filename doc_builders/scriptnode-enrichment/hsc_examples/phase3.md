# HSC Examples Phase 3 - Stateful Construction Pass

**Purpose:** Build one approved scriptnode example in a live HISE session, verify behaviour, optimize the successful shell `hise-cli` command list, apply comments and cosmetics, and produce the handoff artifact for public `.hsc` assembly.

**Batch mode:** Stateful per node. Do not process large batches in one session. This phase combines live prototyping, command optimization, friction comments, and cosmetics because these steps depend on shared context.

**Input:**
- `scriptnode_enrichment/hsc/phase2/{factory}/{node}.md`
- `scriptnode_enrichment/output/{factory}/{node}.md`
- Live HISE reachable via `hise-cli`

**Output:**
- `scriptnode_enrichment/hsc/phase3/{factory}/{node}.md`

**User gate:** The user approves the live-built network, optimized command list, comments, cosmetics, and screenshot command before Phase 4.

---

## Required Reading

Read `style-guide/scriptnode.md` before non-trivial construction work. It is the source of truth for Scriptnode graph semantics, container context, connection ranges, modulation, routing, polyphony, and compilation behaviour.

Use MCP-backed CLI docs for node and parameter lookup:

```bash
hise-cli dsp docs <factory.node> --agent
hise-cli dsp docs <factory> --agent
```

Do not guess node parameters, properties, or connection modes.

---

## Working Model

Separate live investigation from the Phase 4 handoff artifact.

During investigation:

- Edit the live graph incrementally. Make the smallest change that tests the current hypothesis.
- Use `dsp tree`, `dsp show`, `dsp get`, `dsp connections`, and `dsp trace` to verify behaviour before changing more structure.
- Keep a mental scratch model of the final from-scratch build, but do not rebuild the whole graph just to clean up while topology is still being debated.
- Do not write the Phase 3 artifact during investigation. The artifact documents the approved final network, not exploration history.

Before writing the artifact:

- Confirm the final topology with the user, especially any deviation from Phase 2.
- Confirm the trace evidence that justifies the final topology and connection choices.
- Confirm comments, cosmetics, visible nodes, folded nodes, and screenshot composition.
- Complete the documentation feedback pass: decide which live HISE / CLI discoveries should be promoted into node docs, general Scriptnode docs, agent style docs, or kept local to this artifact.
- Only then normalize the final network into a clean from-scratch command sequence for Phase 4.

The final public command block is not a terminal log. It is the smallest consistent build-from-scratch sequence for the signed-off network.

---

## Construction Rules

1. Work one node at a time unless the user explicitly requests a small related batch.
2. Use `hise-cli agent-context` and command-specific help when uncertain.
3. Run first checks before construction: `hise-cli -status --agent`, `hise-cli builder tree --agent`, and `hise-cli dsp tree --module {ModuleId} --agent` once the host exists.
4. If no DSP host exists, create or select one intentionally. For a default Script FX host, create the module and assign the planned network before adding DSP nodes.
5. Read `## Builder Setup` from the approved Phase 2 file before running builder CLI commands. Create the planned host context first, then apply any additional builder steps.
6. The root container ID is the assigned network name shown by `dsp tree`; use that ID for `--container`, `create_parameter`, and root parameter paths.
7. Apply all `## Locked Build Values` from the approved Phase 2 file before verification. Treat them as fixed node/example constraints, not optional build preferences.
8. Build incrementally and inspect after meaningful steps with `dsp tree`, `dsp show`, `dsp get`, and `dsp connections`.
9. Use `hise-cli dsp docs` before choosing unfamiliar nodes, parameters, properties, or connection modes.
10. Run `hise-cli dsp status --module {ModuleId} --agent` before trace validation. Runtime status catches graph-level issues that structural commands can miss.
11. If status reports an autofixable runtime error, run `hise-cli dsp status --module {ModuleId} --autofix --agent`, then run plain status again before tracing.
12. Verify parameter flow with `dsp trace` after structural and runtime-status checks.
13. Verify signal flow with `dsp trace` after structural and runtime-status checks.
14. During investigation, prefer incremental live edits over full rebuilds. Once the network is signed off, rewrite the final command list as a coherent from-scratch build.
15. Capture only successful shell `hise-cli ...` commands for the final artifact. Exclude failed attempts, temporary probes, cleanup commands, and CLI-fix exploration.
16. Optimize the final command list:
    - Add nodes directly to their final parent.
    - Omit default-value no-ops.
    - Avoid move/reparent commands if direct parent creation is possible.
    - Keep `matched` connections whenever possible.
17. Public/root parameters should expose raw target-node values with sensible narrowed ranges.
18. If using `matched`, narrow the target parameter range before connecting.
19. Use as many channels as required by the node. For most nodes, default stereo should be enough.
20. For channel/routing examples, explicitly verify module routing, master routing, and channel-isolation topology.
21. Verify any inherited or duplicated branches that Phase 2 planned to clear, replace, or leave intentionally empty.
22. If a target parameter appears to need multiple incoming controls, stop and insert a combiner node. A target parameter must not have more than one direct incoming connection.
23. Avoid unnecessary normalisation and rescaling. Prefer root/public parameters in useful native units, and check whether unscaled control variants can preserve the same parameter logic with less range mapping.
24. Do not write HSC mode grammar in this artifact. Phase 4 performs that conversion.
25. Do not put `save` or `screenshot` into the public command list. Keep them under pipeline-only commands.

---

## Trace Validation

Use trace after structural and runtime-status checks. Structure tells what is connected; runtime status tells whether the graph is valid for processing; trace tells what happened after a runtime stimulus. A graph can be structurally valid and still be runtime-invalid.

Runtime status validates graph-level processing errors before trace:

```bash
hise-cli dsp status --module {ModuleId} --agent
```

If HISE reports an autofixable runtime error, apply the autofix and immediately verify plain status again:

```bash
hise-cli dsp status --module {ModuleId} --autofix --agent
hise-cli dsp status --module {ModuleId} --agent
```

Record status and autofix evidence separately from trace evidence in the Phase 3 artifact. This matters for SNEX/expression nodes, Faust nodes, compiled-node constraints, special containers, routing mismatches, context mismatches, and deprecated nodes.

Parameter trace validates public/root controls and runtime parameter edges:

```bash
hise-cli dsp trace --module {ModuleId} --container {network_id} --inject-param {network_id}.{Parameter}=0.75 --probe-changed-parameters --agent
```

Use `--probe-changed-parameters` for discovery, then explicitly probe suspected targets with repeated `--probe-param <Node.Param>` flags. Changed-parameter traces report runtime values that changed during the stimulus, not all possible static dependencies.

Signal trace validates audio flow, silence, runaway values, context, and timing:

```bash
hise-cli dsp trace --module {ModuleId} --container {network_id} --inject dirac --probe-recursive --agent
```

Use `--probe-recursive` when topology context matters. Inspect recursive `specs` for unexpected channel count, block size, MIDI policy, polyphony, or container-context changes.

Mixed signal-to-parameter trace validates analysis or detector nodes that convert signal events into parameter changes:

```bash
hise-cli dsp trace --module {ModuleId} --container {network_id} --inject dirac --inject-before {NodeId} --probe-changed-parameters --agent
```

For time-domain timing, combine the requested delay, returned delay remainder, and captured peak index:

```text
eventMs = requestedDelayMs - response.delayMs + peakIndex / sampleRate * 1000
```

Probe slightly before the expected event so the peak lands inside the captured block. For feedback or container loops, account for block quantisation and loop/container latency.

Trace interpretation heuristics:

- Missing expected parameter edge: wrong source, target, parameter name, inactive control context, or unchanged runtime value.
- `outOfRange`: inspect raw units, target range, and `connectionMode`.
- `unscaled`: safe only when the source already computes exact target units.
- Signal silence: inspect gain, routing, filters, bypass, and container context.
- Parameter-only tests can produce silent audio by design; inspect `parameters.probed` and touched edges.
- Unexpected timing: account for block quantisation and container / feedback-loop latency.
- Unexpected behaviour after moving nodes: inspect recursive `specs` because context may have changed.

---

## Cosmetic Rules

1. The demonstrated node gets the accent colour and a concise Markdown comment explaining the project context.
2. Relevant non-utilitarian support nodes get a dim/desaturated colour.
3. Fold all nodes that are not relevant to understanding the demonstrated node.
4. Do not fold any ancestor container of a node that must remain visible. Folding a parent hides its children, even if the child itself is marked visible in the cosmetic plan.
5. Exception: if the demonstrated node is a control/output node, keep the target node visible if needed to show the cable.
6. Add comments to non-obvious topology containers.
7. Write comments with one `hise-cli dsp set ... --param Comment --value '\"...\"' --agent` command per node. Wrap the comment payload as an escaped quoted string so spaces and Markdown punctuation survive shell parsing.
8. Use only `0xAARRGGBB` colour literals.

---

## Friction Comments

During construction, update the Phase 2 friction comments with what actually mattered. These comments must be woven into the final `.hsc` in Phase 4.

Include comments for:
- Host/module routing that differs from defaults.
- Internal channels vs output channels.
- Why a topology node such as `container.multi` is required.
- Why a hidden control-path container such as `container.mod_chain` is required.
- Why a branch is intentionally empty.
- Why an inherited branch is explicitly cleared or replaced.
- Why a parameter range is narrowed before `matched`.
- Why a parameter range is widened.

Keep comments short and place them near the relevant command in the final command sequence. In the final command list, every comment write must wrap the payload as an escaped quoted string, for example `--value '\"Control branch only.\"'`.

---

## Documentation Feedback Pass

After the final topology, runtime behaviour, trace evidence, and optimized command list are approved, perform a short documentation feedback pass before writing or finalizing the Phase 3 artifact.

Phase 3 is the first live-contact phase with HISE and `hise-cli`, so it is expected to discover practical rules that earlier static docs missed. Promote those rules into the broader documentation when they are general enough to help future nodes.

Look for:

- incorrect or outdated factory paths, parameter names, properties, defaults, or ranges
- runtime requirements that are not visible from structure alone
- `dsp status` errors, autofix behaviour, or trace caveats
- connection-mode discoveries, especially scaled vs unscaled behaviour
- container-context discoveries, including channel count, block size, MIDI, polyphony, or hidden routing changes
- node semantics that differ from assumptions in Phase 1 or Phase 2
- CLI quoting, command-ordering, reload, or validation requirements
- reusable graph-construction rules, such as combiner nodes for multi-control targets
- user-facing workflow notes that differ from agent-facing CLI workflow notes

Promote findings at the right level:

- Node-specific behaviour goes in `scriptnode_enrichment/output/{factory}/{node}.md`.
- General Scriptnode concepts go in `language_enrichment/output/scriptnode.md`.
- Agent construction heuristics go in `style-guide/scriptnode.md`.
- Phase workflow requirements go in this Phase 3 guide.
- HSC-specific command or artifact rules go in the relevant HSC builder docs.
- If a finding changes an approved Phase 1 or Phase 2 assumption, update that phase artifact too.

Keep the human and agent documentation domains separate:

- User-facing docs should describe HISE UI actions, concepts, and expected behaviour.
- `llmRef` and agent-facing docs may include exact `hise-cli` commands.
- Do not put CLI-only workflow details into the main prose of user-facing node pages unless the page is explicitly about CLI usage.

Only promote findings that are reusable. Do not overfit a broad doc page to one example graph. If a rule only matters for the current example, keep it in the Phase 3 artifact as trace evidence, caveat, or preserved HSC comment.

Record the documentation feedback in the Phase 3 artifact:

- list docs updated, or state `None`
- list the general rules promoted
- list any intentionally local findings that were not promoted

---

## Output Format

Do not write this file until the user has approved the live-built topology, behaviour, trace evidence, optimized command list, comments, cosmetics, and screenshot command.

If the final network differs from Phase 2, record the difference and the trace evidence that justified it in `## Status`, `## Trace Validation`, and `## Comments To Preserve In HSC`.

Write one file per node:

```text
scriptnode_enrichment/hsc/phase3/{factory}/{node}.md
```

Use this exact structure:

```markdown
# {factory}.{node} - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/{factory}/{node}.md`
- Reference: `scriptnode_enrichment/output/{factory}/{node}.md`

## Status

- Built in HISE: {true|false}
- User approved: {true|false}
- Notes: {brief status}

## Naming

- Module ID: `{CamelCase}`
- Network ID: `{snake_case}`

## Builder Setup Applied

- Host context: `{Script FX | Script Envelope | HISE global mod setup}`
- Additional builder steps applied:
  - {step, or "None"}
- Channel/routing setup verified:
  - Required channels: `{value}`
  - Module routing: `{value}`
  - Master routing: `{value}`

## Verified Parameters

- `{Node.Param}` = `{value}` range `{min..max}` stepSize `{stepSize}`

## Verified Connections

- `{Source.Param}` -> `{Target.Param}` matched: {true|false}

## Trace Validation

- Parameter trace commands:
  - `{hise-cli dsp trace ...}`
- Parameter trace evidence:
  - `{brief evidence, touched edge, probed value, or "None"}`
- Signal trace commands:
  - `{hise-cli dsp trace ...}`
- Signal trace evidence:
  - `{brief evidence, peak/silence/timing/specs result, or "None"}`
- Trace caveats:
  - `{caveat, or "None"}`

## Locked Build Values Applied

- `{Node.Property}` = `{value}`
- {or "None"}

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
{hise-cli builder ...}
{hise-cli dsp ...}
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module {ModuleId} --agent
hise-cli dsp screenshot --module {ModuleId} --scale 200% --output "scriptnode_enrichment/hsc/phase5/{factory}/{node}.png" --agent
```

## Comments To Preserve In HSC

- Before `{command/topic}`: {comment text}

## Documentation Feedback

- Docs updated:
  - `{path}`: {brief reason}
  - {or "None"}
- General rules promoted:
  - {rule, or "None"}
- Local-only findings:
  - {finding kept local, or "None"}

## Cosmetics Applied

- Main node: `{NodeId}` colour `0xAARRGGBB`
- Support nodes: [`NodeId`, ...] colour `0xAARRGGBB`
- Folded nodes: [`NodeId`, ...]
- Visible target nodes: [`NodeId`, ...]

## Defaults Omitted

- `{Node.Param}` default `{value}`

## Open Issues

- {issue, or "None"}
```

---

## Final Response

Return:
- The optimized public command sequence summary.
- Parameter trace evidence.
- Signal trace evidence.
- Any pipeline-only commands.
- Any unresolved issues.
- Whether the user must approve before Phase 4.
