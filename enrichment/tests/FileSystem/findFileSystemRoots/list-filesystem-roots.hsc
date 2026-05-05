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
var roots = FileSystem.findFileSystemRoots();

for (r in roots)
    Console.print(r.toString(r.FullPath));

Console.print("Found " + roots.length + " root(s)");
// test
/compile

# Verify
/expect roots.length > 0 is true
/exit
// end test
