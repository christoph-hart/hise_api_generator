Sets a CSS variable on this component that can be queried from a stylesheet. The `type` parameter controls how the value is converted to a CSS string:

| Type | Conversion |
|------|------------|
| `"color"` | Integer colour to `#AARRGGBB` |
| `"%"` | Number to percentage (0.5 becomes `"50%"`) |
| `"px"` | Number to pixel value |
| `"em"` | Number to em value |
| `"deg"` | Number to degree value |
| `"path"` | Path object to base64 string |
| `""` | No conversion (stored as-is) |
