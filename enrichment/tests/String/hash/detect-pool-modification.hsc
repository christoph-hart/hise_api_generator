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
// Context: Sum hashes of all items in a pool to detect changes
// without comparing every element individually.

var pool = ["Kick_01.wav", "Snare_02.wav", "HiHat_03.wav"];

inline function getPoolFingerprint(list)
{
    local sum = 0;
    
    for (n in list)
        sum += n.hash();
    
    return sum;
}

var before = getPoolFingerprint(pool);
pool.push("Clap_04.wav");
var after = getPoolFingerprint(pool);

Console.print(before == after); // 0 (false - pool changed)
// test
/compile

# Verify
/expect-logs ["0"]
/exit
// end test
