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
// Context: User presets store a version string. On load, split it
// into components to decide whether migration is needed.

inline function needsMigration(version)
{
    local v = version.split(".");
    
    // Check if major version is 1 and minor is less than 2
    if (parseInt(v[0]) == 1 && parseInt(v[1]) < 2)
        return true;
    
    return false;
}

Console.print(needsMigration("1.1.3")); // 1 (true)
Console.print(needsMigration("1.2.0")); // 0 (false)
// test
/compile

# Verify
/expect-logs ["1", "0"]
/exit
// end test
