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
// Title: Insert with duplicate detection
const var f = Engine.createFixObjectFactory({
    "note": 0,
    "velocity": 0.0
});

f.setCompareFunction("note");
const var s = f.createStack(8);
const var obj = f.create();

obj.note = 60;
obj.velocity = 0.8;
var result1 = s.insert(obj);

// Same note value -- rejected as duplicate
obj.velocity = 0.5;
var result2 = s.insert(obj);

Console.print(result1); // 1 (true -- inserted)
Console.print(result2); // 0 (false -- duplicate note=60)
Console.print(s.size()); // 1
// test
/compile

# Verify
/expect result1 is 1
/expect result2 is 0
/expect s.size() is 1
/expect s[0].velocity is 0.8
/exit
// end test
