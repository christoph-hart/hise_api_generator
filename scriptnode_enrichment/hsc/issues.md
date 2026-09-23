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
- **Status:** Fixed and verified. In a fresh `MutationProbe` network, the invalid matched command failed and left `dsp connections` empty; the subsequent valid non-matched command succeeded.

## Issue 9: dsp rename is unsupported by the live DSP mutation backend

- **Node:** container.clone generated child
- **Type:** CLI/backend capability mismatch
- **Severity:** medium
- **Source:** HSC pipeline live construction for `container.clone`
- **Observed:** A fresh `container.clone` automatically creates one child chain named `clone_child`. The documented shell `dsp rename` command cannot rename it because the live DSP mutation backend rejects the underlying `set_id` operation as unsupported. The earlier apparent network unload was caused by the Playground being deactivated, not by this command.
- **Reproduction:** Paste this DSL into `hise-cli` to build the minimal topology:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "clone_child_rename_repro"
  /exit

  /dsp
  cd S
  add container.clone as "C"
  show C
  rename clone_child "RenamedChild"
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp rename --module S --node clone_child --id RenamedChild --agent
  hise-cli dsp tree --module S --agent
  ```
- **Observed result:** The command returns `unsupported op at domain dsp: set_id`; the network remains loaded and `clone_child` remains unchanged.
- **Expected:** The documented `dsp rename` command should work through the live DSP mutation backend, or the CLI should report that renaming is unavailable before issuing the unsupported operation.
- **Impact:** Phase 3 cannot apply the planned cosmetic ID `UnisonVoice` to the generated clone root. The graph can otherwise retain the generated `clone_child` ID.
- **Pipeline action:** Stop `container.clone` until the user approves retaining `clone_child` or the rename operation is implemented.
- **Status:** Fixed and verified. `dsp rename --module CloneRenameProbe --node clone_child --id RenamedChild --agent` succeeded, and the following tree inspection reported the generated child as `RenamedChild` with the network still loaded.

## Issue 10: hise-cli cannot configure the actual container.clone instance count

- **Node:** container.clone
- **Type:** CLI missing mutation affordance
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.clone`
- **Observed:** Setting `UnisonLayers.NumClones` range to `[1, 8]` changes the parameter metadata and allows runtime values up to 8, but it does not rebuild the clone container with eight actual child instances. The additional clone children had to be created manually from the Scriptnode UI.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "clone_count_repro"
  /exit

  /dsp
  cd S
  add container.clone as "C"
  add core.oscillator as "Osc" to clone_child
  set C.NumClones.range [1, 8]
  set C.NumClones 8
  show C
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp set --module S --node C --param NumClones --range "1,8" --stepSize 1 --agent
  hise-cli dsp set --module S --node C --param NumClones --value 8 --agent
  hise-cli dsp show --module S --node C --agent
  hise-cli dsp tree --module S --agent
  ```
- **Observed result:** `NumClones` reports a maximum and value of 8, while the clone container still has only its original generated child configuration. No CLI command exposes the UI action that rebuilds or duplicates the first child into eight configured clone instances.
- **Expected:** The CLI should provide an explicit atomic operation equivalent to the Scriptnode clone container's UI rebuild command, taking the desired configured clone count and duplicating the first child structure.
- **Impact:** Runtime traces can misleadingly report `NumClones=8` even though the network was never configured with eight clone instances. Public HSC cannot construct the intended unison topology without a manual UI step.
- **Pipeline action:** Stop `container.clone`. Do not treat widening the NumClones range as clone construction, and do not produce the Phase 3 artifact until the configured clone count can be built through CLI or the user explicitly permits a manual-only example.
- **Status:** Fixed and verified. Setting `UnisonLayers.NumClones` to `8` reported `Changed clone amount ... to 8 child nodes`; `dsp show` and `dsp tree` listed all eight physical chains, trace reported all eight frequency-ratio and pan values, and the maintainer confirmed the rebuilt clones in the UI.

## Issue 11: trace times out when injecting dynamic_blocksize index 0

- **Node:** container.dynamic_blocksize
- **Type:** HISE or CLI runtime trace bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.dynamic_blocksize`
- **Observed:** A structurally valid network with `dsp status` OK times out when one trace request injects root BlockSize index `0`, which switches `container.dynamic_blocksize` to one-sample frame processing. The network contains a modchain ramp/peak source and an additive target inside the dynamic container.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "dynamic_blocksize_trace_repro"
  /exit

  /dsp
  cd S
  add container.dynamic_blocksize as "D"
  add container.modchain as "M" to D
  add core.ramp as "R" to M
  add core.peak as "P" to M
  add math.add as "A" to D
  create_parameter dynamic_blocksize_trace_repro.BlockSize [0, 7] default 4 step 1
  connect dynamic_blocksize_trace_repro.BlockSize to D.BlockSize matched
  connect P to A.Value
  /exit
  ```
- **Shell trace reproduction:**
  ```bash
  hise-cli dsp status --module S --agent
  hise-cli dsp trace --module S --container dynamic_blocksize_trace_repro --inject silence --inject-param dynamic_blocksize_trace_repro.BlockSize=0 --probe-recursive --probe-param D.BlockSize --probe-param A.Value --trace-compact --agent
  ```
- **Observed result:** Runtime status succeeds, but the first trace returns `Probe timed out`.
- **Expected:** Trace should tolerate the documented one-buffer silence during runtime block-size re-preparation, then return frame-mode specs and the generated staircase signal.
- **Impact:** Mandatory Phase 3 trace validation cannot compare frame mode with larger dynamic block sizes.
- **Pipeline action:** Stop `container.dynamic_blocksize` until the trace completes after dynamic re-preparation or the user explicitly authorizes validation without index 0.
- **Status:** Still reproducible after the latest fix attempt. The complete example was rebuilt from a reset state and runtime status passed, but the first trace at index `0` timed out again. Indices `1..7` were not attempted after the first failure.

## Issue 12: dsp set parses some node Comments as numeric parameters

- **Node:** math.add, control.bipolar, container.fix128_block, container.multi
- **Type:** CLI parameter/property resolution bug
- **Severity:** medium
- **Source:** HSC pipeline live construction for `container.dynamic_blocksize`
- **Observed:** The standard property command for setting a Markdown Comment succeeds on surrounding container and support nodes but fails on nodes including `math.add` and `control.bipolar`. The parser expects a numeric literal and rejects the quoted comment string, indicating that it resolves Comment through the node's numeric parameter path instead of its generic property path.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "math_add_comment_repro"
  /exit

  /dsp
  cd S
  add math.add as "A"
  set A.Comment "Inspection comment."
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp set --module S --node A --param Comment --value '"Inspection comment."' --agent
  ```
