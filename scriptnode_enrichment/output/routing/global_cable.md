---
title: routing.global_cable
description: "Routes a normalised control value across all DspNetworks via a named cable connection."
factoryPath: routing.global_cable
factory: routing
polyphonic: false
tags: [routing, control, global, cable]
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "routing.local_cable", type: disambiguation, reason: "Network-scoped alternative for connections within a single network" }
  - { id: "GlobalCable", type: api, reason: "Direct equivalent -- scriptnode node wraps the GlobalCable API for cross-network value distribution" }
commonMistakes:
  - title: "Values clamped to 0..1 range"
    wrong: "Sending a value of 440.0 through a global_cable expecting it to arrive unchanged"
    right: "All values are clamped to 0..1. Use a range converter on the receiving end to map back to the target range."
    explanation: "The global cable system clamps all values to 0..1 internally. To transmit values outside this range, normalise before sending and denormalise after receiving."
forumReferences:
  - id: 1
    title: "Nested compiled C++ nodes"
    summary: "A compiled external C++ node using global cables needs fixed runtime-target metadata and a second template parameter when it is nested in another compiled network."
    topic: 12543
llmRef: |
  routing.global_cable

  Routes a normalised 0..1 control value across all DspNetworks via a named cable connection. Bidirectional -- any global_cable node on the same Connection ID can send or receive. A recursion guard prevents feedback loops.

  Signal flow:
    Control node -- no audio processing
    Value param -> broadcast to all peers on same Connection -> modulation output on receivers

  CPU: negligible, monophonic

  Parameters:
    Value: 0.0 - 1.0 (default 1.0). Control value sent/received through the cable.

  When to use:
    Cross-network control value routing. 13 instances across surveyed projects (rank 30). Use for linking parameters between different DspNetworks or for OSC integration (IDs starting with /). Prefer routing.local_cable when connections stay within a single network.

  Common mistakes:
    Values are always clamped to 0..1 -- use range converters for wider ranges.

  External C++ integration:
    Use Tools -> Create C++ code for global cables to generate the GlobalCables enum and routing::global_cable_cpp_manager setup for the current cable IDs. Inherit the generated manager in the external node.
    setGlobalCableValue<Cable>(value) sends scalar values and is realtime safe. Listener callbacks run synchronously, so avoid redundant calls from the sample loop and prefer sending once per block where possible.
    sendDataToGlobalCable<Cable>(data) sends cloned juce::var data and is not realtime safe. Use it only for non-realtime data such as analysis buffers or UI payloads.
    registerDataCallback<Cable>(callback) receives juce::var data sent through GlobalCable.sendData(); register it in the node constructor or prepare callback.
    For an external C++ node with global cables that is nested in another network which is then compiled, add IsFixRuntimeTarget to that node's node_properties.json entry and declare a second unused template parameter defaulting to runtime_target::indexers::none. This preserves the global-cable connection through the nested compiled network.

  See also:
    [disambiguation] routing.local_cable -- network-scoped cable for single-network use
    [api] GlobalCable -- HiseScript API for creating and connecting global cables
---

Routes a normalised control value between any number of nodes across all DspNetworks via a shared named connection. Each global_cable node acts as both sender and receiver -- setting the Value parameter broadcasts it to every other global_cable sharing the same Connection ID, and incoming values from peers appear on the modulation output. A built-in recursion guard prevents feedback loops.

Cable IDs starting with `/` integrate with OSC. When an OSC receiver is active, incoming OSC messages are normalised to 0..1 using the configured input range. When an OSC sender is active, outgoing values are denormalised using the configured output range.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Value:
      desc: "Control value sent through the cable"
      range: "0.0 - 1.0"
      default: "1.0"
  functions:
    broadcastToPeers:
      desc: "Sends the value to all other global_cable nodes on the same Connection"
---

```
// routing.global_cable - bidirectional control value router
// control in -> broadcast -> modulation out (on peers)

onValueChange(Value) {
    broadcastToPeers(Value)  // all peers on same Connection
    // each peer forwards to its modulation output
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Signal
    params:
      - { name: Value, desc: "Control value to send or receive. Clamped to 0..1 by the cable system.", range: "0.0 - 1.0", default: "1.0" }
---
::

### External C++ Integration

External C++ nodes can use global cables to exchange scalar values or arbitrary data with HISE. This is useful for exposing internal state such as gain reduction, metering, or analysis data to the UI.

First choose **Tools -> Create C++ code for global cables** in the network editor. HISE collects the current cable IDs and generates an enum plus a `routing::global_cable_cpp_manager` specialization with the required cable hashes:

```cpp
enum class GlobalCables
{
    Funky_cable = 0,
    Another_funky_cable = 1
};

using cable_manager_t = routing::global_cable_cpp_manager<
    SN_GLOBAL_CABLE(623777931),
    SN_GLOBAL_CABLE(1331638607)>;
```

Place the generated declarations before the node and inherit the manager alongside the node's other base classes:

```cpp
template <int NV> struct cpp_cable_test : public data::base,
                                          public cable_manager_t
{
    // Node implementation
};
```

#### Nested compiled C++ nodes

If an external C++ node using global cables is placed in a network that is itself compiled and then loaded into another compiled network, add `IsFixRuntimeTarget` to that node's entry in `node_properties.json`. This makes the generated code forward the global-cable connection to the nested node. The node class must also accept the generated, otherwise unused, second template argument: [1]($FORUM_REF.12543$)

```json
{
  "internal_cpp_node": [
    "IsPolyphonic",
    "IsFixRuntimeTarget",
    "AllowPolyphonic"
  ]
}
```

```cpp
template <int NV, typename UnusedHash = runtime_target::indexers::none>
struct internal_cpp_node : public data::base,
                           public cable_manager_t
{
    // Node implementation
};
```

Use `setGlobalCableValue` for a scalar value:

```cpp
this->setGlobalCableValue<GlobalCables::Funky_cable>(value);
```

`setGlobalCableValue` is realtime safe and may be called from processing code. Connected listeners execute their callbacks synchronously, however, so avoid sending an unchanged value for every sample. Sending once per block where possible reduces redundant listener work.

Use `sendDataToGlobalCable` for serialized `juce::var` payloads:

```cpp
juce::var text("someString");
juce::var buffer(new VariantBuffer(512));
juce::var object(JSON::fromString("{\"value\": 1234}"));

this->sendDataToGlobalCable<GlobalCables::Funky_cable>(text);
this->sendDataToGlobalCable<GlobalCables::Funky_cable>(buffer);
this->sendDataToGlobalCable<GlobalCables::Another_funky_cable>(object);
```

This data path serializes and dispatches the `juce::var` payload and is **not realtime safe**. Reserve it for non-realtime, heavier payloads such as analysis buffers or UI data; use `setGlobalCableValue` for realtime scalar control.

To receive `juce::var` data sent from HiseScript with `GlobalCable.sendData()`, register a callback in the node constructor or `prepare` callback:

```cpp
this->registerDataCallback<GlobalCables::Funky_cable>([](const var& data)
{
    if (auto buffer = data.getBuffer())
    {
        // Consume buffer data outside the realtime scalar path.
    }

    if (data.isString())
    {
        auto text = data.toString();
    }
});
```

**See also:** $SN.routing.local_cable$ -- network-scoped cable for connections within a single network, $API.GlobalCable$ -- HiseScript API for creating and connecting global cables
