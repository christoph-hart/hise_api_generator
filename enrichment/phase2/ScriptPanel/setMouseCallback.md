## setMouseCallback

**Examples:**


```javascript:modal-dismiss-outside-click
// Title: Modal dialog dismiss on outside click
// Context: A full-interface overlay panel that dismisses when the user
// clicks outside the dialog box area. Uses the data object to store
// the box bounds for hit testing.

const var modal = Content.addPanel("ModalOverlay", 0, 0);
modal.set("width", 800);
modal.set("height", 600);
modal.set("visible", false);
modal.set("allowCallbacks", "Clicks Only");

// Store the dialog box bounds for hit-testing
modal.data.boxBounds = [175, 193, 450, 214];

modal.setMouseCallback(function(event)
{
    if (event.clicked)
    {
        // Dismiss if click is outside the dialog box
        if (!Rect.contains(this.data.boxBounds, [event.x, event.y]))
            this.set("visible", false);
    }
});

modal.setPaintRoutine(function(g)
{
    // Semi-transparent background
    g.fillAll(0x66000000);

    // Draw dialog box
    g.setColour(0xFFDDDDDD);
    g.fillRoundedRectangle(this.data.boxBounds, 10);
});
```
```json:testMetadata:modal-dismiss-outside-click
{
  "testable": false,
  "skipReason": "Requires visual UI interaction to show modal popup before testing dismiss behavior"
}
```

**Pitfalls:**
- The `event.drag` flag only fires when the mouse moves with the button held. For a click-then-drag control, always store the initial click position (from `event.clicked`) in `this.data` and compute the delta in the `event.drag` handler using `event.dragX`/`event.dragY`.
- The `event.hover` flag requires `allowCallbacks` to be at least `"Clicks & Hover"`. Setting `"Clicks Only"` silently suppresses hover events without any error.
