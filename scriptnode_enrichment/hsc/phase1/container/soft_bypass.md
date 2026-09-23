# container.soft_bypass - HSC Scenario

## Node

- Factory path: `container.soft_bypass`
- Source page: `scriptnode_enrichment/output/container/soft_bypass.md`

## Scenario

- Title: Click-Free Vocal Strip Enable
- Project context: A serial vocal channel strip combines a gentle high-pass filter, compressor, and soft saturator inside one wrapper. A public Strip Enable control fades the complete processed path in and out instead of hard-bypassing stateful stages during playback.
- Teaching goal: Demonstrate the smoothed dry-to-processed transition of one `container.soft_bypass` around an entire serial effect chain.

## Support Nodes

- Required: [`filters.one_pole`, `dynamics.comp`, `math.tanh`]
- Optional: [`math.mul`]
- Rationale: `filters.one_pole` provides the stateful HPF that would be vulnerable to abrupt bypass; `dynamics.comp` supplies level-dependent state and a clearly processed strip sound; `math.tanh` adds bounded soft saturation; and an optional pre-gain multiplier can drive the saturator if the source level is too low to reveal it.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use exactly one `container.soft_bypass` and place the HPF, compressor, and saturator serially inside it. Do not wrap each stage separately or chain multiple soft-bypass containers.
- Configure `filters.one_pole` in HP mode with non-zero smoothing, set the compressor threshold and ratio for moderate vocal control, and use restrained saturation drive so the complete strip remains level-comparable to bypass.
- Expose Strip Enable through the container's dynamic bypass connection and label its polarity clearly: connection values at or above 0.5 activate processing, while lower values bypass it.
- Keep `SmoothingTime` at a clearly audible but practical non-zero value and verify transitions on sustained vocal audio. Changing this property during a transition cancels the ramp and snaps to the current bypass state.
- Compare against a temporary hard-bypass transition only for verification; the canonical topology uses the soft wrapper.
- Do not route modulation from children to downstream targets as part of this example. Audio crossfades over `SmoothingTime`, but child modulation output is suppressed immediately on bypass and would not fade smoothly.
- MIDI events continue to reach children in both states, and bypass is shared rather than per voice.
