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
// Title: Validating callback state
// Context: Before invoking a stored callback reference, confirm it was
// actually assigned. A missing callback is a programming error, not
// a valid state.

var currentOKCallback;

inline function showConfirmDialog(message, okCallback)
{
    currentOKCallback = okCallback;
    // ... show dialog
}

inline function onDialogOK()
{
    Console.assertIsDefined(currentOKCallback);
    currentOKCallback();
}

// Set up a callback and invoke it
showConfirmDialog("Test", function() {
    Console.print("Callback executed");
});

onDialogOK();
// test
/compile

# Verify
/expect-logs ["Callback executed"]
/exit
// end test