- **Observed result:** The command fails with a parse error that expects `NumberLiteral` and rejects the quoted string.
- **Expected:** Comment is a generic node property and should accept the same quoted string syntax for `math.add` as for other nodes.
- **Impact:** The diagnostic staircase output node cannot receive its planned explanatory node comment through the public command sequence.
- **Pipeline action:** Stop `container.dynamic_blocksize`; do not silently omit the planned comment unless the user explicitly approves it.
- **Latest reproduction:** After the latest rebuild, `hise-cli dsp set --module ThreeLevelPhaseModulation --node ChannelAllocator --param Comment --value '"With one child, DynamicFrames inherits both stereo channels. Add a second multi child and its frame width becomes one channel."' --agent` succeeds.
- **Status:** Fixed and verified for `container.multi`. The planned framex comment was applied successfully, and the pipeline resumed through cosmetics, save, and screenshot.

## Issue 13: dsp disconnect cannot address parameter IDs containing spaces

- **Node:** core.oscillator `Freq Ratio`
- **Type:** CLI endpoint parsing bug
- **Severity:** high
- **Source:** HSC pipeline live revision for `container.fix8_block`
- **Observed:** `dsp connections` reports the target as node `AudibleTone`, parameter `Freq Ratio`, but `dsp disconnect` rejects the correctly shell-quoted combined endpoint `AudibleTone.Freq Ratio` because its internal command parser splits the endpoint at the space.
- **Reproduction:** Create `LfoValue -> AudibleTone.Freq Ratio`, then run:
  ```bash
  hise-cli dsp disconnect --module EventRasterVibrato --target 'AudibleTone.Freq Ratio' --agent
  ```
