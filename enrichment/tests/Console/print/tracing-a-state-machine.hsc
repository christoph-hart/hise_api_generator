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
// Title: Tracing a state machine during development
// Context: Console.print calls left in production code serve as
// built-in documentation of control flow. They are no-ops in
// exported plugins, so there is no reason to remove them.

reg progress = 0.65;

inline function onExportStateChanged(newState)
{
    local NAMES = ["Idle", "Preparing", "Bouncing", "Writing", "Done"];
    Console.print("New export state: " + NAMES[newState]);

    if (newState == 2)
        Console.print("Bouncing... " + parseInt(progress * 100) + "%");

    if (newState == 4)
        Console.print("Export complete");
}

onExportStateChanged(2);
// test
/compile

# Verify
/expect-logs ["New export state: Bouncing", "Bouncing... 65%"]
/exit
// end test
