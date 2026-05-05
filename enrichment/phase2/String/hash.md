## hash

**Examples:**

```javascript:skip-redundant-loading
// Title: Skip redundant file loading by comparing state hashes
// Context: When multiple controls determine which audio file to load,
// concatenate their values into a string and hash it. Compare with
// the previous hash to avoid reloading when nothing changed.

const var Controls = [Content.getComponent("TypeSelector"),
                      Content.getComponent("VariantSelector"),
                      Content.getComponent("MicSelector")];

reg lastHash = 0;

inline function getSelectionHash()
{
    local s = "";
    
    for (c in Controls)
        s += c.getValue() + "_";
    
    return s.hash();
}

inline function loadIfChanged()
{
    local thisHash = getSelectionHash();
    
    if (thisHash == lastHash)
        return; // Nothing changed, skip the expensive load
    
    lastHash = thisHash;
    // ... load the audio file based on current selections
}
```
```json:testMetadata:skip-redundant-loading
{
  "testable": false,
  "skipReason": "Requires TypeSelector, VariantSelector, and MicSelector UI components"
}
```


