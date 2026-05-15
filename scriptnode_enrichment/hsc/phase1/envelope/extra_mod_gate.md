# envelope.extra_mod_gate - HSC Scenario

## Node

- Factory path: `envelope.extra_mod_gate`
- Source page: `scriptnode_enrichment/output/envelope/extra_mod_gate.md`

## Scenario

- Title: Extra modulation chain cleanup
- Project context: A polyphonic Script FX uses an extra modulation slot to drive a modulatable container parameter inside the DSP network. `envelope.extra_mod_gate` monitors the same extra modulation chain and kills the voice only after that extra envelope has finished its release.
- Teaching goal: Demonstrate how `envelope.extra_mod_gate` monitors an extra modulation chain and provides the binary Gate signal needed for voice lifecycle management.

## Support Nodes

- Required: [`container.mod_chain`, `core.extra_mod`, `envelope.voice_manager`]
- Optional: [`core.gain`, `filters.svf_eq`]
- Rationale: `container.mod_chain` provides the internal modulation context, `core.extra_mod` provides the continuous modulation value from the same extra chain, and `envelope.extra_mod_gate` provides the matching lifecycle gate. `envelope.voice_manager` performs the actual voice reset.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: true
- Questions:
  - How should the required extra modulation slot and modulatable container parameter be configured in HISE before Phase 2 generation?

## Notes For Phase 2

- Build this as a polyphonic Script FX; `envelope.extra_mod_gate` needs the polyphonic context to report per-voice release state correctly.
- The preprocessor must be configured so at least one extra modulation slot exists for the node to connect to.
- The example needs one container parameter set up as modulatable; this likely requires manual HISE-side setup because the current `hise-cli` interface does not support the full configuration.
- The example must describe the runtime target connection to the selected extra modulation chain; without it, the gate always reads active.
- Use the same Index value for `core.extra_mod` and `envelope.extra_mod_gate` so the continuous modulation and gate refer to the same extra chain.
- Enable `core.extra_mod.ProcessSignal` so the extra modulation chain becomes an actual gain-control signal in the effect path.
- Choose an envelope-based extra modulation chain, not a non-envelope modulator, so the gate can actually drop after release.
