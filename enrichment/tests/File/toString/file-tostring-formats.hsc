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
const var dir = FileSystem.getFolder(FileSystem.AudioFiles);
const var audioFile = dir.getChildFile("recording.wav");

// FullPath is machine-dependent, but other formats are deterministic
Console.print(audioFile.toString(audioFile.NoExtension));  // recording
Console.print(audioFile.toString(audioFile.Extension));     // .wav
Console.print(audioFile.toString(audioFile.Filename));      // recording.wav
// test
/compile

# Verify
/expect audioFile.toString(audioFile.NoExtension) is "recording"
/expect audioFile.toString(audioFile.Extension) is ".wav"
/expect audioFile.toString(audioFile.Filename) is "recording.wav"
/exit
// end test
