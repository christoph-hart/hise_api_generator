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
const var storage = Engine.createThreadSafeStorage();
storage.store([1, 2, 3]);

// tryLoad returns stored data when no write is in progress
var result = storage.tryLoad([]);
Console.print("Length: " + result.length); // Length: 3
// test
/compile

# Verify
/expect result.length is 3
/expect result[0] is 1
/exit
// end test
