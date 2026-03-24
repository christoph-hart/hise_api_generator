# SVG Signal Flow Renderer

Prototype specification for generating publication-quality SVG block diagrams from the intermediate signal flow JSON format defined in `module-enrichment/intermediate-format.md`.

## Goal

Build a Node.js/TypeScript tool that reads an intermediate JSON file (nodes, edges, groups) and produces a styled SVG diagram suitable for first-class use on docs.hise.dev.

## Architecture

```
Intermediate JSON (e.g., Delay.json)
         |
    [1] Filter by complexity budget (importance threshold)
         |
    [2] Transform to ELK graph model (nodes with ports, edges, compound nodes)
         |
    [3] ELK layout computation (elkjs) -> positioned graph
         |
    [4] Custom SVG renderer -> final .svg file
```

### Why ELK + custom renderer

- **ELK (elkjs)**: Industry-standard layout engine from the Eclipse Foundation. Its `layered` algorithm is purpose-built for directed signal flow graphs with hierarchical grouping. Pure JS/WASM, runs in Node.js, no external binaries. npm package `elkjs` (~2MB).
- **Custom SVG renderer**: ELK computes positions; we render the SVG elements with HISE-specific styling (colors per node type, scope-based group borders, edge styles per connection type). This gives full control over the visual output.

Alternatives considered and rejected:
- **Mermaid.js**: Limited styling control, generic aesthetic, basic subgraph support. Good for quick docs, not for first-class visual content.
- **Graphviz**: Output looks "Graphviz-y", limited post-processing for custom aesthetics.
- **D2**: Better aesthetics than Mermaid but still limited compared to programmatic rendering.
- **Pure custom layout (no ELK)**: Would require implementing edge routing and compound node layout from scratch. ELK solves the hard problem for free.

## Directory Structure

```
tools/api generator/svg_renderer/
  package.json
  tsconfig.json
  src/
    types.ts              # IntermediateJSON types matching intermediate-format.md
    budget-filter.ts      # Importance-based node filtering
    elk-transform.ts      # Intermediate JSON -> ELK graph model
    svg-render.ts         # ELK positioned graph -> SVG string
    styles.ts             # Color palette, shapes, edge styles, fonts
    render.ts             # CLI entry point: reads JSON, writes SVG
  test-data/
    Delay.json            # Delay example from intermediate-format.md
    AHDSR.json            # AHDSR example (second test)
  output/                 # Generated SVGs (gitignored)
```

## Implementation Steps

### Step 1: Project setup

`package.json` with:
- `elkjs` - layout engine
- `tsx` (dev) - run TypeScript directly for prototyping
- `typescript` (dev)

`tsconfig.json`: ES2022, NodeNext module resolution, strict mode.

### Step 2: Types (`types.ts`)

Define TypeScript interfaces matching the intermediate format spec (`intermediate-format.md`):

```typescript
interface IntermediateJSON {
  moduleId: string;
  notes?: string;
  nodes: Node[];
  edges: Edge[];
  groups?: Group[];
}

interface Node {
  id: string;
  label: string;
  type: NodeType;
  detail?: string;
  scope: Scope;
  parameters?: string[];
  importance: number;
  condition?: Condition;
}

type NodeType = 'io' | 'external_input' | 'midi_event' | 'audio' | 'modulation'
  | 'filter' | 'gain' | 'waveshaper' | 'delay_line' | 'table'
  | 'parameter' | 'decision';

type Scope = 'shared_resource' | 'per_voice' | 'monophonic' | 'parameter';

interface Edge {
  from: string;
  to: string;
  type: EdgeType;
  label?: string;
}

type EdgeType = 'signal' | 'feedback' | 'bypass' | 'modulation' | 'sidechain';

interface Group {
  id: string;
  label: string;
  nodes: string[];
  style: 'polyphonic' | 'shared_region' | 'dashed_outline';
}
```

### Step 3: Budget filter (`budget-filter.ts`)

Filter nodes by importance before layout.

```
Input: IntermediateJSON + budget level ('thumbnail' | 'documentation' | 'overview')
Output: Filtered IntermediateJSON with sub-budget nodes removed
```

Budget thresholds:

| Level | Budget | Max nodes | Description |
|-------|--------|-----------|-------------|
| `overview` | 2-3 | ~4 | Input -> process -> output |
| `thumbnail` | 3-4 | ~6 | Essential flow only |
| `documentation` | 7-10 | all | Full detail |

Algorithm:
1. Sort nodes by importance descending
2. Accumulate importance until budget reached
3. Remove nodes below cutoff
4. Remove edges referencing removed nodes (unless reroutable)
5. Remove groups with no remaining visible members