- **Observed result:** `disconnect: path must have at least 2 segments (use disconnect <node>.<param>)`
- **Expected:** The quoted endpoint should resolve to node `AudibleTone` and parameter ID `Freq Ratio`, matching the value returned by `dsp connections`.
- **Impact:** A valid existing modulation cable to any spaced parameter ID cannot be removed through the public disconnect command, blocking topology revisions without destructive node replacement.
- **Pipeline action:** Stop the `container.fix8_block` revision rather than removing and recreating the oscillator as a workaround.
- **Status:** Fixed and verified. The same quoted command successfully disconnected `LfoValue -> AudibleTone.Freq Ratio` after the fix.

## Issue 15: recursive trace crashes on an empty passthrough container

- **Node:** empty container.chain inside container.multi
- **Type:** HISE recursive trace crash
- **Severity:** critical
- **Source:** HSC pipeline live construction for `container.fix32_block`
- **Observed:** A recursive noise trace through an intentionally empty `MainAudio` chain originally returned contradictory metrics. After the attempted fix, the same trace crashed HISE at `NodeContainer.cpp:680`.
- **Reproduction topology:** `container.fix32_block -> container.sidechain -> container.multi`, with an empty `container.chain` as the first stereo slice and a generated key path as the second slice.
- **Shell reproduction:**
  ```bash
  hise-cli dsp trace --module SidechainDynamicMidCut --container sidechain_dynamic_mid_cut --inject noise --gain 0.25 --seed 1234 --inject-param sidechain_dynamic_mid_cut.MaxCut=0 --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- **Observed result:** HISE crashes at `NodeContainer.cpp:680`. In the empty-list branch around lines 663-669, `reports[0]` is converted into the container's own specs and signal, but execution then enters the report loop and indexes `list[index]` even though `list` is empty.
- **Expected:** The empty-container branch should skip the child-report loop, for example with an `else` or early return, while still reporting the chain's passthrough signal.
- **Impact:** Recursive trace crashes HISE when any intentionally empty container is present.
- **Pipeline action:** Stop `container.fix32_block` before cosmetics and finalization; do not replace the intentionally empty passthrough chain merely to avoid the reporting bug.
- **Status:** Fixed and verified. After rebuilding the complete topology, recursive tracing reported valid finite metrics for both channels of the empty `MainAudio` passthrough chain, including in-range peak indices, and HISE did not crash.

## Issue 20: soft_bypass dynamic Bypass target is unavailable or inert

- **Node:** container.soft_bypass
- **Type:** HISE or CLI parameter-connection bug
- **Severity:** high
- **Source:** HSC pipeline live validation for `container.soft_bypass`
- **Observed:** `dsp show` reports no numeric parameters and only the `Bypassed` property. Connecting a root switch to the documented dynamic target name `Bypass` fails with `Unknown parameter or property Bypass`. Connecting to `Bypassed` succeeds structurally, but changing the root switch between 0 and 1 leaves `VocalStrip.Bypassed=false`, reports no touched edge, and both traces continue through the active processing chain.
- **Primary reproduction:**
  ```bash
  hise-cli dsp connect --module ClickFreeVocalStrip --source click_free_vocal_strip --source-param StripEnable --target VocalStrip --param Bypass --matched --agent
  ```
- **Primary result:** `Unknown parameter or property Bypass.`
- **Inert alternative:**
  ```bash
  hise-cli dsp connect --module ClickFreeVocalStrip --source click_free_vocal_strip --source-param StripEnable --target VocalStrip --param Bypassed --agent
  hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param StripEnable --value 0 --agent
  hise-cli dsp get --module ClickFreeVocalStrip --node VocalStrip --param Bypassed --agent
  hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param StripEnable --value 1 --agent
  hise-cli dsp get --module ClickFreeVocalStrip --node VocalStrip --param Bypassed --agent
  ```
- **Inert result:** Both property reads return `false`; signal traces remain processed rather than switching between dry and wet states.
- **Expected:** `container.soft_bypass` should expose its documented dynamic bypass target through the public connection command, and root switch changes should drive its smoothed bypass transition.
- **Impact:** The canonical click-free automated strip cannot be validated or published.
- **Pipeline action:** Initially stopped `container.soft_bypass` before comments, cosmetics, save, screenshot, and Phase 3 artifact.
- **Resolution:** Fixed after the maintainer rebuild. The documented `VocalStrip.Bypass` target now connects successfully. Persistent `StripEnable=0` produced dry peak `0.0999`, while `StripEnable=1` ran the active strip and produced peak `0.1556` from the same seeded noise. This confirms the intended Off/On polarity and runtime behavior.
- **Status:** Fixed and verified.

## Issue 19: positive trace delay is reported as a negative value

- **Node:** container.repitch validation
- **Type:** HISE or CLI trace timing bug
- **Severity:** medium
- **Source:** HSC pipeline live validation for `container.repitch`
- **Observed:** Traces requested with `--delay-ms 20` complete successfully but report `delayMs: -1.3333` in the returned trace.
- **Reproduction command:**
  ```bash
  hise-cli dsp trace --module RepitchedReverbSpace --container repitched_reverb_space --inject dirac --gain 0.2 --inject-param repitched_reverb_space.RepitchFactor=0.5 --delay-ms 20 --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- **Additional evidence:** Increasing the request to `--delay-ms 100` returns `delayMs: -6.6667`. The negative magnitude grows with the requested delay instead of crossing positive after the repitch container latency, so this is not explained by subtracting an approximately 20 ms processing latency.
