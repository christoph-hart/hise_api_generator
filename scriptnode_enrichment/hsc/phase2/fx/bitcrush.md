# fx.bitcrush - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/bitcrush.md`
- Reference: `scriptnode_enrichment/output/fx/bitcrush.md`

## Naming

- Module ID: `CrushedEchoTrail`
- Network ID: `crushed_echo_trail`

## Graph Plan

```text
crushed_echo_trail
  EchoLoop         template.feedback_delay
    EchoLoop_fb_out routing.receive
    EchoCrusher     fx.bitcrush
    FeedbackTone    filters.one_pole
    EchoLoop_fb_in  routing.send
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Inspect `template.feedback_delay` child IDs before inserting the crusher into the feedback path.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Bits -> `EchoCrusher.BitDepth` matched
- Target range before connection: `[4, 12]`
- Macro range: `[4, 12]`
- Default: `7`
- Feedback -> internal feedback gain parameter of `EchoLoop` matched
- Target range before connection: `[0, 0.8]`
- Macro range: `[0, 0.8]`
- Default: `0.45`
- DelayMs -> internal delay time parameter of `EchoLoop` matched
- Target range before connection: `[80, 600]`
- Macro range: `[80, 600]`
- Default: `240`

## Defaults To Omit

- `EchoCrusher.BitDepth` default `16`
- `EchoCrusher.Mode` default `0`

## Locked Build Values

- `EchoCrusher.Mode` = `1` Bipolar
- `EchoCrusher.BitDepth.range` = `[4, 12]`
- Feedback macro upper bound = `0.8`
- If `FeedbackTone` is used, set it as a gentle low-pass or high-cut support stage only; do not let it become the demonstrated node.

## Friction Comments To Weave In

- Before `template.feedback_delay`: putting `fx.bitcrush` in the feedback path makes each repeat degrade again.
- Before `EchoCrusher.Mode`: Bipolar mode avoids the DC bias that DC Offset mode can accumulate in repeated feedback.
- Before Feedback macro: feedback must remain below unity to avoid runaway echoes.

## Cosmetic Plan

- Main node: `EchoCrusher`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`EchoLoop`, `FeedbackTone`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`FeedbackTone`]
- Nodes that must stay visible: [`EchoLoop`, `EchoCrusher`]

## Open Questions

- Phase 3 must verify the exact feedback-template insertion point and internal parameter IDs for delay time and feedback gain.
