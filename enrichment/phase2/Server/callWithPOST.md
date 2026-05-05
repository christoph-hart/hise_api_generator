## callWithPOST

**Examples:**


```javascript:post-crash-report
// Title: Submit a crash report with device information
// Context: A common pattern for collecting anonymous device information
// via POST. The response callback handles multiple status categories
// to provide appropriate user feedback.

Server.setBaseURL("https://api.example.com");

const var projectInfo = Engine.getProjectInfo();

inline function submitCrashReport(errorMessage)
{
    local parameters = {
        "product": projectInfo.ProjectName,
        "version": projectInfo.ProjectVersion,
        "os": Engine.getOS(),
        "message": errorMessage
    };

    Server.callWithPOST("reports/crash", parameters, function(status, response)
    {
        if (status == Server.StatusNoConnection)
            Console.print("No internet connection");
        else if (status == Server.StatusOK)
            Console.print("Report submitted");
        else
            Console.print("Server error: " + status);
    });
};
```
```json:testMetadata:post-crash-report
{
  "testable": false,
  "skipReason": "requires-live-server (example.com endpoint does not exist)"
}
```

**Pitfalls:**
- When handling server responses, always check `status == 0` separately from other error codes. Status 0 means no response was received at all (timeout or no internet), while codes like 403, 404, or 500 are actual server responses with potentially useful error messages in the response body. Conflating the two leads to misleading error messages for the user.
