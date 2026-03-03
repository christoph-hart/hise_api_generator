## assertIsDefined

**Examples:**

```javascript
// Title: Guarding Builder API module creation
// Context: After creating modules with the Builder API, assertIsDefined
// catches failures immediately rather than letting undefined propagate
// through subsequent setAttribute calls.

const var builder = Synth.createBuilder();

inline function buildOscillator(index)
{
    local target = {};

    target["Gain"]   = builder.create("SynthGroup", "OSC" + index, 0, -1);
    target["Filter"] = builder.create("PolyphonicFilter", "OSC" + index + "_Filter", target["Gain"], builder.ChainIndexes.FX);

    for (key in target)
    {
        Console.assertIsDefined(target[key]);
    }

    builder.flush();
}
```

```javascript
// Title: Validating object properties before use
// Context: When reading structured data from JSON or configuration objects,
// assertIsDefined confirms that expected properties exist.

inline function loadActivationConfig()
{
    local keyFile = FileSystem.getFolder(FileSystem.AudioFiles)
                    .getParentDirectory()
                    .getChildFile("RSA.xml");

    local obj = keyFile.loadFromXmlFile();

    Console.assertIsDefined(obj.PublicKey);
    Console.assertIsDefined(obj.PrivateKey);
}
```

```javascript
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
```
