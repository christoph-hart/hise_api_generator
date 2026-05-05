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
// Title: Unreachable code marker
const DATA_LIST = [{Key: 'A', Name: 'Alpha'}, {Key: 'B', Name: 'Beta'}];

inline function findNameByKey(key)
{
    for (entry in DATA_LIST)
        if (entry.Key == key)
            return entry.Name;

    // If we get here, the key was not in DATA_LIST - a programming error
    Console.assertTrue(false);
    return "";
}

// Invoke with invalid key to trigger assertion
const result = findNameByKey('Z');
// test
/expect-compile throws "Assertion failure: condition is false"
/exit
// end test
