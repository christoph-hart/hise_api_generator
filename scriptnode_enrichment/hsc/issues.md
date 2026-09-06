# HSC Pipeline Issues

This file tracks HISE and `hise-cli` friction discovered while building public HSC examples.

Ground rule: do not work around these bugs in examples. Stop the affected node, document the issue with exact reproduction steps, and wait for a HISE / CLI fix or explicit user approval.

Reproduction snippets should be pasteable `hise-cli` DSL, start from a fresh builder state with `/builder` + `reset`, and build the complete minimal example. Do not use `/hise playground open` in issue reproductions.

## Issue 1: hise-cli dsp set cannot write template-created container parameters

- **Node:** template.dry_wet / expanded `container.split`
- **Type:** CLI bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `fx.reverb`
- **Observed:** `dsp show` lists the expanded dry/wet container parameter `DryWet`, and `dsp get` can read it, but `dsp set` rejects the same parameter as unknown.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "dry_wet_set_repro"
  /exit

  /dsp
  cd S
  add template.dry_wet as "D"
  show D
  get D.DryWet.value
  set D.DryWet 0.35
  /exit
  ```
- **Observed result:** `dsp show` reports `DryWet`; `dsp get` returns `0`; `dsp set` fails with `Unknown parameter "DryWet" on container.split. Did you mean "Folded"?`.
- **Expected:** `dsp set` should be able to write any parameter that `dsp show` exposes and `dsp get` can read.
- **Impact:** Public examples cannot set template-created dynamic container parameter defaults directly from shell commands. This blocks clean dry/wet template examples until the CLI setter handles dynamic container parameters consistently.
- **Pipeline action:** Do not work around this in HSC examples. Stop the affected node and wait for CLI fix or explicit user approval.
- **Status:** Fixed and verified. `hise-cli dsp set --module S --node D --param DryWet --value 0.35 --agent` now succeeds and `dsp get` returns `0.35`.

## Issue 2: hise-cli dsp set --index drops incoming connection on template-owned wet gain

- **Node:** template.dry_wet / expanded `core.gain` wet gain
- **Type:** CLI mutation bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `fx.reverb`
- **Observed:** A freshly added `template.dry_wet` correctly creates `D_dry_wet_mixer.1 -> D_wet_gain.Gain`. Removing the dummy preserves the connection. Reordering the template-owned wet gain with `dsp set --index` removes the incoming connection.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "dry_wet_index_repro"
  /exit

  /dsp
  cd S
  add template.dry_wet as "D"
  show connections
  remove D_dummy
  show connections
  set D_wet_gain.index 0
  show connections
  /exit
  ```
- **Observed result:** Before reordering, connections include `DryWetMutationProbe_dry_wet_mixer.1 -> DryWetMutationProbe_wet_gain.Gain`. After `set --index`, that connection disappears while the dry gain connection remains.
- **Expected:** Reordering a node in its parent container should preserve incoming parameter/modulation connections to that node.
- **Impact:** Template examples can silently lose critical internal parameter wiring during CLI graph cleanup, producing valid-looking but behaviourally broken dry/wet networks.
- **Pipeline action:** Do not work around this in HSC examples. Stop the affected node and wait for CLI fix or explicit user approval.
- **Status:** Fixed and verified. After `set D_wet_gain.index 0`, `show connections` still reports `D_dry_wet_mixer.1 -> D_wet_gain.Gain`.

## Issue 3: hise-cli dsp get/set cannot address control.bipolar Scale parameter

