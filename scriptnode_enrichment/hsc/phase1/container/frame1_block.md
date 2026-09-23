# container.frame1_block - HSC Scenario

## Node

- Factory path: `container.frame1_block`
- Source page: `scriptnode_enrichment/output/container/frame1_block.md`

## Scenario

- Title: Antiphase Stereo Sample-Accurate Chorus
- Project context: A default stereo Script FX is split into independent mono left and right paths with `container.multi`. Each channel owns a `container.frame1_block`, sine LFO, and cubic delay; the right LFO is polarity-inverted so the two delay sweeps move in opposite directions before a shared dry/wet mix recombines them.
- Teaching goal: Demonstrate the one-channel contract of `container.frame1_block` without requiring a mono host, while showing a practical stereo use case where two independent frame processors provide sample-accurate antiphase chorus modulation.

## Support Nodes

- Required: [`template.dry_wet`, `container.multi`, `container.modchain`, `core.ramp`, `math.pi`, `math.sin`, `math.mul`, `math.sig2mod`, `core.peak`, `jdsp.jdelay_cubic`]
- Optional: []
- Rationale: `template.dry_wet` supplies a shared linear chorus mix; `container.multi` gives each stereo channel its own mono child; each `container.frame1_block` processes one channel per sample; ramp, pi, sine, normalization, and peak nodes create delay modulation; `math.mul` inverts the right sine; and cubic delays provide interpolation suitable for chorus.

## Assumptions

- Channels: default stereo, split into two independent mono frame paths
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the host and root network stereo. Place one `container.multi` in the dry/wet template's wet path and give it exactly two `container.frame1_block` children, mapping left and right channels to independent mono frame processors.
- Build each LFO as `core.ramp -> math.pi -> math.sin`; insert `math.mul` set to -1 only in the right path, then normalize and export with `core.peak`.
- Put each LFO modchain before its `jdsp.jdelay_cubic` target in the same frame container so DelayTime updates every sample.
- Configure both DelayTime targets to the same 4 to 10 ms range and both ramp periods identically. Their synchronized sources then produce opposite delay movement because only the right sine is inverted.
- Preserve the dry/wet template's generated wet gain as the final wet-path child and place the stereo multi before it.
- Expose one Rate parameter to both ramp periods over 200 to 6000 ms, one Mix parameter to the template, and one LfoGate parameter to both ramp gates. Toggle LfoGate off and on after construction so both independently created ramps restart on the same callback and remain exactly synchronized. The dry/wet law is linear, not equal-power.
- Add a module-tree WaveSynth before auditioning so MIDI notes provide an immediate stereo source for the chorus.
- Warn prominently that two interpreted frame1 branches execute this graph per sample and have extremely high CPU usage in the HISE network interpreter. The example should be compiled to a C++ node for practical use.
- Use cubic delay interpolation; do not substitute the Thiran variant for fast modulation.
