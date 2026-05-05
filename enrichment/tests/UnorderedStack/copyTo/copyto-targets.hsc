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
const var us = Engine.createUnorderedStack();
us.insert(1.0);
us.insert(2.0);
us.insert(3.0);

// Copy to Array
var arr = [];
us.copyTo(arr);
Console.print(arr.length); // 3

// Copy to Buffer (must be strictly larger than stack size)
const var bf = Buffer.create(4);
us.copyTo(bf);
Console.print(bf[0]); // 1.0
// test
/compile

# Verify
/expect arr.length is 3
/expect arr[0] is 1.0
/expect bf[0] is 1.0
/exit
// end test
