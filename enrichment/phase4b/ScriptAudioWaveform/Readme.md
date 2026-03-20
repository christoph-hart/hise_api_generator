ScriptAudioWaveform (object)
Obtain via: Content.addAudioWaveform(name, x, y)

Audio waveform display component for visualizing AudioFile data with interactive
range selection. Operates in two modes: AudioFile mode (file browsing, drag-and-drop,
range selection) or Sampler mode (auto-tracks playing voice, shows play/loop/crossfade
areas) depending on the connected processor type.

Complexity tiers:
  1. Basic display: set processorId, optionally configure enableRange, showFileName,
     opaque. No custom LAF needed.
  2. Channel-switching display: + dynamic processorId reassignment at runtime,
     colour updates via set(), setPlaybackPosition(0) to reset cursor.
  3. Fully custom rendering: + LAF draw functions (drawThumbnailBackground,
     drawThumbnailPath, drawThumbnailRuler, drawThumbnailRange, drawThumbnailText,
     getThumbnailRenderOptions). Use getRangeEnd() for overlay positioning.

Practical defaults:
  - Set opaque to false and bgColour to 0 (transparent) when layering the waveform
    over a custom-painted ScriptPanel background.
  - Set enableRange to false for display-only waveforms where user range selection
    is not needed.
  - Set showFileName to false when using a custom LAF that handles text display.
  - Use getThumbnailRenderOptions to set forceSymmetry to true for one-shot drum
    samples where a symmetric waveform looks cleaner.
  - Use getThumbnailRenderOptions to set scaleVertically to true for IR displays
    where the absolute amplitude is less important than the shape.

Common mistakes:
  - Passing a string path to setDefaultFolder() instead of a File object --
    causes a script error. Use FileSystem.getFolder() to obtain a File object.
  - Calling set("processorId", newId) without resetting the playback cursor --
    cursor is stale from the previous audio file. Follow with setPlaybackPosition(0).
  - Polling for audio file changes with a Timer instead of using
    Broadcaster.attachToComplexData("AudioFile.Content", ...) -- unnecessary
    overhead and latency.
  - Setting only itemColour when changing channel colour -- must set both
    itemColour (outline) and itemColour2 (fill) to avoid a mismatched look.

Example:
  const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
  wf.set("width", 400);
  wf.set("height", 150);

Methods (39):
  addToMacroControl          changed
  fadeComponent              get
  getAllProperties            getChildComponents
  getGlobalPositionX         getGlobalPositionY
  getHeight                  getId
  getLocalBounds             getRangeEnd
  getRangeStart              getValue
  getValueNormalized         getWidth
  grabFocus                  loseFocus
  referToData                registerAtParent
  sendRepaintMessage         set
  setControlCallback         setConsumedKeyPresses
  setDefaultFolder           setKeyPressCallback
  setLocalLookAndFeel        setPlaybackPosition
  setPosition                setStyleSheetClass
  setStyleSheetProperty      setStyleSheetPseudoState
  setTooltip                 setValue
  setValueNormalized         setValueWithUndo
  setZLevel                  showControl
  updateValueFromProcessorConnection
