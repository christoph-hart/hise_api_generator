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
// Context: When loading a preset that changes many values simultaneously,
// bypass the broadcaster to prevent listeners from reacting to each
// intermediate state. Unbypass with sendMessageIfEnabled to send the
// final state once at the end.

const var channelBc = Engine.createBroadcaster({
    "id": "ChannelState",
    "args": ["index"]
});

var channelLog = [];

channelBc.addListener("", "updateUI", function(index)
{
    channelLog.push(index);
});

// During preset load, suppress all intermediate updates
channelBc.setBypassed(true, false, false);

// ... restore many values from preset data ...
channelBc.sendSyncMessage([5]);  // Stored but not dispatched
channelBc.sendSyncMessage([3]);  // Stored but not dispatched

// Unbypass and resend the final state
// Note: true = synchronous dispatch (despite the parameter being named "async")
channelBc.setBypassed(false, true, true);
// Listener fires once with value 3
// test
/compile

# Verify
/expect channelLog.length is 1
/expect channelLog[0] is 3
/exit
// end test
