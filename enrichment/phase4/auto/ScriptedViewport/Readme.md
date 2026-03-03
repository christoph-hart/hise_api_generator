# ScriptedViewport

<!-- Diagram triage:
  - viewport-modes (state): CUT - mode table in prose is clearer than state diagram
  - table-setup (sequence): RENDER - mandatory init sequence not obvious from API alone
-->

ScriptedViewport is a UI component created with `Content.addViewport(name, x, y)` that operates in one of three modes:

| Mode | How to activate | Value |
|------|----------------|-------|
| Viewport | Default (no flags) | Scroll position |
| List | Set `useList` property to `true` | Selected index |
| Table | Call `setTableMode()` in onInit | `[column, row]` array |

In table mode, you define columns with `setTableColumns()`, populate rows with `setTableRowData()`, and receive interactions through `setTableCallback()`. The table supports six cell types: Text, Button, Slider, ComboBox, Image, and Hidden. Interactive cells fire specialized callbacks with event type strings (Click, DoubleClick, Selection, ReturnKey, SpaceKey, DeleteRow, Slider, Button, ComboBox).

![Table Mode Setup Sequence](sequence_table-setup.svg)

All table setup methods must be called during `onInit`. Only `setTableRowData()` can update content after init completes. The remaining methods are common to all UI components.

## Common Mistakes

- **Wrong:** `Viewport1.setTableMode({});` called outside onInit
  **Right:** `// In onInit:\nViewport1.setTableMode({});`
  *setTableMode, setTableColumns, and setTableCallback must be called in onInit only.*

- **Wrong:** `Viewport1.setTableColumns([...]);` without calling setTableMode first
  **Right:** `Viewport1.setTableMode({});\nViewport1.setTableColumns([...]);`
  *setTableColumns requires setTableMode to be called first to create the internal table model.*

- **Wrong:** Using `obj.rowIndex` directly to index into the data array when sorting is enabled
  **Right:** Using `viewport.getOriginalRowIndex(obj.rowIndex)` to map back to the original data index
  *When the table is sorted, display indices no longer match the original array positions. Mutations (favorites, deletion) applied to the wrong index corrupt data silently.*

- **Wrong:** Setting `viewPositionY` to a pixel value
  **Right:** Setting `viewPositionY` to a normalized 0.0-1.0 value
  *The scroll position properties are normalized, not pixel-based. Use `(targetRow + 1) / totalRows` to scroll to a specific row.*