- **Expected:** The returned timing metadata should report the requested positive delay, or a documented nonnegative quantized equivalent.
- **Impact:** The reverb tail is nonzero and factor propagation is visible, but the timing metadata cannot establish where the probe occurred.
- **Pipeline action:** Initially stopped `container.repitch` before comments, cosmetics, save, screenshot, and Phase 3 artifact.
- **Resolution:** After the maintainer rebuild, repeating the 100 ms delayed trace completed successfully and no longer returned negative `delayMs` metadata.
- **Status:** Fixed and verified.

## Issue 18: injected parameter probe crashes in ParameterInjector::poll

- **Node:** container.multi example with root dynamic parameter injection
- **Type:** HISE runtime probe crash
- **Severity:** high
- **Source:** HSC pipeline live validation for `container.multi`
- **Observed:** Tracing the panner with temporary `per_channel_stereo_panner.Pan` injection crashed HISE in `ParameterInjector::poll()`.
- **Reproduction command:**
  ```bash
  hise-cli dsp trace --module PerChannelStereoPanner --container per_channel_stereo_panner --inject dc --gain 0.25 --inject-param per_channel_stereo_panner.Pan=-1 --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- **Expected:** The temporary root parameter value should map to `PanLaw.Value` and return channel-local gain traces without destabilizing HISE.
- **Resolution:** Fixed by the maintainer and rebuilt. After reconstructing the network, sequential traces at Pan `-1`, `0`, and `1` all completed successfully with the expected left, equal-power centre, and right outputs.
- **Status:** Fixed and verified.

## Issue 17: note-triggered trace times out for Script FX midichain

- **Node:** container.midichain
- **Type:** HISE or CLI trace bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.midichain`
- **Observed:** A fresh Script FX network with `container.midichain -> core.oscillator -> envelope.simple_ar` passes runtime status, but the first note-triggered recursive trace times out. Root Attack and Release parameter connections are valid.
- **Shell reproduction:**
  ```bash
  hise-cli dsp trace --module MidiPlayedFxSynth --container midi_played_fx_synth --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 10 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- **Observed result:** `Probe timed out`; `dsp status` immediately afterward still returns success with API `0.11.0`.
- **Expected:** The midichain should receive note 60, retune the Saw oscillator, trigger the AR envelope, and return nonzero stereo output with MIDI-enabled recursive specs.
- **Impact:** Mandatory Phase 3 runtime validation cannot verify MIDI delivery in the canonical midichain example.
- **Pipeline action:** Initially stopped `container.midichain` before comments, cosmetics, save, screenshot, and Phase 3 artifact.
- **Resolution:** Fixed after the maintainer rebuild. The exact 10 ms reproduction no longer times out. A second trace using a 1 ms nonzero event offset captured the articulated saw output on both channels with peak `0.4928` and confirmed `processMidi=true` inside the midichain.
- **Status:** Fixed and verified.

## Issue 16: note-triggered trace times out for polyphonic framex network

- **Node:** container.framex_block inside container.multi
- **Type:** HISE or CLI trace bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.framex_block`
- **Observed:** A fresh polyphonic Scriptnode Synthesiser passes runtime status, but a note-triggered recursive trace times out. The graph has one framex child inside a stereo multi container, three MIDI-pitched oscillators, two per-frame phase-modulation connections, a simple AR envelope with voice management, and mono2stereo after the multi.
- **Shell reproduction:**
  ```bash
  hise-cli dsp trace --module ThreeLevelPhaseModulation --container three_level_phase_modulation --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 10 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- **Observed result:** `Probe timed out`; `dsp status` immediately afterward still returns success.
- **Expected:** Note 60 should allocate a synth voice and return recursive one-sample frame specs, changing Sine2/Sine3 Phase values, and nonzero dual-mono carrier output.
- **Impact:** Mandatory Phase 3 runtime validation cannot verify the polyphonic dynamic-width frame example.
- **Pipeline action:** Stop `container.framex_block` before comments, cosmetics, save, and screenshot.
- **Root cause:** `VoiceDataStack::startVoice()` calls `DspNetwork::reset()` under a voice scope. `MultiChannelNode::reset()` delegates to `NodeContainer::resetNodes()`, which unconditionally cancelled its pending injector. Root chain and framex use `DynamicSerialProcessor::reset()`, which resets children without cancelling their own injector, explaining the different trace results.
- **Implementation:** Preserve pending injectors in `resetNodes()` during per-voice resets; retain cancellation for global resets. Arm the complete probe before sending its trigger note. Added direct multi and recursive multi/framex polyphonic regression coverage.
- **Status:** Fixed and verified after maintainer rebuild. Reconstructed the complete topology from a fresh builder state. The exact recursive reproduction succeeded twice, reporting all three containers, one-sample framex specs, changing Sine2/Sine3 Phase parameters, and nonzero output on both channels. Direct non-recursive tracing of ChannelAllocator also succeeded, and runtime status remained valid. No timeout increase.

## Issue 14: sequence play returns Unexpected response from HISE in playground

- **Node:** Scriptnode Synthesiser runtime validation
- **Type:** HISE or CLI sequence playback bug
- **Severity:** high
- **Source:** HSC pipeline live validation for `container.fix16_block`
- **Observed:** Stateful sequence creation, event parsing, flushing, and showing all succeed in one `--run` process, but playing the same valid note sequence aborts with `Unexpected response from HISE`. No voice is created, so the concurrently armed DSP trace times out.
- **Reproduction:**
  ```bash
  hise-cli --run - <<'EOF'
  /sequence
  create "snappy_trace_note"
  500ms play C3 127 for 1000ms
  flush
  play "snappy_trace_note"
  /exit
  EOF
  ```
- **Control check:** Replacing `play "snappy_trace_note"` with `show "snappy_trace_note"` completes successfully, confirming that definition state and event syntax are valid.
- **Observed result:** Batch execution aborts on the `play` line with `Unexpected response from HISE`.
- **Expected:** The sequence should send note-on and note-off events to the active playground Scriptnode Synthesiser and block until playback completes.
- **Impact:** The CLI cannot create an active synth voice for mandatory recursive trace validation of MIDI-driven examples.
- **Pipeline action:** Stop trace validation for `container.fix16_block` until sequence playback succeeds or the user explicitly approves manual MIDI validation.
- **Status:** Fixed and verified. `filters.svf Mode=LP` now applies successfully and is stored as numeric value `0`.

## Issue 6: dsp trace times out on a fresh branch network with expression children

- **Node:** container.branch / math.expr
- **Type:** HISE or CLI runtime trace bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.branch`
- **Observed:** After relaunching HISE and rebuilding the example from a reset builder state, the first and only `dsp trace` request timed out. `dsp status` reported the network as valid immediately before the trace. No concurrent or earlier trace request existed in the fresh HISE session.
- **Reproduction:** Paste this DSL into `hise-cli` to build the minimal topology:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "branch_trace_repro"
  /exit

  /dsp
  cd S
  add container.branch as "B"
  add math.expr as "E1" to B
  add math.expr as "E2" to B
  set E1.Code "Math.tanh(input * 2.0f)"
  set E2.Code "Math.sin(input * 2.0f)"
  /exit
  ```
- **Shell trace reproduction:**
  ```bash
  hise-cli dsp status --module S --agent
  hise-cli dsp trace --module S --container branch_trace_repro --inject dirac --gain 0.5 --probe-recursive --trace-compact --agent
  ```
- **Observed result:** Status returns `ok=true`; the single trace request returns `Probe timed out`.
- **Expected:** The trace should process the injected Dirac impulse through the selected expression child and return recursive signal evidence.
- **Impact:** `container.branch` cannot complete mandatory Phase 3 signal validation even though construction and runtime status succeed.
- **Pipeline action:** Stop `container.branch`; do not create its Phase 3 artifact until trace succeeds or the user explicitly authorizes proceeding without signal evidence.
- **Status:** Fixed and verified. After relaunching HISE with the fix, the first single recursive trace completed successfully and returned the selected `SineFold` output peak at `0.5985` for a `0.5` Dirac input.

## Issue 7: math.expr evaluates the parameterized HISE saturation formula incorrectly

- **Node:** math.expr
- **Type:** HISE expression runtime bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.branch`
- **Observed:** With `Value=0.75`, a `0.5` Dirac sample passed through `(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))` produces `0.2857`. Direct evaluation of the formula produces `0.8`. Replacing it with the mathematically equivalent locked-value expression `input * 4.0f / (1.0f + 3.0f * Math.abs(input))` produces the expected `0.8` in trace.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "expr_saturation_repro"
  /exit

  /dsp
  cd S
  add math.expr as "E"
  set E.Code "(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))"
  set E.Value 0.75
  /exit
  ```
- **Shell trace reproduction:**
  ```bash
  hise-cli dsp status --module S --agent
  hise-cli dsp trace --module S --container expr_saturation_repro --inject dirac --gain 0.5 --probe-after E --probe-param E.Value --trace-compact --agent
  ```
- **Observed result:** The probe confirms `E.Value=0.75` but reports output `0.2857` instead of `0.8`.
- **Expected:** A `0.5` input with `value=0.75` should evaluate to `0.8`.
- **Impact:** The approved `container.branch` HISE-saturation child does not implement its documented transfer function. A fixed-constant equivalent works only because this example locks Value to `0.75`.
- **Pipeline action:** Stop `container.branch`. Do not replace the approved parameterized expression with the constant equivalent unless the user explicitly approves that deviation.
- **Status:** Fixed and verified. In a fresh `ExprProbe` network, the original parameterized formula with `E.Value=0.75` produced the expected `0.8` peak for a `0.5` Dirac input.

## Issue 8: failed matched connection still mutates the graph

- **Node:** core.peak / dynamic container parameter
- **Type:** CLI mutation atomicity bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `container.chain`
- **Observed:** Connecting the modulation output of `core.peak` to a dynamic container parameter with `--matched` returns `matchRange requires a parameter source`, but the connection is created anyway. A subsequent valid connection attempt reports `Connection already exists`.
- **Reproduction:** Paste this DSL into `hise-cli` to build the minimal topology:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "failed_connect_mutation_repro"
  /exit

  /dsp
  cd S
  add container.modchain as "M"
  add core.peak as "P" to M
  add container.chain as "C"
  create_parameter C.Value [0, 1] default 0
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp connect --module S --source P --target C --param Value --matched --agent
  hise-cli dsp connections --module S --agent
  hise-cli dsp connect --module S --source P --target C --param Value --agent
  ```
