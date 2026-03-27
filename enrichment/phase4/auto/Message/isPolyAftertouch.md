Returns whether the current event is a polyphonic aftertouch message. Use inside `onController` before calling `Message.getPolyAfterTouchNoteNumber()` and `Message.getPolyAfterTouchPressureValue()`.

> [!Warning:$WARNING_TO_BE_REPLACED$] Returns true for both polyphonic aftertouch and channel pressure events, since HISE uses the same internal event type for both. See `Message.isMonophonicAfterTouch()` for details on distinguishing them.
