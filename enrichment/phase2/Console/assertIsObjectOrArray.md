## assertIsObjectOrArray

**Examples:**

```javascript
// Title: Validating module references before method calls
// Context: When looking up modules by ID, the result may be undefined
// if the ID is wrong. assertIsObjectOrArray catches this before
// methods like setAttribute or getId are called on a non-object.

inline function connectModulator(sourceIndex, destinationIndex)
{
    local sourceMod = getSourceModulator(sourceIndex);
    local targetModule = getDestinationModule(destinationIndex);

    Console.assertIsObjectOrArray(sourceMod);
    Console.assertIsObjectOrArray(targetModule);

    local newMod = targetModule.addGlobalModulator(0, sourceMod, "Mod_" + sourceIndex);
    Console.assertIsObjectOrArray(newMod);
}
```

```javascript
// Title: Function parameter validation
// Context: Utility functions that expect a module reference or
// structured data object use assertIsObjectOrArray as a type guard.

inline function initVuMeter(panel, module)
{
    Console.assertIsObjectOrArray(module);

    panel.setTimerAndPaintRoutine(40, function(g)
    {
        // module is guaranteed to be a valid object here
        local level = module.getCurrentLevel(0);
        // ... draw meter
    });
}
```
