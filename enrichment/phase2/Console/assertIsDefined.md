## assertIsDefined

**Examples:**


```javascript:validating-object-properties-before
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
```json:testMetadata:validating-object-properties-before
{
  "testable": false
}
```


