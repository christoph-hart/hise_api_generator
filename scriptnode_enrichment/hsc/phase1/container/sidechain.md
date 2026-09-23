# container.sidechain - HSC Scenario

## Node

- Factory path: `container.sidechain`
- Source page: `scriptnode_enrichment/output/container/sidechain.md`

## Scenario

- Title: Internally Keyed Pumping Compressor
- Project context: A stereo effect expands its two input channels to four, keeps the original audio on channels 0-1, and generates a fixed low-frequency sine key on the otherwise empty channels 2-3. A sidechain-enabled compressor uses that internal key to create periodic pumping, after which only the processed main stereo pair leaves the container.
- Teaching goal: Demonstrate that `container.sidechain` creates zeroed auxiliary channels which must be filled explicitly before a child processor can use them as a detector input.

## Support Nodes

- Required: [`container.multi`, `container.no_midi`, `core.oscillator`, `dynamics.comp`]
- Optional: []
- Rationale: `container.multi` divides the expanded four-channel buffer into a passthrough main stereo slice and a key-generator stereo slice; `container.no_midi` prevents notes from retuning the fixed key source; `core.oscillator` writes the periodic signal into channels 2-3; and `dynamics.comp` reads those channels in Sidechain mode while applying gain reduction only to channels 0-1.

## Assumptions

- Channels: multichannel required
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Inside `container.sidechain`, place a four-channel `container.multi` before `dynamics.comp`. Give the multi exactly two stereo children: a passthrough chain for channels 0-1 and a `container.no_midi` chain containing the key oscillator for channels 2-3.
- Override the key oscillator Frequency range to include sub-audio rates, lock it to Sine mode with Gate on, and expose that parameter as Pump Rate. The no-MIDI wrapper must keep its frequency unchanged when notes arrive.
- Set `dynamics.comp.Sidechain` explicitly to Sidechain, not Disabled or Original, and choose threshold, ratio, attack, and release values that make the internally generated key produce obvious gain reduction.
- Verify that the extra channels begin at zero, contain the generated key before the compressor, and are discarded when returning from `container.sidechain`; only processed channels 0-1 should reach the parent.
- This internal example does not require `HISE_NUM_FX_PLUGIN_CHANNELS` or a four-channel Script FX wrapper because the extra pair is created and consumed inside the node. Do not describe it as a DAW sidechain input.
- Keep the sidechain container out of frame-based parents.
