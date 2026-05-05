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
    "id": 0,
    "velocity": 0.0
});

const var a = f.createArray(4);

a[0].id = 3;
a[1].id = 1;
a[2].id = 4;
a[3].id = 2;

f.setCompareFunction("id");
a.sort();

Console.print(a[0].id); // 1
Console.print(a[3].id); // 4
// test
/compile

# Verify
/expect a[0].id is 1
/expect a[1].id is 2
/expect a[2].id is 3
/expect a[3].id is 4
/exit
// end test
