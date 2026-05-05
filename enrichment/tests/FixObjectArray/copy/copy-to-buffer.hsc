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
// Title: Extract a property column into a Buffer
const var f = Engine.createFixObjectFactory({
    "id": 0,
    "velocity": 0.0
});

const var a = f.createArray(4);

a[0].velocity = 0.25;
a[1].velocity = 0.5;
a[2].velocity = 0.75;
a[3].velocity = 1.0;

const var buf = Buffer.create(4);
a.copy("velocity", buf);

Console.print(buf[2]); // 0.75
// test
/compile

# Verify
/expect buf[0] is 0.25
/expect buf[2] is 0.75
/exit
// end test
