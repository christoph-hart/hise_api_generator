## setText

**Examples:**


```javascript:broadcaster-driven-updates
// Title: Update markdown reactively via broadcaster
// Context: An error display panel listens to a status broadcaster
// and updates its markdown text when the status changes.

const var statusPanel = Content.addPanel("StatusPanel", 0, 0);
statusPanel.set("width", 400);
statusPanel.set("height", 150);

const var errorMd = Content.createMarkdownRenderer();
errorMd.setTextBounds([20, 20, 360, 120]);

const var statusBroadcaster = Engine.createBroadcaster({
    "id": "statusBc",
    "args": ["state", "message"]
});

statusBroadcaster.addListener(statusPanel, "update error text",
    function(state, message)
    {
        if (state != 0)
        {
            // setText() parses the markdown immediately
            this.data.errorMd.setText(message);
            this.repaint();
        }
    }
);

statusPanel.data.errorMd = errorMd;

statusPanel.setPaintRoutine(function(g)
{
    g.fillAll(0xFF222222);
    g.drawMarkdownText(this.data.errorMd);
});
```

```json:testMetadata:broadcaster-driven-updates
{
  "testable": false,
  "skipReason": "Listener effect (setText on renderer) has no scriptable readback; verification requires visual rendering"
}
```
