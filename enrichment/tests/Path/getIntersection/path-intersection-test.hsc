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
const var p = Content.createPath();
p.addEllipse([0, 0, 100, 100]);

var intersection = p.getIntersection([0, 50], [100, 50], false);

if (intersection)
    Console.print("Hit at: " + intersection[0] + ", " + intersection[1]);
else
    Console.print("No intersection");
// test
/compile

# Verify
/expect intersection !== false is true
/expect intersection.length is 2
/exit
// end test
