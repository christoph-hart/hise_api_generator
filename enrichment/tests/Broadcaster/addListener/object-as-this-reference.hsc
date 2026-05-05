// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Context: Passing a JSON object or array as the `object` parameter replaces `this`
// inside the callback, giving clean access to related data without external variables.

const var speedBroadcaster = Engine.createBroadcaster({
    "id": "PlaybackSpeed",
    "args": ["ratio"]
});

var lastRatio = 0;

speedBroadcaster.addListener({"scale": 2.0}, "updatePlayers", function(ratio)
{
    lastRatio = ratio * this.scale;
});

speedBroadcaster.sendSyncMessage(1.5);
// test
/compile

# Verify
/expect lastRatio is 3.0
/exit
// end test
