# SVG Signal Flow Renderer (Step 5)

**Purpose:** Transform enriched JSON into publication-quality SVG signal flow diagrams. Reads the enriched JSON topology and resolves parameter metadata from moduleList.json. Produces self-contained SVG files with embedded styles and a dark-first color scheme.

**Input:** `module_enrichment/enriched/{ModuleId}.json` + `module_enrichment/base/moduleList.json`
**Output:** `svg_renderer/output/{ModuleId}.svg`
**Source:** `svg_renderer/src/`

---

## Architecture

The renderer follows a 4-stage pipeline:

```
enriched JSON + moduleList.json
        |
  [1. Budget Filter]  Filter nodes by importance threshold
        |
  [2. ELK Transform]  Convert filtered graph to ELK model
        |
  [3. ELK Layout]     Compute positions via layered algorithm
        |
  [4. SVG Render]      Draw positioned nodes, edges, groups as SVG
        v
  {ModuleId}.svg
```

### Why ELK + Custom Renderer

- **ELK** (Eclipse Layout Kernel) solves the hard graph layout problem: edge routing, crossing minimization, compound node handling, back-edge routing for feedback loops. The `elkjs` npm package provides a JavaScript implementation.
- **Custom SVG renderer** gives full control over HISE-specific aesthetics (node shapes, color palette, composite block rendering, icon placement) that no general-purpose graph tool can provide.
- Rejected alternatives: Mermaid (no compound nodes, limited styling), Graphviz (poor compound node support), D2 (no programmatic control), manual layout (does not scale to 79 modules).

---

## Current State

The renderer exists at `svg_renderer/src/` and currently consumes the **old intermediate JSON format** (defined in `doc_builders/old/module-enrichment/intermediate-format.md`). It needs updating to consume the new enriched JSON format defined in `enriched-format.md`.

### What stays the same

- ELK layout engine and options
- Visual design system (colors, shapes, edge styles, icons)
- SVG rendering approach (string concatenation, embedded styles)
- CLI interface (single file and batch modes)
- Dependency stack (elkjs, typescript, tsx)

### What changes

The TypeScript types in `types.ts` must be updated to match the enriched JSON schema. The transform stage must handle the new fields: `parameterPlacements` (inline parameter labels on nodes, with nested `composite` objects for modMultiply/tempoSyncMux rendering), `omittedParameters` (skipped), `externalInputs`, and `io` object (instead of explicit I/O nodes).

---

## TypeScript Types

The types in `svg_renderer/src/types.ts` must align with the enriched JSON schema from `enriched-format.md`. Key type definitions:

### NodeType

```typescript
type NodeType =
  | 'io'             // Input/output port - pill shape
  | 'external_input' // External signal source - rect, dashed left border
  | 'midi_event'     // MIDI event node - rounded rect
  | 'audio'          // Audio processing - rounded rect
  | 'modulation'     // Modulation processing - rounded rect
  | 'filter'         // Filter processing - rounded rect
  | 'gain'           // Gain/amplitude - rounded rect
  | 'waveshaper'     // Waveshaping - rounded rect
  | 'delay_line'     // Delay line - rounded rect
  | 'table'          // Table/curve lookup - rounded rect
  | 'parameter'      // Explicit parameter node - small rect
  | 'decision';      // Conditional branch - diamond
```

### Scope

```typescript
type Scope = 'per_voice' | 'monophonic' | 'shared_resource' | 'parameter';
```

### EdgeType

```typescript
type EdgeType = 'signal' | 'feedback' | 'bypass' | 'modulation' | 'sidechain';
```

### GroupStyle

```typescript
type GroupStyle = 'polyphonic' | 'shared_region' | 'dashed_outline' | 'compound';
```

Note: `compound` is new compared to the old format. It uses a solid border with a label, similar to `shared_region` but semantically distinct (logical grouping vs. shared resource).

### Key Interfaces

