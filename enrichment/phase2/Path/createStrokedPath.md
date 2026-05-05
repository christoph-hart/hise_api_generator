## createStrokedPath

**Examples:**

```javascript:stroked-arc-laf-shadow
// Title: Thick fillable arc with inner shadow for a knob indicator
// Context: createStrokedPath converts a thin arc outline into thick
// fillable geometry. This is essential when you need to apply fills,
// gradients, or shadow effects to an arc stroke - drawPath can only
// stroke with a solid colour, while fillPath on the stroked result
// supports the full range of Graphics fill modes.

const var laf = Content.createLocalLookAndFeel();
const var ARC = 2.3;
const var strokeConfig = {
    "Thickness": 8.0,
    "EndCapStyle": "square",
    "JointStyle": "curved"
};

laf.registerFunction("drawRotarySlider", function(g, obj)
{
    var track = Content.createPath();
    var valuePath = Content.createPath();
    var area = obj.area;

    // Anchor + build arcs in normalized space
    track.startNewSubPath(area[0], area[1]);
    track.startNewSubPath(area[0] + area[2], area[1] + area[3]);
    track.addArc(area, -ARC, ARC);

    valuePath.startNewSubPath(area[0], area[1]);
    valuePath.startNewSubPath(area[0] + area[2], area[1] + area[3]);
    var end = -ARC + 2.0 * ARC * obj.valueNormalized;
    valuePath.addArc(area, -ARC, end);

    // Convert arcs to fillable shapes
    strokeConfig.Thickness = 3;
    g.setColour(0x22FFFFFF);
    g.fillPath(track.createStrokedPath(strokeConfig, ""), area);

    // Value arc with inner shadow glow
    var strokedValue = valuePath.createStrokedPath(strokeConfig, "");
    g.setColour(obj.itemColour1);
    g.fillPath(strokedValue, area);
    g.drawInnerShadowFromPath(strokedValue, area,
        Colours.withAlpha(obj.itemColour1, 0.5), 3, [0, 0]);
});
```
```json:testMetadata:stroked-arc-laf-shadow
{
  "testable": false,
  "skipReason": "LAF paint callback requires UI rendering context; cannot verify visual output programmatically"
}
```


**Pitfalls:**
- The second parameter `dotData` must be an array - pass `[]` for a solid stroke, not `""`. While some projects pass empty strings and it works (the engine silently treats non-arrays as solid), `[]` is the correct and explicit way to request no dash pattern.
