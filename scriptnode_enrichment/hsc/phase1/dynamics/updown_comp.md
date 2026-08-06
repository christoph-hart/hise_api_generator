# dynamics.updown_comp - HSC Scenario

## Node

- Factory path: `dynamics.updown_comp`
- Source page: `scriptnode_enrichment/output/dynamics/updown_comp.md`

## Scenario

- Title: OTT multiband compressor recreation
- Project context: A stereo signal needs the aggressive upward and downward multiband compression associated with Ableton's famous OTT effect. The network splits the signal into low, mid, and high bands, applies independently calibrated `dynamics.updown_comp` stages, and uses a shared mix control to blend the processed bands back with their phase-matched dry counterparts.
- Teaching goal: Demonstrate how to build a calibrated OTT-style effect from `template.freq_split3`, three band-local `template.dry_wet` mixers, and `dynamics.updown_comp` nodes while preserving the tested gain staging.

## Support Nodes

- Required: [`template.freq_split3`, `template.dry_wet`, `math.mul`, `dynamics.updown_comp`]
- Optional: []
- Rationale: The frequency splitter supplies phase-coherent low, mid, and high bands. Each band-local dry/wet template keeps its dry path behind the same crossover filters as its processed path, avoiding phase and group-delay mismatch that would occur if the dry signal bypassed the splitter in a top-level mixer.

## Assumptions

- Channels: fixed stereo
- Public control needed: yes, one global Mix macro
- Raw node values acceptable: yes, all calibrated DSP values are hardcoded

## User Input Needed

- Required: false
- Questions:
- The three band dry/wet mixers intentionally share one root Mix parameter. Do not replace them with one top-level dry/wet mixer: its dry path would bypass the crossover filters.
- Preserve every numeric value; these values were painstakingly calibrated against the reference OTT effect.

## Notes For Phase 2

- The topology must stay exactly stereo; this node is not suitable for mono or wider multichannel layouts.
- The example should preserve a visible gap between `LowThreshold` and `HighThreshold` so the unity zone is easy to understand.
- The modulation output only reflects attenuation in the exported 0..1 range, so note that upward boost is not represented when sending the signal to `routing.global_cable`.
- If RMS is exposed, present it as a character switch between transient-sensitive peak behaviour and smoother average-level control.
