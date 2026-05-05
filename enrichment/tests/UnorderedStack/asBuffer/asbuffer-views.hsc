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
// Title: Active elements vs full backing array
const var us = Engine.createUnorderedStack();
us.insert(10.0);
us.insert(20.0);
us.insert(30.0);

// Only occupied elements (size = 3)
const var active = us.asBuffer(false);
Console.print(active.length); // 3

// All 128 backing slots
const var all = us.asBuffer(true);
Console.print(all.length); // 128
// test
/compile

# Verify
/expect active.length is 3
/expect all.length is 128
/expect active[0] is 10.0
/exit
// end test
