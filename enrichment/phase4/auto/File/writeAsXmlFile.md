Converts a JSON object to XML and writes it to this file. The `tagName` parameter becomes the root XML element name. This is the inverse of `loadFromXmlFile`. Returns `true` on success.

> [!Warning:$WARNING_TO_BE_REPLACED$] Not all JSON structures survive a `writeAsXmlFile` / `loadFromXmlFile` round-trip identically. Arrays of mixed types or deeply nested structures may be represented differently after the round-trip. Test with your specific data shape before relying on this for complex structures.
