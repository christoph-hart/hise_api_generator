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
// Title: Error function with severity routing
const var eh = Engine.createExpansionHandler();

inline function onExpansionError(message, isCritical)
{
    if (isCritical)
        Console.print("CRITICAL: " + message);
    else
        Console.print("Info: " + message);
};

eh.setErrorFunction(onExpansionError);
// test
eh.setErrorMessage("test warning");
/compile

# Verify
/expect-logs ["Info: test warning"]
/exit
// end test
