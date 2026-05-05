## addEllipse

**Examples:**

```javascript:ellipse-drop-shadow
// Title: Creating a circular path for drop shadow effects
// Context: Graphics shadow methods (drawDropShadowFromPath,
// drawInnerShadowFromPath) require a Path object. When you need
// a circular shadow - for instance, behind a knob center cap -
// addEllipse creates the circle path that the shadow is derived from.

const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawRotarySlider", function(g, obj)
{
    var w = obj.area[2];

    // Shadow behind the knob center
    var shadowPath = Content.createPath();
    shadowPath.addEllipse([0, 0, 1.0, 1.0]);

    g.drawDropShadowFromPath(shadowPath,
        [obj.area[0] + w * 0.22, obj.area[1] + w * 0.22,
         w * 0.56, w * 0.56],
        0xBB000000, w * 0.2, [0, w * 0.1]);

    // Knob center cap
    g.setColour(0xFF666666);
    g.fillEllipse([obj.area[0] + w * 0.25, obj.area[1] + w * 0.25,
                   w * 0.5, w * 0.5]);
});
```
```json:testMetadata:ellipse-drop-shadow
{
  "testable": false,
  "skipReason": "LAF paint callback requires UI rendering context; cannot verify visual output programmatically"
}
```


