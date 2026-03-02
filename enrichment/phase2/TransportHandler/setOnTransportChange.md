## setOnTransportChange

**Examples:**

```javascript
// Title: Bridge transport state to a Broadcaster for multi-file reactivity
// Context: When multiple script files need to react to play/stop, pass a Broadcaster
// as the callback function instead of a plain function. The TransportHandler will
// call the Broadcaster with the isPlaying argument, which propagates to all listeners.

const var th = Engine.createTransportHandler();

const var transportBroadcaster = Engine.createBroadcaster({
    "id": "Transport State",
    "args": ["isPlaying"]
});

// A Broadcaster can be passed directly as the callback function. It receives
// the isPlaying argument and dispatches it to all its listeners. This is the
// standard pattern for propagating transport state across multiple script files.
th.setOnTransportChange(AsyncNotification, transportBroadcaster);

// Now any script file can listen to transport changes through the Broadcaster
const var PlayButton = Content.addButton("PlayButton", 0, 0);

transportBroadcaster.addListener(PlayButton, "sync play button to transport",
    function(isPlaying)
    {
        this.setValue(isPlaying);
    });
```

