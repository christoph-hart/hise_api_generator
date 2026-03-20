ScriptLabel (object)
Obtain via: Content.addLabel(name, x, y)

Editable text label component for displaying and editing interface text.
Stores its value as a string in the text property, with wrapper-managed font, alignment, and editability.
Participates in the Content lifecycle, so some configuration is onInit-only.

Complexity tiers:
  1. Static display: set("text", ...), set("fontName", ...), set("alignment", ...). Layout-only labels.
  2. Editable input: + setEditable() in onInit, setControlCallback(). React to user edits.
  3. Live search field: + set("updateEachKey", true), changed(). Per-key callbacks and programmatic clears.

Practical defaults:
  - Use set("updateEachKey", true) only for live-search or incremental filtering to avoid extra callbacks.
  - Use set("saveInPreset", false) for transient UI inputs like search fields; keep true only for persistent text.
  - Use set("alignment", "left") for editable text fields.

Common mistakes:
  - Calling setEditable() after onInit -- reports a script error and does nothing.
  - Passing non-string values to setValue() -- non-string values are ignored.
  - Updating text programmatically without changed() -- onControl does not fire.

Example:
  const var lb = Content.addLabel("Title", 10, 10);
  lb.setEditable(true);

Methods (29):
  addToMacroControl         changed                    fadeComponent
  get                        getAllProperties          getChildComponents
  getGlobalPositionX         getGlobalPositionY        getHeight
  getId                      getLocalBounds            getValue
  getWidth                   grabFocus                 loseFocus
  sendRepaintMessage         set                       setConsumedKeyPresses
  setControlCallback         setEditable               setKeyPressCallback
  setLocalLookAndFeel        setPosition               setStyleSheetClass
  setStyleSheetProperty      setStyleSheetPseudoState  setTooltip
  setZLevel                  showControl
