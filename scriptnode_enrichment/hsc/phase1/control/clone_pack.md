# control.clone_pack - HSC Scenario

## Node

- Factory path: `control.clone_pack`
- Source page: `scriptnode_enrichment/output/control/clone_pack.md`

## Scenario

- Title: Drawbar Levels For Harmonic Clones
- Project context: Eight cloned sine oscillators form a harmonic additive tone, and an eight-slider pack stores an arbitrary gain for each partial. `control.clone_pack` sends each slider value to the matching clone while one Master Level scales the complete programmed spectrum.
- Teaching goal: Demonstrate explicit index-to-clone value assignment and the global Value multiplier applied to slider-pack data.

## Support Nodes

- Required: [`container.clone`, `control.clone_cable`, `core.oscillator`]
- Optional: [`control.pack_resizer`]
- Rationale: `container.clone` creates the eight identical oscillator chains; `control.clone_cable` in Harmonics mode assigns note-relative partial frequencies; `core.oscillator` generates each sine partial; and optional `control.pack_resizer` is needed only if clone count becomes variable rather than locked to eight.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Lock the clone count and clone-pack NumClones to eight, then duplicate one identical sine-oscillator chain across all clone slots.
- Use `control.clone_cable` Harmonics mode for oscillator Frequency with the required linear 0 to 20 kHz target range. Route `control.clone_pack` only to oscillator Gain.
- Initialise an eight-entry external SliderPack data slot in Interface `onInit`; do not use embedded programmable pack data because script cannot modify it.
- Expose the pack as eight drawbars and expose `control.clone_pack.Value` as Master Level. Each slider index must map to the same clone index.
- Verify editing one slider updates only its corresponding clone and changing Master Level multiplies every current pack value.
- Do not add `control.pack_resizer` unless clone count is made dynamic. With a fixed eight-clone example, manual size equality is clearer and avoids unnecessary support.
