## setBypassed

**Examples:**


```javascript:one-shot-self-bypass
// Title: One-shot broadcaster that permanently disables itself
// Context: A broadcaster that fires once on first interaction then permanently
// disables itself. Useful for lazy initialization patterns.

const var initLoader = Engine.createBroadcaster({
    "id": "InitLoader",
    "args": ["component", "event"]
});

// --- setup ---
const var RootPanel = Content.addPanel("RootPanel", 0, 0);
RootPanel.set("width", 200);
RootPanel.set("height", 200);
RootPanel.set("saveInPreset", false);
// --- end setup ---

initLoader.attachToComponentMouseEvents(RootPanel, "Clicks & Hover", "hover");

var loadCount = 0;

initLoader.addListener("", "loadOnce", function(component, event)
{
    // Permanently disable - this broadcaster never fires again
    initLoader.setBypassed(true, false, false);
    loadCount++;
});
```
```json:testMetadata:one-shot-self-bypass
{
  "testable": false,
  "skipReason": "Mouse events require physical user interaction that cannot be triggered programmatically from script"
}
```

**Pitfalls:**
- The third parameter (`async`) has inverted semantics relative to its name. Passing `true` causes **synchronous** dispatch, and `false` causes **asynchronous** dispatch. Use `SyncNotification`/`AsyncNotification` constants for clarity: `setBypassed(false, true, SyncNotification)`.
