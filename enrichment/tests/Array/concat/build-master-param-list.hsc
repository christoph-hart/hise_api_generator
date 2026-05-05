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
// Context: A plugin with multiple channel strips builds its full
// automation parameter list by creating sub-arrays per channel,
// then concatenating them into one master array. concat() modifies
// in-place -- there is no return value.

inline function makeChannelParams(channelIndex)
{
    local params = [];
    local ch = channelIndex + 1;

    params.push({
        "ID": "Volume " + ch,
        "min": -100.0,
        "max": 0.0,
        "connections": [{ "processorId": "Gain " + ch, "parameterId": "Gain" }]
    });

    params.push({
        "ID": "Pan " + ch,
        "min": -100.0,
        "max": 100.0,
        "connections": [{ "processorId": "Gain " + ch, "parameterId": "Balance" }]
    });

    return params;
}

// Accumulate all channel parameters into one list
const var NUM_CHANNELS = 4;
const var allParams = [];

for(i = 0; i < NUM_CHANNELS; i++)
    allParams.concat(makeChannelParams(i));

Console.print(allParams.length); // 8 (2 params x 4 channels)
// test
/compile

# Verify
/expect-logs ["8"]
/expect allParams[7].ID is "Pan 4"
/exit
// end test
