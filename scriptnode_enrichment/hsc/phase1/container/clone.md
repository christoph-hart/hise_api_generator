# container.clone - HSC Scenario

## Node

- Factory path: `container.clone`
- Source page: `scriptnode_enrichment/output/container/clone.md`

## Scenario

- Title: Dynamic Saw Unison
- Project context: A stereo tone generator duplicates a saw oscillator chain into a selectable number of active unison layers. One Spread control distributes oscillator frequency ratios across a 0.5x to 2x octave range and pan positions across the active clones, while gain compensation keeps the output manageable as layers are added.
- Teaching goal: Demonstrate how `container.clone` runs identical child chains in parallel while clone-aware control nodes differentiate pitch, stereo position, and gain per active clone.

## Support Nodes

- Required: [`control.clone_cable`, `core.oscillator`, `jdsp.jpanner`]
- Optional: []
- Rationale: An offline container presents the control-only nodes as one horizontal strip. Separate `control.clone_cable` instances distribute the shared Spread value to each clone's oscillator frequency ratio and panner position, and a Ducker-mode instance compensates level as clone count changes; `core.oscillator` generates the saw layer in every cloned chain; and `jdsp.jpanner` places each generated layer at its assigned stereo position.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure a finite maximum clone count and expose `NumClones` as the first root macro, with identical integer ranges connected to the clone container and every `control.clone_cable.NumClones` target.
- Use Parallel mode so each active clone generates into silence and is added to the parent signal without multiplying the input audio.
- The clone container creates one generated child chain. Rename it and build its saw-mode `core.oscillator` followed by `jdsp.jpanner`, widen NumClones to `[1, 8]`, then set NumClones to `8`. In the CLI, this value change silently performs the structural rebuild to eight physical child chains.
- Put all three clone cables in a horizontal `container.offline` control strip. Use two Spread-mode clone cables driven by the same public Spread macro. Map one to `core.oscillator.Freq Ratio` over the octave range `0.5..1..2` and the other to the full bipolar `jdsp.jpanner.Pan` range.
- Use a third clone cable in Ducker mode for oscillator gain compensation, and lock the panner to the Sine3dB constant-power rule.
- This canonical example is a fixed-pitch unison tone generator, not a MIDI-playable instrument. Keep the base frequency at 220 Hz and use the frequency ratio target to demonstrate octave-relative clone spread.
- Keep the clone outside frame-based containers. Clone parameters and complex data must not connect across clone boundaries except through clone-aware control nodes.
