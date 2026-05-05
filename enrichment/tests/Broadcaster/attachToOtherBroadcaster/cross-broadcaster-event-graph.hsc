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
// Context: In a complex plugin, broadcasters can target other broadcasters
// as listeners, creating a chain of reactive events. This allows event
// propagation without tight coupling between the systems that own each
// broadcaster.

// A channel selection broadcaster owned by the navigation system
const var channelBc = Engine.createBroadcaster({
    "id": "ChannelSelector",
    "args": ["channelIndex"]
});

// A filter state broadcaster owned by the effects system
const var filterBc = Engine.createBroadcaster({
    "id": "FilterUpdate",
    "args": ["channelIndex"]
});

var filterLog = [];

// When the channel changes, forward the event to the filter broadcaster
// so it can re-evaluate filter bypass states for the new channel
filterBc.attachToOtherBroadcaster(
    channelBc,
    false,  // No transform - forward args directly
    false,  // Synchronous forwarding
    "channelToFilter"
);

filterBc.addListener("", "updateFilter", function(channelIndex)
{
    filterLog.push(channelIndex);
});

channelBc.sendSyncMessage([2]); // Both broadcasters fire
// test
/compile

# Verify
/expect filterLog.length is 1
/expect filterLog[0] is 2
/exit
// end test
