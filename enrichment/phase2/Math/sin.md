## sin

**Examples:**

```javascript:led-arc-positioning
// Title: Drawing an arc of LEDs around a rotary knob
// Context: Circular UI layouts use sin/cos to position elements
// at equal angles around a centre point. The arc offset and delta
// control where the arc starts and how far apart each LED sits.

const var NUM_LEDS = 11;
const var radius = 30;
const var arcOffset = 2.4;   // Start angle in radians
const var delta = 0.48;      // Angle between LEDs
const var centre = [50, 50];

// Inside a LAF paint routine:
for (i = 0; i < NUM_LEDS; i++)
{
    var x = centre[0] + radius * Math.sin(arcOffset - i * delta);
    var y = centre[1] + radius * Math.cos(arcOffset - i * delta);

    g.setColour(0xFF050505);
    g.fillEllipse([x - 2, y - 2, 4, 4]);
}
```
```json:testMetadata:led-arc-positioning
{
  "testable": false,
  "skipReason": "Paint routine fragment requiring Graphics context (g)"
}
```


