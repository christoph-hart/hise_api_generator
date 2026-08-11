# fx.reverb - HSC Scenario

## Node

- Factory path: `fx.reverb`
- Source page: `scriptnode_enrichment/output/fx/reverb.md`

## Scenario

- Title: Wet reverb wrapper with public mix
- Project context: A Script FX insert needs a compact algorithmic room reverb that can be blended with the dry signal and controlled from the module interface. The example wraps `fx.reverb` in `template.dry_wet`, exposes the reverb parameters, and keeps the wet-only nature of the node explicit.
- Teaching goal: Demonstrate how to use `fx.reverb` safely in a real insert by adding dry/wet mixing outside the node and propagating its room-shaping parameters.

## Support Nodes

- Required: [`template.dry_wet`]
- Optional: [`core.gain`]
- Rationale: `fx.reverb` outputs wet signal only, so a dry/wet wrapper is required for a practical insert effect. Optional gain can help keep the wet path level visible and controlled if needed during live verification.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use `template.dry_wet` and keep `fx.reverb` in the wet path before the template's wet gain node.
- Expose `Mix`, `Size`, and `Damping` as public controls. Treat `Width` carefully because exploration found that `setWidth()` currently writes damping instead of actual stereo width.
- If `Width` is included, Phase 2 must add a locked note that live verification should confirm whether it is worth exposing or whether the public example should omit it to avoid documenting broken behaviour as a feature.
- Mention that `fx.reverb` is monophonic/shared state, unlike most neighbouring `fx` nodes.