```typescript
interface ProcessingNode {
  id: string;
  label: string;
  type: NodeType;
  scope: Scope;
  importance: number;
  detail?: string;
  cpuWeight?: {
    base: 'negligible' | 'low' | 'medium' | 'high' | 'very_high';
    scaleFactor?: { parameter: string; description: string };
  };
  condition?: {
    parameter: string;
    whenTrue: string;
    whenFalse: string;
  };
}

interface SignalFlowEdge {
  from: string;
  to: string;
  type: EdgeType;
  label?: string;
}

interface ParameterPlacement {
  param: string;
  target: string | string[];
  role: string;
  composite?: {
    type: 'modMultiply' | 'tempoSyncMux';
    [key: string]: unknown;
  };
}

interface DiagramGroup {
  id: string;
  label: string;
  nodes: string[];
  style: GroupStyle;
}

interface EnrichedJSON {
  moduleId: string;
  prettyName: string;
  type: string;
  subtype: string;
  io: {
    audioIn: string | null;
    audioOut: string | null;
    midiIn: string | null;
    modulationOut: boolean | null;
    fxChain: string | null;
  };
  externalInputs?: Array<{ id: string; label?: string }>;
  interfaces?: string[];
  processing: ProcessingNode[];
  signalFlow: SignalFlowEdge[];
  parameterPlacements: ParameterPlacement[];
  groups?: DiagramGroup[];
  omittedParameters?: Array<{ param: string; reason: string }>;
  layoutHints?: {
    direction?: string;
    feedbackLoops?: boolean;
    compactGroups?: boolean;
  };
  notes?: string;
}
```

---

## Stage 1: Budget Filter

Filter processing nodes by importance threshold before layout.

```
budget="documentation"  ->  importance >= 0.0  (all nodes)
budget="thumbnail"      ->  importance >= 0.5
budget="overview"       ->  importance >= 0.8
```

**Filter procedure:**

1. Remove processing nodes below the importance threshold
2. Remove signalFlow edges where either `from` or `to` references a removed node
3. Remove groups where all member nodes have been removed (keep groups with at least one remaining node, removing references to removed nodes from the `nodes` array)
4. Remove parameterPlacements where the `target` node has been removed
5. Remove composites on removed parameterPlacements

The `io` ports are always present (importance 1.0 by convention).

---

## Stage 2: ELK Transform

Convert the filtered enriched JSON into an ELK graph model.

### I/O Node Generation

The enriched JSON's `io` object does not contain explicit nodes - the renderer creates them:

- `audioIn` -> create node(s) with type `io`, label "Audio In" (or "Audio In L"/"Audio In R" for stereo)
- `audioOut` -> create node(s) with type `io`, label "Audio Out" (similar)
- `midiIn` -> create node with type `midi_event`, label matching the value (e.g., "noteOn + noteOff")
- `modulationOut` -> create node with type `io`, label "Mod Out"
- `fxChain` -> create node with type `audio`, label "FX Chain"

### External Input Node Generation

Each entry in `externalInputs` becomes a node with type `external_input`.

### Parameter Placement Rendering

For each parameterPlacement:

1. **Simple placement** (no composite): Add the parameter name as an annotation label on the target processing node. The renderer shows the parameter name below or beside the node label.

2. **modMultiply composite**: Create an inline multiply node `(*)` between the parameter value and the mod chain input. The icon (pulse/sine) is rendered on the mod chain input side based on the `constrainer` field. The renderer resolves the mod chain details from moduleList.json.

3. **tempoSyncMux composite**: Create an inline trapezoid node labeled with the sync toggle parameter name, with the time parameter on one input and the Host BPM external input on the other.

### ELK Layout Options

These options are proven and should be preserved:

```typescript
{
  'elk.algorithm': 'layered',
  'elk.direction': 'RIGHT',             // Left-to-right signal flow
  'elk.spacing.nodeNode': '30',
  'elk.spacing.edgeNode': '20',
  'elk.layered.spacing.nodeNodeBetweenLayers': '60',
  'elk.hierarchyHandling': 'INCLUDE_CHILDREN',
  'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
  'elk.edgeRouting': 'ORTHOGONAL',
}
```

### Port Assignment

Create source and target ports on nodes based on edge types:

| Edge type | Source port side | Target port side |
|-----------|-----------------|------------------|
| `signal` | EAST | WEST |
| `feedback` | WEST | EAST (routed as back-edge) |
| `bypass` | EAST | WEST |
| `modulation` | EAST | NORTH (enters from above) |
| `sidechain` | EAST | SOUTH (enters from below) |

### Group Handling

Groups become ELK compound nodes with their member nodes as children. The compound node has padding for the group label:

```typescript
{
  'elk.padding': '[top=30,left=15,bottom=15,right=15]'
}
```

---

## Stage 3: ELK Layout

Run `elkjs` layered layout. This stage is purely mechanical - pass the ELK graph to `elk.layout()` and receive positioned nodes with computed edge routes.

---

## Stage 4: SVG Render

### Draw Order

1. **Group backgrounds** (bottom layer)
2. **Edges** with arrowhead markers (middle layer)
3. **Nodes** with labels and icons (top layer)

### Visual Design System

#### Dark-First Color Scheme

