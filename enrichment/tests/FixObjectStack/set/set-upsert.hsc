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
const var f = Engine.createFixObjectFactory({
    "note": 0,
    "velocity": 0.0
});

f.setCompareFunction("note");
const var s = f.createStack(8);
const var obj = f.create();

// Insert new entry
obj.note = 60;
obj.velocity = 0.8;
s.set(obj);

// Update existing entry (same note, different velocity)
obj.velocity = 0.5;
s.set(obj);

Console.print(s.size());       // 1 (replaced, not added)
Console.print(s[0].velocity);  // 0.5 (updated)
// test
/compile

# Verify
/expect s.size() is 1
/expect s[0].velocity is 0.5
/exit
// end test