- **Node:** control.bipolar
- **Type:** CLI parser bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `fx.haas`
- **Observed:** `dsp show` lists the `Scale` parameter on a `control.bipolar` node, but `dsp get` and `dsp set` reject `Scale` with a parser error.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "bipolar_scale_repro"
  /exit

  /dsp
  cd S
  add control.bipolar as "B"
  show B
  get B.Scale.value
  set B.Scale 0.65
  /exit
  ```
- **Shell reproduction observed during Phase 3:**
  ```bash
  hise-cli dsp show --module VoiceHaasScatter --node SpreadScale --agent
  hise-cli dsp get --module VoiceHaasScatter --node SpreadScale --param Scale --agent
  hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param Scale --value 0.65 --agent
  ```
- **Observed result:** `dsp show` reports parameters `Value`, `Scale`, and `Gamma`; `dsp get` / `dsp set` fail with `Parse error ... but found: 'Scale'`.
- **Expected:** `dsp get` and `dsp set` should address any parameter listed by `dsp show`, including `Scale`.
- **Impact:** `fx.haas` cannot expose a public Spread control through the intended `control.bipolar.Scale` stage without using a workaround. This blocks the HSC example.
- **Pipeline action:** Do not work around this in HSC examples. Stop `fx.haas` until the CLI parser handles `Scale` correctly or the user explicitly approves a different topology.
- **Status:** Fixed and verified. `hise-cli dsp get --module S --node B --param Scale --agent` returns `0`, `hise-cli dsp set --module S --node B --param Scale --value 0.65 --agent` succeeds, and a subsequent get returns `0.65`.

## Issue 4: core.extra_mod parent-context rule missing from docs

- **Node:** core.extra_mod / container.midichain / container.frame2_block
- **Type:** Documentation gap / hidden context rule
- **Severity:** medium
- **Source:** HSC pipeline live construction for `fx.phase_delay`
- **Observed:** Adding `core.extra_mod` directly to a freshly created `container.frame2_block` in a monophonic `ScriptFX` reports `Can't find suitable parent node`. Source inspection showed this is a valid runtime-context error: `core.extra_mod` processes HISE events and needs either a polyphonic root network or a `container.midichain` ancestor, with no `container.no_midi` ancestor. The docs did not mention this rule.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "frame_child_add_repro"
  /exit

  /dsp
  cd S
  add container.frame2_block as "F"
  add core.extra_mod as "M" to F
  show F
  /exit
  ```
- **Shell reproduction observed during Phase 3:**
  ```bash
  hise-cli dsp add --module PhaseFXRecreation --type container.frame2_block --id FramePhaseFX --agent
  hise-cli dsp add --module PhaseFXRecreation --type core.extra_mod --id PhaseMod --parent FramePhaseFX --agent
  hise-cli dsp show --module PhaseFXRecreation --node FramePhaseFX --agent
  ```
- **Observed result:** The second command returns `ok=false` with `PhaseMod - Can't find suitable parent node`, but `dsp show FramePhaseFX` lists `PhaseMod` as a child.
- **Expected:** `core.extra_mod` docs should say that in monophonic effect networks it requires `container.midichain`, and that frame processing must be nested below the midichain: `midichain -> frame2_block -> extra_mod`. `container.midichain` docs should also say it cannot be placed inside a frame context.
- **Impact:** Example builders can infer the wrong topology (`frame2_block -> extra_mod`) from incomplete docs and hit `NoMatchingParent` during validation.
- **Pipeline action:** Update docs and use the source-valid topology for `fx.phase_delay`: `container.midichain` outside `container.frame2_block`.
- **Status:** Reclassified. Documentation updated; `fx.phase_delay` may proceed with corrected topology.

## Issue 5: hise-cli cannot set root parameter ExternalModulation for core.extra_mod

- **Node:** core.extra_mod / root dynamic parameters
- **Type:** CLI missing affordance / documentation gap
- **Severity:** high
- **Source:** HSC pipeline live construction for `fx.phase_delay`
- **Observed:** `core.extra_mod` also requires one root parameter with `ExternalModulation` enabled so the selected `Index` maps to an existing extra modulation slot. Source inspection shows `extra_config_with_display::checkIndex()` validates `root->getParameterProperties().isUsed(index)`, which depends on root parameter `ExternalModulation`. The current `hise-cli dsp set` path can set dynamic parameter values and ranges, but does not expose setting the root parameter's `ExternalModulation` subproperty.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "extra_mod_slot_repro"
  /exit

  /dsp
  cd S
  add container.midichain as "MIDI"
  add core.extra_mod as "X" to MIDI
  create_parameter extra_mod_slot_repro.ModDepth [0, 1] default 0.5
  set extra_mod_slot_repro.ModDepth.ExternalModulation "Combined"
  show X
  /exit
  ```
- **Shell reproduction observed during Phase 3:**
  ```bash
  hise-cli dsp set --module PhaseFXRecreation --node phase_fx_recreation --param Frequency1.ExternalModulation --value Combined --agent
  ```
- **Observed result:** The shell command fails with `unknown sub-field: phase_fx_recreation.Frequency1.ExternalModulation`. The HSC run that uses `core.extra_mod` aborts with `PhaseMod - No parameter assigned to modulation slot #1`.
- **Expected:** HSC / CLI should expose setting `ExternalModulation` on root dynamic parameters, or `create_parameter` should accept an external modulation mode option. The `core.extra_mod` docs should state this root parameter slot requirement.
- **Impact:** HSC examples cannot build `core.extra_mod` examples that require a real extra modulation slot, including the intended `fx.phase_delay` PhaseFX recreation, without manual UI setup or direct ValueTree mutation.
- **Pipeline action:** Stop `fx.phase_delay` until HSC / CLI exposes root parameter external modulation setup or the user explicitly approves a different topology that avoids `core.extra_mod`.
- **Status:** Open.
