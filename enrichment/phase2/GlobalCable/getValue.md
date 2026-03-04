## getValue

**Examples:**

```javascript:timer-polled-cable-reading-for
// Title: Timer-polled cable reading for visual feedback
// Context: A ScriptPanel displays a modulation ring that shows the
// current cable value as an arc. The panel polls the cable on a
// timer rather than using a callback, which is simpler when the
// only consumer is a visual element.

const var rm = Engine.getGlobalRoutingManager();

const var ModDisplay = Content.getComponent("ModRing");

// Store the cable reference in the panel's data object so the
// timer callback can access it without a namespace lookup
ModDisplay.data.cable = rm.getCable("ModulationValue");

ModDisplay.setPaintRoutine(function(g)
{
    local arc = Content.createPath();
    local start = 2.4;
    local sweep = 2.0 * this.data.cable.getValue() * start;

    arc.startNewSubPath(0.0, 0.0);
    arc.startNewSubPath(1.0, 1.0);
    arc.addArc([0.0, 0.0, 1.0, 1.0], -start, -start + sweep);

    g.setColour(0x8800CCFF);
    g.drawPath(arc, this.getLocalBounds(3), 2.0);
});

ModDisplay.setTimerCallback(function()
{
    this.repaint();
});

ModDisplay.startTimer(30);

```
```json:testMetadata:timer-polled-cable-reading-for
{
  "testable": false
}
```


```javascript:peak-meter-with-smoothed
// Title: Peak meter with smoothed cable value
// Context: A DSP network writes peak levels to a cable. The script
// smooths the value for visually stable meter decay.

const var rm = Engine.getGlobalRoutingManager();
const var peakCable = rm.getCable("PeakLevel");

const var MeterPanel = Content.getComponent("PeakMeter");

MeterPanel.setTimerCallback(function()
{
    local currentValue = peakCable.getValue();

    // Attack: jump to new peaks immediately
    // Decay: smooth falloff for visual stability
    if (currentValue > this.data.value)
        this.data.value = currentValue;
    else
        this.data.value *= 0.8;

    this.repaint();
});

MeterPanel.startTimer(60);

```
```json:testMetadata:peak-meter-with-smoothed
{
  "testable": false
}
```

