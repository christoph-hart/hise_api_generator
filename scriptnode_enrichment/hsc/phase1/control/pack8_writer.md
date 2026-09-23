# control.pack8_writer - HSC Scenario

## Node

- Factory path: `control.pack8_writer`
- Source page: `scriptnode_enrichment/output/control/pack8_writer.md`

## Scenario

- Title: Eight-Step Cutoff Programmer
- Project context: Eight individually automatable controls write the largest fixed writer pack, which a clocked lookup reads as a conventional eight-step filter sequence. Each control owns one exact sequence position and can update it while playback continues.
- Teaching goal: Demonstrate the complete eight-input writer variant, automatic eight-entry sizing, and direct parameter-to-index correspondence.

## Support Nodes

- Required: [`core.clock_ramp`, `control.cable_pack`, `filters.svf`]
- Optional: []
- Rationale: `core.clock_ramp` supplies bar-synchronised lookup position; `control.cable_pack` reads the eight entries as held values; and `filters.svf` makes the programmed pattern audible as cutoff movement.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Assign writer and cable pack to the same external SliderPack slot and initialise eight values in Interface `onInit`.
- Expose Value1 through Value8 as Step 1 through Step 8. Verify they write indices 0 through 7 and that connecting the writer resizes the pack to exactly eight entries.
- Connect a one-bar clock ramp to the cable-pack lookup and map output to a useful LP filter frequency range with short non-zero smoothing.
- Keep AddToSignal disabled, use Synced update mode, and set deterministic stopped-transport output.
- Verify live edits alter only the selected step and remember that slider-pack UI notifications are asynchronous.
- This is the largest fixed writer. Use `control.pack_resizer` plus a different writing strategy if more than eight entries are required.
- Do not embed the script-initialised programmable pack.
