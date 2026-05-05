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
// Context: Demonstrates the standard callWithPOST pattern with proper
// multi-status error handling. The forum API rejects unauthenticated
// POST requests with a 403, which exercises the error path.

Server.setBaseURL("https://forum.hise.audio");

reg postResult = "pending";

Server.callWithPOST("api/v3/topics", {"title": "test"}, function(status, response)
{
    if (status == Server.StatusOK)
        postResult = "success";
    else if (status == Server.StatusAuthenticationFail)
        postResult = "auth-required";
    else if (status == Server.StatusNoConnection)
        postResult = "no-connection";
    else
        postResult = "error-" + status;
});
// test
/compile

# Verify
/wait 1000ms
/expect postResult is "auth-required"
/exit
// end test
