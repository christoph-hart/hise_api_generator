## assertNoString

**Examples:**

```javascript
// Title: Catching accidental string values in data arrays
// Context: When iterating a data array where a property must be a
// non-string type (e.g., an icon path object, a number), assertNoString
// catches data corruption from incorrect serialization or manual edits.

for (entry in mixerData)
{
    if (!isDefined(iconLookup[entry.Icon]))
    {
        // If the icon lookup fails, the Name field may have been
        // corrupted to a string when it should be a path object
        Console.assertNoString(entry.Name);
    }
}
```

**Pitfalls:**
- The error message on failure is the string value itself (e.g., `"Assertion failure: hello"`). This can be confusing if the string content resembles a different error. Use `assertWithMessage` if you need a clearer failure message for string-type checks.
