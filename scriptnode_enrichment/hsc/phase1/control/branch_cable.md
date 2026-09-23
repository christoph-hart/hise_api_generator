# control.branch_cable - HSC Scenario

## Node

- Factory path: `control.branch_cable`
- Source page: `scriptnode_enrichment/output/control/branch_cable.md`

## Scenario

- Title: Selectable RMS Meter Bus
- Project context: A stereo running-RMS analyser produces one normalised level value from built-in signal nodes. `control.branch_cable` routes each update to one of three named global cables for selectable input, effect, or output meter destinations, while unselected buses retain their last snapshot.
- Teaching goal: Demonstrate one-to-many control routing, immediate resend on Index changes, and retained state on unselected outputs.

## Support Nodes

- Required: [`container.split`, `math.square`, `filters.one_pole`, `math.sqrt`, `core.peak`, `math.clear`, `routing.global_cable`]
- Optional: []
- Rationale: `container.split` preserves the audible input while feeding an analysis branch; `math.square`, `filters.one_pole`, and `math.sqrt` form an exponential running-RMS envelope; `core.peak` exports the maximum channel envelope once per block; `math.clear` prevents the analysis signal from being summed into the output; and three `routing.global_cable` instances publish the selected result under distinct cross-network meter IDs.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build two split branches: an unchanged audio path and `math.square -> filters.one_pole -> math.sqrt -> core.peak -> math.clear` for analysis. The clear node must remain after the peak exporter so the derived envelope never enters the summed audio output.
- Configure the one-pole node in LP mode and choose its cutoff from the desired RMS averaging time. Squaring guarantees non-negative input to `math.sqrt`, avoiding NaN output.
- Treat the result as the maximum of the left and right running-RMS envelopes because `core.peak` exports the largest channel value. Do not describe it as a single arithmetic mean across both channels.
- Set branch NumParameters to three, connect outputs to separately named InputMeter, EffectMeter, and OutputMeter global cables, and expose Index as a three-choice Meter Bus selector.
- Connect analyser modulation to branch Value. Changing Index must immediately send the current RMS value to the newly selected cable.
- Unselected outputs retain their previous values. Present them as last snapshots, or explicitly send zero before changing Index in Interface script if inactive meters must clear; do not imply automatic reset.
- Keep values normalised because global cables clamp to 0 to 1. Send scalar cable values only, not non-realtime `var` payloads.
