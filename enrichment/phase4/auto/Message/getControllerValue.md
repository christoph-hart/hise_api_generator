Returns the value of the current controller-type event. The return range depends on the event type: standard CCs and aftertouch return 0-127, while pitch bend returns the full 14-bit range 0-16383.

> [!Warning:$WARNING_TO_BE_REPLACED$] The value range is not uniform across event types. Code that normalises by dividing by 127.0 will produce values greater than 1.0 for pitch wheel messages. Check `Message.getControllerNumber()` first to handle pitch bend's wider range.
