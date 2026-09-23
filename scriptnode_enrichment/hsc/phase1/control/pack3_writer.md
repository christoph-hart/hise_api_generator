# control.pack3_writer - HSC Scenario

## Node

- Factory path: `control.pack3_writer`
- Source page: `scriptnode_enrichment/output/control/pack3_writer.md`

## Scenario

- Title: Three-Partial Additive Mixer
- Project context: Three public level controls write a three-entry pack used by a cloned sine oscillator bank. Each Value parameter adjusts one harmonic's gain, creating a compact fundamental, second, and third partial mixer.
- Teaching goal: Demonstrate the three fixed writer inputs, their zero-based slider indices, and automatic pack sizing.

## Support Nodes

- Required: [`container.clone`, `control.clone_cable`, `control.clone_pack`, `core.oscillator`]
- Optional: []
- Rationale: `container.clone` supplies three identical oscillator chains; `control.clone_cable` assigns harmonic frequencies; `control.clone_pack` reads the written three-value gain pack per clone; and `core.oscillator` renders the independently levelled partials.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Lock the clone count, clone cable, clone pack, and writer width to three; configure identical sine oscillator child chains.
- Assign `control.pack3_writer` and `control.clone_pack` to one external SliderPack slot initialised in Interface `onInit`.
- Expose Value1, Value2, and Value3 as Fundamental, Second, and Third levels. Verify they write indices 0, 1, and 2 respectively.
- Use clone-cable Harmonics mode for oscillator Frequency with a linear 0 to 20 kHz target range, and use clone-pack output only for oscillator Gain.
- Connecting the writer must resize the pack to exactly three entries. UI display updates are asynchronous.
- Use conservative gain defaults because three summed oscillators can exceed unity, and do not embed the script-modified pack.
