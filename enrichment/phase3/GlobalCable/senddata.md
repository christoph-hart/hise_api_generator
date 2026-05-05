This function can be used to send any kind of arbitrary data to the global cable targets. This can be used for safe communication between different scripts and even external C++ nodes. In order to use this method, just call it with any kind of data and it will be send to all targets that are registered to this cable.

```javascript:senddata-1
const var rm = Engine.getGlobalRoutingManager();
const var c = rm.getCable("myDataCable");
c.sendData({ someJson: 1234, also: "strings are supported" });
c.sendData([ 1, 2, 3, 4, 5, 6]);
c.sendData(Buffer.create(128));
```
```json:testMetadata:senddata-1
{
  "testable": false,
  "skipReason": "Fire-and-forget calls with no registered callbacks produce no observable output"
}
```

Note that there is not a data queue for the sender side of this protocol, which means that if you register a target after the data has been sent, it will not be "initialised" with the previously sent value. However if you're using the C++ API in your external node, it will queue the data that is about to be sent if the cable is not connected yet.

Also it will skip its own callbacks, so if you register a callback using [Global Cable.registerDataCallback()](/scripting/scripting-api/globalcable#registerdatacallback), it will not be executed:


As you can see if you send a value through the first cable object it will skip the C1 callback and vice versa. This behaviour is also the same on the C++ side.
