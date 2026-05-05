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
const var pointFactory = Engine.createFixObjectFactory({
    "x": 0.0,
    "y": 0.0,
    "active": false
});

var point = pointFactory.create();
point.x = 1.5;
point.y = 2.5;
point.active = true;

Console.print(point.x); // 1.5
// test
/compile

# Verify
/expect point.x is 1.5
/expect point.active is true
/exit
// end test
