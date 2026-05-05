## pow

**Examples:**

```javascript:peak-meter-scaling
// Title: Perceptual peak meter scaling with fourth-root curve
// Context: Linear gain values need non-linear scaling for visually
// meaningful meter displays. The fourth root (0.25) maps the wide
// dynamic range of audio levels to a compact visual range.

const var meter = Content.addPanel("PeakMeter", 0, 0);

meter.setPaintRoutine(function(g)
{
    var area = this.getLocalBounds(0);
    var leftPeak = this.data.left;
    var rightPeak = this.data.right;

    // Fourth-root scaling: compresses loud values, expands quiet ones
    leftPeak = Math.pow(leftPeak / 2.0, 0.25);
    rightPeak = Math.pow(rightPeak / 2.0, 0.25);

    g.fillAll(0xFF222222);
    g.setColour(0xFF00FF00);
    g.fillRect([0, 0, 2, leftPeak * area[3]]);
    g.fillRect([4, 0, 2, rightPeak * area[3]]);
});
```
```json:testMetadata:peak-meter-scaling
{
  "testable": false,
  "skipReason": "Paint routine requiring Graphics context and runtime peak data (this.data.left/right)"
}
```

```javascript:biased-random-humanization
// Title: Biased random distribution for MIDI timing humanization
// Context: Raising Math.random() to a power > 1 biases the
// distribution toward zero, producing mostly small timing offsets
// with occasional larger ones - mimicking natural performance feel.

const var MAX_DELAY_MS = 50;

function onNoteOn()
{
    if (Message.isArtificial())
    {
        // Exponent 1.5 biases toward small delays
        local delaySamples = parseInt(
            MAX_DELAY_MS * 0.001 *
            Engine.getSampleRate() *
            Math.pow(Math.random(), 1.5)
        );

        Message.delayEvent(delaySamples);
    }
}
```
```json:testMetadata:biased-random-humanization
{
  "testable": false,
  "skipReason": "MIDI onNoteOn callback requiring note input; non-deterministic random delay"
}
```


