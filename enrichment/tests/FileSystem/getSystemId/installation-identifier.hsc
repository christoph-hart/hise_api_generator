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
// Context: getSystemId() returns a deterministic hex string derived from
// hardware characteristics. It identifies a specific machine without
// exposing personal information, making it suitable for anonymous
// crash reports or usage analytics.

reg machineId = FileSystem.getSystemId();

Console.print("Machine ID: " + machineId);
Console.print("ID length: " + machineId.length);

// Include the machine ID in a crash report payload
inline function buildCrashReport(errorMessage)
{
    return {
        "machine_id": FileSystem.getSystemId(),
        "product": Engine.getProjectInfo().ProjectName,
        "version": Engine.getProjectInfo().ProjectVersion,
        "os": Engine.getOS(),
        "message": errorMessage
    };
};

// Verify determinism: calling it twice returns the same value
Console.print("Stable: " + (FileSystem.getSystemId() == machineId));
// test
/compile

# Verify
/expect machineId.length > 0 is true
/expect FileSystem.getSystemId() == machineId is true
/exit
// end test
