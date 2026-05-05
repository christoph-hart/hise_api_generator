## setPaintRoutine

**Examples:**


```javascript:modulation-led-indicator
// Title: Modulation level LED indicator
// Context: Small indicator panels that show real-time modulator output.
// Each LED polls its assigned modulator and draws a colored ellipse
// that interpolates from dark to bright based on the current level.

const var mod = Synth.getModulator("LFO1");

const var led = Content.addPanel("ModLED", 0, 0);
led.set("width", 12);
led.set("height", 12);
led.set("opaque", true);

led.data.mod = mod;
led.data.value = 0.0;

led.setPaintRoutine(function(g)
{
    g.fillAll(0xFF222222);
    g.setColour(0xFFBBBBBB);
    g.fillEllipse(this.getLocalBounds(1));
    g.setColour(0xFF101010);
    g.fillEllipse(this.getLocalBounds(2));

    // Interpolate from dark grey to yellow based on modulator level
    g.setColour(Colours.mix(0xFF404040, 0xFFFFF600, this.data.value));
    g.fillEllipse(this.getLocalBounds(3));
});

led.setTimerCallback(function()
{
    this.data.value = this.data.mod.getCurrentLevel();
    this.repaint();
});

led.startTimer(30);
```
```json:testMetadata:modulation-led-indicator
{
  "testable": false,
  "skipReason": "Requires LFO1 modulator in the signal chain"
}
```

**Pitfalls:**
- Calling `setImage()` clears the paint routine and switches to fixed image mode. Setting a new paint routine via `setPaintRoutine()` cancels fixed image mode. These two rendering approaches are mutually exclusive on a single panel.
