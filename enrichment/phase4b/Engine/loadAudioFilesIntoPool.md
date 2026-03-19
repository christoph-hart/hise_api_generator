Engine::loadAudioFilesIntoPool() -> Array

Thread safety: UNSAFE -- file I/O (bulk load in backend), heap allocations
Ensures all audio files are loaded into the pool and returns reference string list.
Backend: loads all files from AudioFiles folder. Both: returns pool reference list.
Call in onInit for compiled plugins to ensure audio file references are available.
Source:
  ScriptingApi.cpp  Engine::loadAudioFilesIntoPool()
    -> [backend] pool->loadAllFilesFromProjectFolder()
    -> returns pool reference list
