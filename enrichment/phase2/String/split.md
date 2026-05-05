## split

**Examples:**


```javascript:parse-text-file-lines
// Title: Parse a text file into lines for data import
// Context: Loading a legacy data file as a string, then splitting
// on newlines to process each line individually.

const var f = FileSystem.getFolder(FileSystem.Documents).getChildFile("data.txt");
var lines = f.loadAsString().split("\n");

for (line in lines)
{
    local values = line.split(",");
    // Process each comma-separated value...
}
```
```json:testMetadata:parse-text-file-lines
{
  "testable": false,
  "skipReason": "Requires an external data.txt file in the Documents folder"
}
```

**Pitfalls:**
- Only the first character of the separator is used. `"a::b::c".split("::")` splits on `":"`, producing `["a", "", "b", "", "c"]` instead of the expected `["a", "b", "c"]`. Use a single-character delimiter.