The SVG uses a dark background (`#1a1a1a`) with embedded CSS. A `prefers-color-scheme: light` media query can be added for light-mode adaptation, but the primary design target is dark.

```css
svg { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #1a1a1a; }
.node-label { fill: rgba(255,255,255,0.9); font-size: 13px; font-weight: 600; }
.group-label { fill: rgba(255,255,255,0.5); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }
```

#### Node Color Palette

| NodeType | Fill | Stroke | Shape |
|----------|------|--------|-------|
| `io` | #3a3a3a | #888888 | pill (stadium) |
| `audio` | #1a3d2a | #4CAF50 | rounded rect |
| `modulation` | #1a2d4a | #42A5F5 | rounded rect |
| `midi_event` | #3d2a1a | #FF9800 | rounded rect |
| `filter` | #1a3d3a | #26A69A | rounded rect |
| `gain` | #1a3d2a | #66BB6A | rounded rect |
| `delay_line` | #1a3a3d | #26C6DA | rounded rect |
| `waveshaper` | #3d1a1a | #EF5350 | rounded rect |
| `parameter` | #2a2a2a | #9E9E9E | small rect |
| `table` | #3d3a1a | #FFCA28 | rounded rect |
| `decision` | #3d2d1a | #FFA726 | diamond |
| `external_input` | #2a1a3d | #AB47BC | rect, dashed left border |

#### Edge Styles

| EdgeType | Color | Dash pattern | Width | Arrow |
|----------|-------|-------------|-------|-------|
| `signal` | #bbbbbb | solid | 2 | filled |
| `feedback` | #999999 | 8,4 | 2 | open (stroke only) |
| `bypass` | #777777 | 4,4 | 1.5 | filled |
| `modulation` | #42A5F5 | solid | 1.5 | filled (smaller) |
| `sidechain` | #AB47BC | 6,3 | 1.5 | filled |

#### Group Styles

| GroupStyle | Border color | Dash | Fill | Border width |
|-----------|-------------|------|------|-------------|
| `polyphonic` | #42A5F5 | solid | rgba(66,165,245,0.06) | 2 (doubled border) |
| `shared_region` | #666666 | solid | rgba(255,255,255,0.04) | 1.5 |
| `dashed_outline` | #555555 | 6,4 | rgba(255,255,255,0.02) | 1 |
| `compound` | #555555 | solid | rgba(255,255,255,0.03) | 1.5 |

The `polyphonic` group renders a doubled border (offset shadow rect at 30% opacity) to indicate per-voice duplication.

`compound` is new - uses the same visual treatment as `shared_region` but with a slightly different fill opacity to distinguish logical grouping from shared resources.

#### Node Shapes

| Shape | Used by | Rendering |
|-------|---------|-----------|
| Pill / stadium | `io` | `<rect>` with `rx` = height/2 |
| Diamond | `decision` | `<polygon>` with 4 points |
| Rounded rect | most types | `<rect>` with `rx="6"` |
| Small rect | `parameter` | `<rect>` with `rx="3"`, smaller height, lighter font |
| Dashed-left rect | `external_input` | `<rect>` with a dashed `<line>` overlay on the left border |

#### Icon Symbols

Defined as `<symbol>` elements in `<defs>`:

| Icon ID | Used for | Description |
|---------|----------|-------------|
| `icon-sine` | Modulation nodes, external inputs | One period sine wave, stroke #42A5F5 |
| `icon-voice-start` | VoiceStartModulator nodes | Single trigger pulse, stroke #AB47BC |

Icons are placed to the left of the node label, both centered as a group within the node.

The `rules.ts` module controls icon assignment via priority-based matching:
- Priority 10: `voice-start-mod` - matches nodes with `detail` containing "VoiceStartModulator" -> `icon-voice-start`
- Priority 1: `mod-signal` - matches `modulation` or `external_input` type -> `icon-sine`

#### Node Sizing

| Metric | Value |
|--------|-------|
| Character width estimate | 7.8px at 13px font |
| Horizontal padding | 24px per side |
| Vertical padding | 12px per side |
| Minimum width | 80px |
| Standard height | 36px |
| Parameter node height | 28px |
| Decision diamond size | 60px minimum side length |
| Icon width | 18px |
| Icon gap | 5px |
| Diagram padding | 24px |

Node width = max(80, label_length * 7.8 + 48 + icon_space)

#### Target Dimensions

- **Documentation** (full diagram): up to 800px wide
- **Thumbnail** (sidebar): ~400px wide

The SVG uses a `viewBox` and can be scaled to any size while maintaining aspect ratio.

---

