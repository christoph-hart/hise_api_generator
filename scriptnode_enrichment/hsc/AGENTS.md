# HSC Example Authoring Rules

These rules apply to every file below `scriptnode_enrichment/hsc/`.

## Absolute prohibition on generated Phase 1 and Phase 2 documents

Never generate, scaffold, batch-create, or template Phase 1 or Phase 2 documents with Python, shell loops, code generators, data tables, or repeated boilerplate substitutions.

This prohibition includes scripts that produce documents which merely satisfy pipeline validation. Passing structural validation is not evidence that an example is technically correct, useful, or reviewed.

Author each Phase 1 and Phase 2 file individually. Do not create multiple Phase 1 or Phase 2 files in one tool call.

Automation remains allowed for these mechanical tasks only:

- Inventory reporting
- Validation of already authored documents
- Phase 4 execution
- Screenshot capture
- Phase 5 draft extraction from an approved Phase 3 artifact
- Publication

Phase 4 execution is mandatory, not optional. Every `.hsc` file must be run once through the connected HISE instance immediately after it is written or modified. Do not rely on structural validation or Phase 3 command validation as a substitute for execution. A script is not complete until HISE accepts the complete script without an error.

## Required research before Phase 1

Before authoring one Phase 1 file:

1. Read the primary node reference page completely.
2. Read `ideas.md` for the proposed scenario.
3. Read every proposed required support-node reference page completely.
4. Verify that each support node actually provides the assumed signal, event, routing, or modulation behavior.
5. Identify conflicts between the idea and documented node behavior.
6. Ask the user about choices that materially change the topology, sound, controls, or teaching goal.

Do not infer support-node behavior from its name.

## Phase 1 quality requirements

Every statement must be specific to the example. In particular:

- `Rationale` must explain the exact responsibility of every required support node.
- `Assumptions` must reflect the real channel, polyphony, MIDI, compilation, and host constraints.
- `User Input Needed` must preserve unresolved decisions. Never write `None` merely to complete the section.
- `Notes For Phase 2` must describe concrete architectural constraints and known failure modes from the reference documentation.

## Required research before Phase 2

Before authoring one Phase 2 file:

1. Re-read the approved Phase 1 file.
2. Re-read the primary and required support-node references completely.
3. Resolve every Phase 1 question with the user.
4. Check existing completed examples for established topology and naming patterns.
5. Design the actual parent-child hierarchy, signal flow, modulation flow, and lifecycle handling.
6. Verify parameter and property names against documentation. Do not invent plausible names.

## Phase 2 quality requirements

- Builder setup must describe setup unique to the scenario.
- Channel routing must identify exact channel roles where relevant.
- Public parameters must name real targets and explain matched versus unscaled mapping.
- Defaults must list intentional omissions, not generic statements.
- Locked values must be executable assignments or precise configuration requirements.
- Friction comments must explain concrete ordering constraints, node behavior, or known traps.
- Open questions must remain open until answered.

## Forbidden boilerplate

Do not use any of these phrases or close paraphrases:

- "follow the Phase 1 teaching goal and keep support nodes minimal"
- "preserve the hierarchy shown above"
- "values not listed as public or locked remain at node defaults"
- "provide the supporting signal, modulation, routing, or analysis context required by the scenario"
- "confirm nested nodes resolve under the intended container path"

If a section has nothing scenario-specific to say, research further instead of inserting filler.

## Review cadence

Work on one example at a time in this order:

1. Research
2. Surface questions
3. Obtain decisions
4. Author Phase 1
5. Review Phase 1
6. Author Phase 2
7. Review Phase 2
8. Move to live Phase 3 construction

Do not report a batch as complete solely because files exist or a structural validator passes.

## Phase 4 execution and publication gate

Phase 3 shell commands and Phase 4 HSC commands are different languages. Do not copy unquoted shell values into HSC. Quote every multi-word string, comment, enum value, expression, and property value that requires quoting in HSC syntax. In particular, `set Node.Comment` values must be quoted.

After writing or modifying each Phase 4 script:

1. Run that single `.hsc` file through the connected HISE instance.
2. Fix the first reported HSC error manually.
3. Run the same script again and continue until it succeeds.
4. Only then move to the next script.

The publish command is a hard gate. It must execute scripts in deterministic order and stop immediately at the first failed script. It must not continue launching HISE scripts after a syntax, API, screenshot, or connection failure. Later artifacts must not be reported as successful after an earlier script fails.
