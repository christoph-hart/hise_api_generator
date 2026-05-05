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
// Context: isOnline() blocks for up to 20 seconds when offline, so use it
// sparingly -- only when you need a definitive answer to show the user
// a meaningful "no internet" message before attempting an operation.

Server.setBaseURL("https://forum.hise.audio");

reg connectivityResult = "unknown";

inline function syncWithServer()
{
    if (!Server.isOnline())
    {
        connectivityResult = "offline";
        Console.print("No internet connection - please check your network");
        return;
    }

    connectivityResult = "online";

    Server.callWithGET("api/recent", {}, function(status, response)
    {
        if (status == Server.StatusOK)
            Console.print("Sync complete");
    });
};

syncWithServer();
// test
/compile

# Verify
/wait 1000ms
/expect connectivityResult is "online"
/exit
// end test