## Composite Block Rendering

### modMultiply

Rendered as a small multiply node `(*)` between the parameter value and the modulation chain input:

```
[Parameter Value] ----> (*) ----> [Processing Node]
                         ^
                    [Mod Chain]
                   (with icon)
```

The icon on the mod chain input is determined by the composite's `constrainer` field:
- Contains `VoiceStartModulator` -> pulse icon (icon-voice-start)
- Otherwise -> sine icon (icon-sine)

### tempoSyncMux

Rendered as a trapezoid node inline with the parameter:

```
[Time Parameter] ----> [TempoSync] ----> [Processing Node]
                            ^
                       [Host BPM]
```

The trapezoid label is the sync toggle parameter name. The renderer draws this as a slightly asymmetric rect or trapezoid path to distinguish it visually from standard nodes.

---

## Parameter Annotation

For simple parameter placements (no composite), the parameter name is rendered as a secondary label on or adjacent to the target processing node. Options:

1. **Below the node**: parameter name in a smaller font, centered
2. **Inside the node**: if the node label is short, append `(param)` in a lighter font weight
3. **As a connected parameter node**: create a small `parameter` type node with an edge to the target

The choice depends on diagram density. For modules with many parameters on the same node, option 3 prevents overcrowding. For modules with one parameter per node, option 1 or 2 is cleaner. This is a renderer judgment call that may evolve.

---

## moduleList.json Resolution

The renderer reads `moduleList.json` to resolve:

- Parameter display names (for annotation labels)
- Parameter ranges and defaults (not currently rendered, but available for tooltips)
- Modulation chain names and constrainer types (for modMultiply icon selection)
- Tempo sync parameter names (for tempoSyncMux labels)

The enriched JSON's `parameterPlacements[].param` field is the key into moduleList.json's parameter array. The renderer looks up the matching entry by `id` field.

---

## CLI Interface

```
npx tsx src/render.ts <input.json|dir> <output.svg|dir> [--budget documentation|thumbnail|overview]
```

- **Single file mode**: `render.ts enriched/AHDSR.json output/AHDSR.svg`
- **Batch mode**: `render.ts enriched/ output/` (renders all `.json` files)
- **Budget flag**: `--budget thumbnail` (default: `documentation`)

The batch mode script in `package.json`:
```json
{
  "scripts": {
    "render": "tsx src/render.ts",
    "render:all": "tsx src/render.ts ../module_enrichment/enriched/ output/"
  }
}
```

Note: The `render:all` script path should be updated from `../module_enrichment/phase1/` to `../module_enrichment/enriched/` when the renderer is updated for the new format.

---

## Validation

### Test Cases

After updating the renderer, validate with these test cases from the pilot batch:

**AHDSR** (envelope modulator):
- Expected: MIDI event input, 5 envelope stages in a compound group, modulation chain multiply nodes, modulation output
- Success: All stages visible in left-to-right flow, polyphonic group with doubled border, mod multiply nodes show correct icons

**Delay** (master effect):
- Expected: Stereo audio I/O, delay lines with feedback paths, tempo sync mux nodes, Host BPM external input
- Success: Feedback edges rendered as dashed back-edges, tempo sync trapezoids inline, stereo paths visible

### Step 5 Gate Checklist

Before accepting a rendered SVG, verify:

- [ ] Diagram is legible at 800px wide (documentation budget)
- [ ] Diagram is recognizable at 400px wide (thumbnail budget)
- [ ] Overview budget (>= 0.8 importance) produces a meaningful 3-5 node diagram
- [ ] No overlapping nodes or labels
- [ ] Feedback loops render as visually distinct curved-back dashed edges
- [ ] Group borders do not overlap node borders
- [ ] Icons render at correct size and alignment with labels
- [ ] Composite blocks render inline without disrupting the signal flow direction
- [ ] All processing nodes from the enriched JSON are present in the SVG (at the documentation budget)
- [ ] All edges from the enriched JSON are rendered with correct types (solid/dashed/dotted)

---

## Future Extensions

1. **Light mode**: Add `@media (prefers-color-scheme: light)` CSS block with inverted colors
2. **Interactive SVG**: Add `<title>` elements on nodes for browser tooltips showing parameter details
3. **CSS custom properties**: Replace hardcoded colors with `var(--node-audio-fill)` etc. for themability
4. **Parameter range display**: Show `[min..max]` or default values as secondary text on parameter annotations
5. **Condition rendering**: Decision nodes could show both branches with conditional labels
6. **cpuWeight visualization**: Color intensity or node border thickness proportional to CPU cost tier
