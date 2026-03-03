## assertEqual

**Examples:**

```javascript
// Title: Validating preprocessor definitions at init time
// Context: Before an activation system runs, verify that the project's
// preprocessor settings are correctly configured. assertEqual gives a
// clear error message showing expected vs actual values.

inline function checkPreprocessorSettings()
{
    if (Engine.isHISE())
    {
        local def = Engine.getExtraDefinitionsInBackend();

        Console.assertEqual(def.USE_COPY_PROTECTION, 1);
        Console.assertEqual(def.USE_SCRIPT_COPY_PROTECTION, 1);
        Console.assertEqual(def.HISE_DEACTIVATE_OVERLAY, 1);
    }
}

checkPreprocessorSettings();
```

```javascript
// Title: Verifying data array dimensions
// Context: When a multi-dimensional data structure must have consistent
// sizes, assertEqual catches mismatches before they cause index errors.

const var NUM_CHANNELS = 4;
const var NUM_MODES = 3;
const var NUM_BANKS = 2;

Console.assertEqual(NUM_BANKS * NUM_CHANNELS * NUM_MODES, dataPackList.length);
```

```javascript
// Title: Unit-testing a string transformation function
// Context: assertEqual works well for inline unit tests that run
// during init and are stripped in exported builds.

Console.assertEqual(transformName("Drive A1", 0, 3), "Drive All1");
Console.assertEqual(transformName("Drive All9", 3, 0), "Drive A9");
Console.assertEqual(transformName("Mixer 2 Pan1", 1, 3), "Mixer 2 Pan All");
```
