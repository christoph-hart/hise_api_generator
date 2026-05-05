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
var data = {"name": "MyPreset", "values": [1, 2, 3]};
var compressed = Engine.compressJSON(data);
var restored = Engine.uncompressJSON(compressed);
Console.print(restored.name);
// test
/compile

# Verify
/expect typeof compressed is "string"
/expect restored.name is "MyPreset"
/expect restored.values[2] is 3
/exit
// end test
