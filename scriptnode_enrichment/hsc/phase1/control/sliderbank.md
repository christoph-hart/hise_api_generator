# control.sliderbank - HSC Scenario

## Node

- Factory path: `control.sliderbank`
- Source page: `scriptnode_enrichment/output/control/sliderbank.md`

## Scenario

- Title: Weighted Three-Target Macro
- Project context: One Character macro simultaneously opens a filter, increases soft saturation, and moves the signal toward the right. Three slider-pack entries define independent amounts so each destination responds with a different strength.
- Teaching goal: Demonstrate per-output multiplication of one input value by slider-pack weights and independent updates for changed weights.

## Support Nodes

- Required: [`filters.svf`, `math.tanh`, `jdsp.jpanner`]
- Optional: []
- Rationale: `filters.svf.Frequency`, `math.tanh.Value`, and `jdsp.jpanner.Pan` provide three visibly different target ranges, making the slider bank's separate weighted outputs and connection mappings easy to inspect.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set NumParameters to three and connect outputs in a fixed documented order: filter cutoff, saturation amount, then pan.
- Assign an external three-entry SliderPack slot and initialise distinct weights in Interface `onInit`. The slider bank resizes the pack to match NumParameters.
- Connect a public Character macro to Value, then give each output an explicit target range appropriate to its destination.
- Keep the target chain serial and lock unrelated filter, saturation, and panner parameters.
- Verify Character at zero sends zero-weighted results to all outputs, Character at one sends each stored weight, and changing one pack slider updates only its corresponding destination.
- Keep NumParameters at or below eight; outputs beyond index seven are unsupported.
- Do not embed the programmable pack because its startup weights are set from script.