### Step 4: ELK transform (`elk-transform.ts`)

Convert intermediate JSON to ELK's `ElkNode` model.

Key mappings:
- Groups become compound `ElkNode` with `children` arrays
- Ungrouped nodes become top-level children
- Edges become `ElkExtendedEdge` with source/target node IDs
- Node widths estimated from `label.length * charWidth + padding`
- Node heights fixed per type (taller for decision diamonds)

ELK layout options:
```typescript
{
  'elk.algorithm': 'layered',
  'elk.direction': 'RIGHT',
  'elk.spacing.nodeNode': '30',
  'elk.spacing.edgeNode': '20',
  'elk.layered.spacing.nodeNodeBetweenLayers': '60',
  'elk.hierarchyHandling': 'INCLUDE_CHILDREN',
  'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP'
}
```

Port handling:
- Each edge creates source and target ports on its nodes
- Ports are grouped by edge type (signal ports on right, modulation ports on top/bottom)
- This produces cleaner routing than connecting to node centers

Feedback edges:
- Tag feedback edges so ELK routes them as back-edges (characteristic curved-back loop)

### Step 5: SVG renderer (`svg-render.ts`)

Take ELK's positioned output and generate SVG elements.

**Rendering order** (z-index via draw order):
1. SVG document setup (viewBox, padding, defs)
2. Group backgrounds (colored rectangles with styled borders)
3. Edges (SVG `<path>` from ELK waypoints, with arrowhead markers)
4. Nodes (shapes with fills, strokes, and label text)

**Arrowhead markers** (in `<defs>`):
- `signal-arrow`: Solid triangle, matches edge color
- `modulation-arrow`: Smaller triangle, blue
- `feedback-arrow`: Open triangle

**Edge path generation**:
- Convert ELK bend points to SVG path `d` attribute
- Use cubic bezier curves for smooth routing
- Apply line style per edge type (solid, dashed, dotted)

**Node shape rendering**:
- Each node type maps to a shape function
- Shape functions return SVG element strings with proper positioning

### Step 6: CLI entry point (`render.ts`)

```bash
# Render single file at documentation budget
npx tsx src/render.ts test-data/Delay.json output/Delay.svg

# Render at thumbnail budget
npx tsx src/render.ts test-data/Delay.json output/Delay-thumb.svg --budget thumbnail

# Render all JSON files in a directory
npx tsx src/render.ts test-data/ output/
```

## Visual Design

### Dark-first design

docs.hise.dev uses a dark theme. The SVG is designed dark-first with automatic light mode support via CSS custom properties and `prefers-color-scheme`.

The SVG embeds a `<style>` block:

```css
:root {
  --bg: #1a1a1a;
  --text: rgba(255,255,255,0.9);
  --text-secondary: rgba(255,255,255,0.5);
  --border: #555;
  --group-bg: rgba(255,255,255,0.05);
  --group-border: rgba(255,255,255,0.15);
  --edge-signal: #bbb;
  --edge-feedback: #999;
  --edge-bypass: #777;
  --edge-modulation: #42A5F5;
  --edge-sidechain: #AB47BC;
}
@media (prefers-color-scheme: light) {
  :root {
    --bg: #ffffff;
    --text: #333;
    --text-secondary: rgba(0,0,0,0.45);
    --border: #ccc;
    --group-bg: rgba(0,0,0,0.04);
    --group-border: rgba(0,0,0,0.15);
    --edge-signal: #555;
    --edge-feedback: #888;
    --edge-bypass: #aaa;
    --edge-modulation: #1976D2;
    --edge-sidechain: #7B1FA2;
  }
}
```

### Node type color palette

Each node type has a fill (dark tinted background) and stroke (vivid border) optimized for dark backgrounds.

| Node Type | Fill (dark) | Stroke (dark) | Shape |
|-----------|-------------|---------------|-------|
| `io` | `#3a3a3a` | `#888` | Pill / stadium (rounded ends) |
| `audio` | `#1a3d2a` | `#4CAF50` | Rounded rectangle |
| `modulation` | `#1a2d4a` | `#42A5F5` | Rounded rectangle |
| `midi_event` | `#3d2a1a` | `#FF9800` | Rounded rectangle (distinct corner radius) |
| `filter` | `#1a3d3a` | `#26A69A` | Rounded rectangle |
| `gain` | `#1a3d2a` | `#66BB6A` | Rounded rectangle |
| `delay_line` | `#1a3a3d` | `#26C6DA` | Rounded rectangle |
| `waveshaper` | `#3d1a1a` | `#EF5350` | Rounded rectangle |
| `parameter` | `#2a2a2a` | `#9E9E9E` | Small rectangle (compact) |
| `table` | `#3d3a1a` | `#FFCA28` | Rectangle with wavy bottom |
| `decision` | `#3d2d1a` | `#FFA726` | Diamond |
| `external_input` | `#2a1a3d` | `#AB47BC` | Rectangle with dashed left border |

