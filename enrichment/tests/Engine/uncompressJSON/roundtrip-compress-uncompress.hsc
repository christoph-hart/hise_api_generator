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
// Title: Roundtrip compress and uncompress a JSON object
var original = {"key": "value", "number": 42};
var compressed = Engine.compressJSON(original);
Console.print(typeof compressed); // "string"

var restored = Engine.uncompressJSON(compressed);
Console.print(restored.key);    // "value"
Console.print(restored.number); // 42
// test
/compile

# Verify
/expect restored.key is "value"
/expect restored.number is 42
/exit
// end test
