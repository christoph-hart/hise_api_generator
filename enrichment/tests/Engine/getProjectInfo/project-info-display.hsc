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
// Title: Displaying project info in the console
var info = Engine.getProjectInfo();
Console.print(info.ProjectName + " v" + info.ProjectVersion);
Console.print("Built with HISE " + info.HISEBuild);
// test
/compile

# Verify
/expect typeof info.ProjectName is "string"
/expect info.ProjectName.length > 0 is true
/expect typeof info.HISEBuild is "string"
/expect info.HISEBuild.length > 0 is true
/exit
// end test