Light mode: fills invert to very light tinted versions of the stroke color; strokes darken slightly.

### Edge styles

| Edge Type | Color (dark) | Line Style | Width | Arrow |
|-----------|-------------|------------|-------|-------|
| `signal` | `#bbb` | Solid | 2px | Solid triangle |
| `feedback` | `#999` | Dashed (8,4) | 2px | Open triangle |
| `bypass` | `#777` | Dotted (4,4) | 1.5px | Solid triangle |
| `modulation` | `#42A5F5` | Solid | 1.5px | Small solid triangle |
| `sidechain` | `#AB47BC` | Dashed (6,3) | 1.5px | Solid triangle |

Edge labels rendered in small text (`--text-secondary`) positioned at the midpoint of the edge path.

### Group styles

| Style | Border | Background | Annotation |
|-------|--------|------------|------------|
| `polyphonic` | Double/stacked solid border (suggests multiplicity) | Subtle tinted fill | "x N voices" label |
| `shared_region` | Solid single border, slightly brighter | Distinct background tint | Label at top |
| `dashed_outline` | Dashed border | No fill or very subtle | Label at top |

### Typography

- Node labels: 13px, semi-bold, `--text` color
- Node detail text: 10px, regular, `--text-secondary` color (rendered below label when present)
- Edge labels: 10px, italic, `--text-secondary` color
- Group labels: 11px, uppercase, `--text-secondary` color
- Font family: system sans-serif stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`)

### Target dimensions

- Documentation page SVG: ~800px wide, height varies by graph complexity
- Thumbnail SVG: ~400px wide
- Padding: 20px around the diagram

## Prototype Validation

### Test 1: Delay

The Delay intermediate JSON from `intermediate-format.md` exercises:
- Linear signal path with branching (dry path bypass)
- Feedback loop (dashed edge curving back to an earlier node)
- A group (`dashed_outline` style around the feedback path)
- Conditional behavior (tempo sync on delay lines)
- Mix of node types: `io`, `delay_line`, `gain`, `filter`
- 7 nodes, 8 edges, 1 group

**Success criteria:**
- All 7 nodes visible in clear left-to-right flow
- Distinct shapes/colors for each node type
- Feedback loop rendered as a visually distinct curved-back dashed edge
- Dry path shown as a dotted bypass edge
- "Feedback Path" group drawn as dashed outline around 3 feedback nodes
- Clean edge routing, no overlapping edges
- Legible at 800px wide
- Looks professional on a dark background

### Test 2: AHDSR

The AHDSR intermediate JSON exercises:
- Two compound groups (`polyphonic` + `shared_region`)
- Many parameter nodes feeding into phase nodes (modulation edges)
- MIDI event triggers (note-on, note-off)
- Linear phase sequence (A -> H -> D -> S -> R) with parameter inputs from above
- 16 nodes, 16 edges, 2 groups

**Success criteria (additional to Test 1):**
- `polyphonic` group has stacked/doubled border suggesting multiplicity
- `shared_region` group has distinct background separating parameters from per-voice processing
- Parameter-to-phase modulation edges route cleanly without tangling
- The A-H-D-S-R sequence reads as a clear left-to-right flow within the per-voice group

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `elkjs` | latest | Graph layout computation |
| `typescript` | ^5.x | Type checking |
| `tsx` | latest | Run TypeScript directly (dev convenience) |

No other dependencies. SVG generation is string concatenation with XML escaping.

## Future Extensions

Once the prototype validates:

1. **Batch rendering**: Process all intermediate JSONs in a directory
2. **Multiple budgets**: Render each module at thumbnail + documentation budgets
3. **Integration with enrichment pipeline**: Called from the module enrichment orchestrator (see `doc_builders/module-enrichment.md`)
4. **Font metrics refinement**: Use actual font measurements for precise node sizing
5. **Interactive SVGs**: Optional hover tooltips showing parameter details (for the docs website)
6. **Accessibility**: `<title>` and `<desc>` elements derived from the signalFlow string

## Reference

- Intermediate format specification: `doc_builders/module-enrichment/intermediate-format.md`
- Module enrichment pipeline: `doc_builders/module-enrichment.md`
- ELK documentation: https://www.eclipse.org/elk/
- elkjs npm: https://www.npmjs.com/package/elkjs