- **Observed result:** The matched command fails, `dsp connections` nevertheless lists `P.0 -> C.Value`, and the valid command then fails because that connection already exists.
- **Expected:** A failed mutation must leave the graph unchanged. Either reject `--matched` without creating the connection, or support the connection and return success.
- **Impact:** Failed exploratory commands can silently alter the live graph and make later valid commands fail, so the final successful command history cannot be inferred safely without rebuilding.
- **Pipeline action:** Stop `container.chain`; do not rely on the partially successful mutation. Rebuild only after the CLI mutation is atomic or the user explicitly approves a clean no-`--matched` rebuild.
- **Status:** Fixed and verified by the maintainer. For a valid modulation-output connection, `--matched` is now ignored with an explicit message and the command succeeds, so the return status matches the resulting graph mutation.

## Issue 9: dsp set of filters.svf Mode corrupts the live DSP tree

- **Node:** filters.svf
- **Type:** HISE/CLI parameter serialization bug
- **Severity:** high
- **Source:** HSC pipeline live construction for `control.bang`
- **Observed:** `dsp set --node SteppedFilter --param Mode --value LP` returns success, but a subsequent DSP inspection fails with `DSP parameter "Mode" ... "value" must be number, numeric string, or null`. The graph can no longer be normalized or inspected.
- **Reproduction:** Paste this DSL into `hise-cli`:
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "svf_mode_repro"
  /exit

  /dsp
  cd S
  add filters.svf as "F"
  set F.Mode LP
  show F
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp set --module S --node F --param Mode --value LP --agent
  hise-cli dsp show --module S --node F --agent
  ```
- **Observed result:** The setter reports success, then `dsp show` fails because the serialized Mode value is non-numeric.
- **Expected:** The documented enum value `LP` should either be accepted and serialized in the format required by HISE, or the command should fail without corrupting the network.
- **Impact:** The live DSP network becomes unreadable after setting the SVF mode, blocking further Phase 3 construction and verification.
- **Pipeline action:** Stop `control.bang`. Do not continue or work around the issue by changing the example topology until the HISE/CLI behaviour is fixed or the user explicitly approves a workaround.
- **Status:** Fixed and verified. `filters.svf Mode=LP` now applies successfully and is stored as numeric value `0`.

## Issue 11: SNEX parser rejects the documented Math.min quantizer expression

- **Node:** control.cable_expr
- **Type:** HISE SNEX expression parser bug or documentation mismatch
- **Severity:** high
- **Source:** HSC pipeline live construction for `control.change`
- **Observed:** The earlier build accepted the expression only as a bracketed Code value and the node fell back to passthrough. After rebuilding the network from a fresh XML, the same expression is stored without brackets and compiles successfully.
- **Reproduction:**
  ```text
  /builder
  reset
  add ScriptFX as "S"
  set S.network "cable_expr_min_repro"
  /exit

  /dsp
  cd S
  add control.cable_expr as "E"
  set E.Code "Math.min(Math.floor(input * 4.0), 3.0) / 3.0"
  /exit
  ```
- **Shell reproduction:**
  ```bash
  hise-cli dsp set --module S --node E --param Code --value 'Math.min(Math.floor(input * 4.0), 3.0) / 3.0' --agent
  ```
- **Observed result:** A stale network retained a failed bracketed expression and silently fell back to passthrough. Rebuilding the network from a fresh XML causes `dsp set` to report the unbracketed expression, applies the compilation autofix, and returns runtime status ok.
- **Expected:** The documented endpoint-safe expression should compile, or the docs should provide a supported equivalent.
- **Impact:** Phase 3 cannot verify the approved four-level quantizer without changing the locked expression or risking a fifth out-of-range level.
- **Pipeline action:** Stop `control.change`. Do not replace the approved expression with a workaround until the HISE parser/docs are fixed or the user explicitly approves the deviation.
- **Status:** Fixed and verified by rebuilding the network from a fresh XML after the parser fix.

