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

const var s = f.createStack(16);
const var obj = f.create();

obj.note = 60;
obj.velocity = 0.8;
s.insert(obj);
obj.note = 72;
obj.velocity = 0.6;
s.insert(obj);

// copy() reads all 16 slots -- use manual loop for used portion only
var velocities = [];
for (i = 0; i < s.size(); i++)
    velocities.push(s[i].velocity);

Console.print(velocities.length); // 2, not 16
// test
/compile

# Verify
/expect s.size() is 2
/expect velocities.length is 2
/expect velocities[0] is 0.8
/exit
// end test
