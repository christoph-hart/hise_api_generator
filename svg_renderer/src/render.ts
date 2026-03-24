import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, statSync } from 'node:fs';
import { resolve, basename, join, dirname } from 'node:path';
import ELK, { type ElkNode, type ElkExtendedEdge, type ElkPort } from 'elkjs';
import type { IntermediateJSON, Node, Edge, Group, NodeType, EdgeType, GroupStyle } from './types.js';
import { getVisualModifiers, type VisualModifiers } from './rules.js';

// ---------------------------------------------------------------------------
//  Style constants
// ---------------------------------------------------------------------------

const FONT_FAMILY = `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`;
const CHAR_WIDTH = 7.8;   // estimated average character width at 13px
const NODE_PAD_X = 24;
const NODE_PAD_Y = 12;
const NODE_MIN_WIDTH = 80;
const NODE_HEIGHT = 36;
const PARAM_NODE_HEIGHT = 28;
const DECISION_SIZE = 60;  // diamond side length
const DIAGRAM_PAD = 24;
const ICON_WIDTH = 18;     // icon viewBox width
const ICON_HEIGHT = 12;    // icon viewBox height
const ICON_GAP = 5;        // gap between icon and label text
const ICON_TOTAL = ICON_WIDTH + ICON_GAP; // total horizontal space for icon

// Node type -> fill & stroke colors (dark theme)
const NODE_COLORS: Record<NodeType, { fill: string; stroke: string }> = {
	io:             { fill: '#3a3a3a', stroke: '#888888' },
	audio:          { fill: '#1a3d2a', stroke: '#4CAF50' },
	modulation:     { fill: '#1a2d4a', stroke: '#42A5F5' },
	midi_event:     { fill: '#3d2a1a', stroke: '#FF9800' },
	filter:         { fill: '#1a3d3a', stroke: '#26A69A' },
	gain:           { fill: '#1a3d2a', stroke: '#66BB6A' },
	delay_line:     { fill: '#1a3a3d', stroke: '#26C6DA' },
	waveshaper:     { fill: '#3d1a1a', stroke: '#EF5350' },
	parameter:      { fill: '#2a2a2a', stroke: '#9E9E9E' },
	table:          { fill: '#3d3a1a', stroke: '#FFCA28' },
	decision:       { fill: '#3d2d1a', stroke: '#FFA726' },
	external_input: { fill: '#2a1a3d', stroke: '#AB47BC' },
};

// Edge type -> color, dash, width
const EDGE_STYLES: Record<EdgeType, { color: string; dash: string; width: number }> = {
	signal:     { color: '#bbbbbb', dash: '',      width: 2 },
	feedback:   { color: '#999999', dash: '8,4',   width: 2 },
	bypass:     { color: '#777777', dash: '4,4',   width: 1.5 },
	modulation: { color: '#42A5F5', dash: '',      width: 1.5 },
	sidechain:  { color: '#AB47BC', dash: '6,3',   width: 1.5 },
};

// Group style -> border, fill
const GROUP_STYLES: Record<GroupStyle, { border: string; borderDash: string; fill: string; borderWidth: number }> = {
	polyphonic:    { border: '#42A5F5', borderDash: '',    fill: 'rgba(66,165,245,0.06)',  borderWidth: 2 },
	shared_region: { border: '#666666', borderDash: '',    fill: 'rgba(255,255,255,0.04)', borderWidth: 1.5 },
	dashed_outline:{ border: '#555555', borderDash: '6,4', fill: 'rgba(255,255,255,0.02)', borderWidth: 1 },
};

// ---------------------------------------------------------------------------
//  Node sizing
// ---------------------------------------------------------------------------

function measureNode(node: Node, mods: VisualModifiers): { width: number; height: number } {
	if (node.type === 'decision') {
		const textWidth = node.label.length * CHAR_WIDTH + NODE_PAD_X;
		const side = Math.max(DECISION_SIZE, textWidth * 0.9);
		return { width: side, height: side };
	}

	const iconExtra = mods.icon ? ICON_TOTAL : 0;
	const labelWidth = node.label.length * CHAR_WIDTH + NODE_PAD_X * 2 + iconExtra;
	const width = Math.max(NODE_MIN_WIDTH, labelWidth);

	if (node.type === 'parameter') {
		return { width, height: PARAM_NODE_HEIGHT };
	}

	return { width, height: NODE_HEIGHT };
}

// ---------------------------------------------------------------------------
//  ELK transform
// ---------------------------------------------------------------------------

interface ElkGraphInput {
	elkGraph: ElkNode;
	nodeMap: Map<string, Node>;
	edgeTypes: Map<string, EdgeType>;
	nodeModifiers: Map<string, VisualModifiers>;
}

function toElkGraph(data: IntermediateJSON): ElkGraphInput {
	const nodeMap = new Map<string, Node>();
	const nodeModifiers = new Map<string, VisualModifiers>();
	for (const n of data.nodes) {
		nodeMap.set(n.id, n);
		nodeModifiers.set(n.id, getVisualModifiers(n));
	}

	// Build group membership: nodeId -> groupId
	const nodeToGroup = new Map<string, string>();
	const groups = data.groups ?? [];
	for (const g of groups) {
		for (const nid of g.nodes) {
			nodeToGroup.set(nid, g.id);
		}
	}

	// Build ELK nodes for each intermediate node, with ports
	const portCounters = new Map<string, number>(); // nodeId -> port counter
	function makePort(nodeId: string, side: 'EAST' | 'WEST' | 'NORTH' | 'SOUTH'): ElkPort {
		const count = portCounters.get(nodeId) ?? 0;
		portCounters.set(nodeId, count + 1);
		return {
			id: `${nodeId}_p${count}`,
			layoutOptions: {
				'elk.port.side': side,
			},
		};
	}

	// Pre-create ports based on edges
	const nodePorts = new Map<string, ElkPort[]>(); // nodeId -> ports
	const edgeSourcePorts = new Map<string, string>(); // edgeKey -> portId
	const edgeTargetPorts = new Map<string, string>(); // edgeKey -> portId
	const edgeTypes = new Map<string, EdgeType>();

	for (let i = 0; i < data.edges.length; i++) {
		const e = data.edges[i];
		const edgeKey = `e${i}`;
		edgeTypes.set(edgeKey, e.type);

		// Source port (output side - EAST for signal, SOUTH for params feeding down)
		const srcSide = (e.type === 'feedback') ? 'WEST' : 'EAST';
		const srcPort = makePort(e.from, srcSide);
		if (!nodePorts.has(e.from)) nodePorts.set(e.from, []);
		nodePorts.get(e.from)!.push(srcPort);
		edgeSourcePorts.set(edgeKey, srcPort.id);

		// Target port (input side - WEST for signal, NORTH for modulation targets)
		const tgtSide = (e.type === 'modulation') ? 'NORTH' : (e.type === 'feedback') ? 'EAST' : 'WEST';
		const tgtPort = makePort(e.to, tgtSide);
		if (!nodePorts.has(e.to)) nodePorts.set(e.to, []);
		nodePorts.get(e.to)!.push(tgtPort);
		edgeTargetPorts.set(edgeKey, tgtPort.id);
	}

	// Create ELK child nodes
	function makeElkNode(n: Node): ElkNode {
		const mods = nodeModifiers.get(n.id) ?? {};
		const size = measureNode(n, mods);
		const ports = nodePorts.get(n.id) ?? [];
		return {
			id: n.id,
			width: size.width,
			height: size.height,
			ports,
			labels: [{ id: `${n.id}_label`, text: n.label, width: n.label.length * CHAR_WIDTH, height: 14 }],
			layoutOptions: {
				'elk.portConstraints': 'FIXED_SIDE',
			},
		};
	}

	// Create ELK edges
	const elkEdges: ElkExtendedEdge[] = data.edges.map((e, i) => {
		const edgeKey = `e${i}`;
		return {
			id: edgeKey,
			sources: [edgeSourcePorts.get(edgeKey)!],
			targets: [edgeTargetPorts.get(edgeKey)!],
		};
	});

	// Build compound nodes for groups
	const groupElkNodes = new Map<string, ElkNode>();
	for (const g of groups) {
		const children: ElkNode[] = [];
		for (const nid of g.nodes) {
			const n = nodeMap.get(nid);
			if (n) children.push(makeElkNode(n));
		}
		const groupNode: ElkNode = {
			id: g.id,
			children,
			labels: [{ id: `${g.id}_label`, text: g.label, width: g.label.length * CHAR_WIDTH, height: 14 }],
			layoutOptions: {
				'elk.padding': '[top=30,left=15,bottom=15,right=15]',
			},
		};
		groupElkNodes.set(g.id, groupNode);
	}

	// Top-level children: grouped nodes are inside compound nodes, ungrouped are top-level
	const topChildren: ElkNode[] = [];
	const groupedNodeIds = new Set<string>();
	for (const g of groups) {
		for (const nid of g.nodes) groupedNodeIds.add(nid);
		topChildren.push(groupElkNodes.get(g.id)!);
	}
	for (const n of data.nodes) {
		if (!groupedNodeIds.has(n.id)) {
			topChildren.push(makeElkNode(n));
		}
	}

	const elkGraph: ElkNode = {
		id: 'root',
		children: topChildren,
		edges: elkEdges,
		layoutOptions: {
			'elk.algorithm': 'layered',
			'elk.direction': 'RIGHT',
			'elk.spacing.nodeNode': '30',
			'elk.spacing.edgeNode': '20',
			'elk.layered.spacing.nodeNodeBetweenLayers': '60',
			'elk.hierarchyHandling': 'INCLUDE_CHILDREN',
			'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
			'elk.edgeRouting': 'ORTHOGONAL',
		},
	};

	return { elkGraph, nodeMap, edgeTypes, nodeModifiers };
}

// ---------------------------------------------------------------------------
//  SVG rendering
// ---------------------------------------------------------------------------

function esc(s: string): string {
	return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

interface PositionedNode extends ElkNode {
	x: number;
	y: number;
	width: number;
	height: number;
}

// Collect all positioned nodes recursively (compound nodes contain children)
function collectNodes(elkNode: ElkNode, offsetX = 0, offsetY = 0): Map<string, { x: number; y: number; w: number; h: number }> {
	const result = new Map<string, { x: number; y: number; w: number; h: number }>();
	const x = (elkNode.x ?? 0) + offsetX;
	const y = (elkNode.y ?? 0) + offsetY;
	const w = elkNode.width ?? 0;
	const h = elkNode.height ?? 0;
	result.set(elkNode.id, { x, y, w, h });

	if (elkNode.children) {
		for (const child of elkNode.children) {
			const childPositions = collectNodes(child, x, y);
			for (const [id, pos] of childPositions) {
				result.set(id, pos);
			}
		}
	}
	return result;
}

// Collect port positions
function collectPorts(elkNode: ElkNode, offsetX = 0, offsetY = 0): Map<string, { x: number; y: number }> {
	const result = new Map<string, { x: number; y: number }>();
	const nx = (elkNode.x ?? 0) + offsetX;
	const ny = (elkNode.y ?? 0) + offsetY;

	if (elkNode.ports) {
		for (const p of elkNode.ports) {
			result.set(p.id, { x: nx + (p.x ?? 0), y: ny + (p.y ?? 0) });
		}
	}
	if (elkNode.children) {
		for (const child of elkNode.children) {
			const childPorts = collectPorts(child, nx, ny);
			for (const [id, pos] of childPorts) {
				result.set(id, pos);
			}
		}
	}
	return result;
}

/** Render a node's icon (if any) + label text, centered in the node box. */
function renderNodeContent(
	lines: string[],
	nx: number, ny: number, nw: number, nh: number,
	label: string, mods: VisualModifiers,
	labelClass: string = 'node-label',
	labelStyle?: string,
): void {
	const cx = nx + nw / 2;
	const cy = ny + nh / 2;
	const styleAttr = labelStyle ? ` style="${labelStyle}"` : '';

	if (mods.icon) {
		// Icon to the left of label, both centered as a group
		const textW = label.length * CHAR_WIDTH;
		const totalW = ICON_WIDTH + ICON_GAP + textW;
		const groupLeft = cx - totalW / 2;
		const iconX = groupLeft;
		const iconY = cy - ICON_HEIGHT / 2;
		const textX = groupLeft + ICON_TOTAL + textW / 2;

		lines.push(`  <use href="#${mods.icon}" x="${iconX.toFixed(1)}" y="${iconY.toFixed(1)}" width="${ICON_WIDTH}" height="${ICON_HEIGHT}"/>`);
		lines.push(`  <text x="${textX.toFixed(1)}" y="${(cy + 4).toFixed(1)}" text-anchor="middle" class="${labelClass}"${styleAttr}>${esc(label)}</text>`);
	} else {
		lines.push(`  <text x="${cx.toFixed(1)}" y="${(cy + 4).toFixed(1)}" text-anchor="middle" class="${labelClass}"${styleAttr}>${esc(label)}</text>`);
	}
}

function renderSvg(
	layoutedGraph: ElkNode,
	data: IntermediateJSON,
	nodeMap: Map<string, Node>,
	edgeTypes: Map<string, EdgeType>,
	nodeModifiers: Map<string, VisualModifiers>,
): string {
	const positions = collectNodes(layoutedGraph);
	const portPositions = collectPorts(layoutedGraph);
	const groups = data.groups ?? [];

	// Compute bounding box
	let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
	for (const [, pos] of positions) {
		minX = Math.min(minX, pos.x);
		minY = Math.min(minY, pos.y);
		maxX = Math.max(maxX, pos.x + pos.w);
		maxY = Math.max(maxY, pos.y + pos.h);
	}

	const svgWidth = maxX - minX + DIAGRAM_PAD * 2;
	const svgHeight = maxY - minY + DIAGRAM_PAD * 2;
	const ox = -minX + DIAGRAM_PAD; // offset to shift everything into positive space
	const oy = -minY + DIAGRAM_PAD;

	const lines: string[] = [];

	// SVG header
	lines.push(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${svgWidth.toFixed(0)} ${svgHeight.toFixed(0)}" width="${svgWidth.toFixed(0)}" height="${svgHeight.toFixed(0)}">`);
	lines.push(`<title>${esc(data.moduleId)} Signal Flow</title>`);
	if (data.notes) {
		lines.push(`<desc>${esc(data.notes.substring(0, 200))}</desc>`);
	}

	// Embedded styles
	lines.push(`<style>`);
	lines.push(`  svg { font-family: ${FONT_FAMILY}; background: #1a1a1a; }`);
	lines.push(`  .node-label { fill: rgba(255,255,255,0.9); font-size: 13px; font-weight: 600; }`);
	lines.push(`  .group-label { fill: rgba(255,255,255,0.5); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }`);
	lines.push(`</style>`);

	// Arrowhead markers
	lines.push(`<defs>`);
	for (const [type, style] of Object.entries(EDGE_STYLES)) {
		const markerSize = type === 'modulation' ? 6 : 8;
		const isFeedback = type === 'feedback';
		lines.push(`  <marker id="arrow-${type}" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="${markerSize}" markerHeight="${markerSize}" orient="auto-start-reverse">`);
		if (isFeedback) {
			lines.push(`    <path d="M 0 0 L 10 5 L 0 10" fill="none" stroke="${style.color}" stroke-width="1.5"/>`);
		} else {
			lines.push(`    <path d="M 0 0 L 10 5 L 0 10 Z" fill="${style.color}"/>`);
		}
		lines.push(`  </marker>`);
	}
	// Icon symbols for detail rules
	// Sine wave: one period, stroke-only
	lines.push(`  <symbol id="icon-sine" viewBox="0 0 18 12">`);
	lines.push(`    <path d="M 1,6 C 3.5,1 6,1 9,6 C 12,11 14.5,11 17,6" fill="none" stroke="#42A5F5" stroke-width="1.8" stroke-linecap="round"/>`);
	lines.push(`  </symbol>`);
	// Voice-start pulse: single trigger pulse, stroke-only
	lines.push(`  <symbol id="icon-voice-start" viewBox="0 0 18 12">`);
	lines.push(`    <path d="M 1,10 L 5,10 L 5,2 L 13,2 L 13,10 L 17,10" fill="none" stroke="#AB47BC" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>`);
	lines.push(`  </symbol>`);
	lines.push(`</defs>`);

	// --- Layer 1: Group backgrounds ---
	for (const g of groups) {
		const gPos = positions.get(g.id);
		if (!gPos) continue;

		const style = GROUP_STYLES[g.style];
		const gx = gPos.x + ox;
		const gy = gPos.y + oy;

		if (g.style === 'polyphonic') {
			// Double border effect: outer offset rect + inner rect
			const offset = 3;
			lines.push(`  <rect x="${(gx + offset).toFixed(1)}" y="${(gy + offset).toFixed(1)}" width="${gPos.w.toFixed(1)}" height="${gPos.h.toFixed(1)}" rx="6" fill="none" stroke="${style.border}" stroke-width="${style.borderWidth}" stroke-opacity="0.3"/>`);
		}

		let dashAttr = '';
		if (style.borderDash) dashAttr = ` stroke-dasharray="${style.borderDash}"`;

		lines.push(`  <rect x="${gx.toFixed(1)}" y="${gy.toFixed(1)}" width="${gPos.w.toFixed(1)}" height="${gPos.h.toFixed(1)}" rx="6" fill="${style.fill}" stroke="${style.border}" stroke-width="${style.borderWidth}"${dashAttr}/>`);

		// Group label at top-left
		lines.push(`  <text x="${(gx + 10).toFixed(1)}" y="${(gy + 16).toFixed(1)}" class="group-label">${esc(g.label)}</text>`);
	}

	// --- Layer 2: Edges ---
	if (layoutedGraph.edges) {
		for (const edge of layoutedGraph.edges) {
			const eType = edgeTypes.get(edge.id) ?? 'signal';
			const style = EDGE_STYLES[eType];

			// Build path from edge sections or from source/target ports
			let pathD = '';
			if (edge.sections && edge.sections.length > 0) {
				for (const section of edge.sections) {
					const sx = section.startPoint.x + ox;
					const sy = section.startPoint.y + oy;
					pathD += `M ${sx.toFixed(1)} ${sy.toFixed(1)}`;

					if (section.bendPoints) {
						for (const bp of section.bendPoints) {
							pathD += ` L ${(bp.x + ox).toFixed(1)} ${(bp.y + oy).toFixed(1)}`;
						}
					}
					const ex = section.endPoint.x + ox;
					const ey = section.endPoint.y + oy;
					pathD += ` L ${ex.toFixed(1)} ${ey.toFixed(1)}`;
				}
			} else {
				// Fallback: connect port centers
				const srcPortId = (edge as ElkExtendedEdge).sources?.[0];
				const tgtPortId = (edge as ElkExtendedEdge).targets?.[0];
				const srcPos = srcPortId ? portPositions.get(srcPortId) : undefined;
				const tgtPos = tgtPortId ? portPositions.get(tgtPortId) : undefined;
				if (srcPos && tgtPos) {
					pathD = `M ${(srcPos.x + ox).toFixed(1)} ${(srcPos.y + oy).toFixed(1)} L ${(tgtPos.x + ox).toFixed(1)} ${(tgtPos.y + oy).toFixed(1)}`;
				}
			}

			if (!pathD) continue;

			let dashAttr = '';
			if (style.dash) dashAttr = ` stroke-dasharray="${style.dash}"`;

			lines.push(`  <path d="${pathD}" fill="none" stroke="${style.color}" stroke-width="${style.width}"${dashAttr} marker-end="url(#arrow-${eType})"/>`);
		}
	}

	// --- Layer 3: Nodes ---
	const groupIds = new Set(groups.map(g => g.id));
	for (const [id, pos] of positions) {
		if (id === 'root') continue;
		if (groupIds.has(id)) continue; // groups rendered as backgrounds, not nodes

		const node = nodeMap.get(id);
		if (!node) continue;

		const nx = pos.x + ox;
		const ny = pos.y + oy;
		const nw = pos.w;
		const nh = pos.h;
		const colors = NODE_COLORS[node.type];
		const mods = nodeModifiers.get(id) ?? {};

		if (node.type === 'decision') {
			// Diamond shape
			const cx = nx + nw / 2;
			const cy = ny + nh / 2;
			const hw = nw / 2;
			const hh = nh / 2;
			lines.push(`  <polygon points="${cx},${(cy - hh).toFixed(1)} ${(cx + hw).toFixed(1)},${cy} ${cx},${(cy + hh).toFixed(1)} ${(cx - hw).toFixed(1)},${cy}" fill="${colors.fill}" stroke="${colors.stroke}" stroke-width="2"/>`);
			renderNodeContent(lines, nx, ny, nw, nh, node.label, mods);
		} else if (node.type === 'io') {
			// Pill / stadium shape
			const r = nh / 2;
			lines.push(`  <rect x="${nx.toFixed(1)}" y="${ny.toFixed(1)}" width="${nw.toFixed(1)}" height="${nh.toFixed(1)}" rx="${r.toFixed(1)}" fill="${colors.fill}" stroke="${colors.stroke}" stroke-width="2"/>`);
			renderNodeContent(lines, nx, ny, nw, nh, node.label, mods);
		} else if (node.type === 'external_input') {
			// Rectangle with dashed left border
			lines.push(`  <rect x="${nx.toFixed(1)}" y="${ny.toFixed(1)}" width="${nw.toFixed(1)}" height="${nh.toFixed(1)}" rx="4" fill="${colors.fill}" stroke="${colors.stroke}" stroke-width="1.5"/>`);
			// Dashed left border overlay
			lines.push(`  <line x1="${nx.toFixed(1)}" y1="${(ny + 4).toFixed(1)}" x2="${nx.toFixed(1)}" y2="${(ny + nh - 4).toFixed(1)}" stroke="${colors.stroke}" stroke-width="3" stroke-dasharray="4,3"/>`);
			renderNodeContent(lines, nx, ny, nw, nh, node.label, mods);
		} else if (node.type === 'parameter') {
			// Compact rectangle
			lines.push(`  <rect x="${nx.toFixed(1)}" y="${ny.toFixed(1)}" width="${nw.toFixed(1)}" height="${nh.toFixed(1)}" rx="3" fill="${colors.fill}" stroke="${colors.stroke}" stroke-width="1"/>`);
			renderNodeContent(lines, nx, ny, nw, nh, node.label, mods, 'node-label', 'font-size:11px;font-weight:400');
		} else {
			// Default: rounded rectangle
			lines.push(`  <rect x="${nx.toFixed(1)}" y="${ny.toFixed(1)}" width="${nw.toFixed(1)}" height="${nh.toFixed(1)}" rx="6" fill="${colors.fill}" stroke="${colors.stroke}" stroke-width="2"/>`);
			renderNodeContent(lines, nx, ny, nw, nh, node.label, mods);
		}
	}

	lines.push(`</svg>`);
	return lines.join('\n');
}

// ---------------------------------------------------------------------------
//  Main
// ---------------------------------------------------------------------------

async function renderFile(inputPath: string, outputPath: string) {
	const raw = readFileSync(inputPath, 'utf-8');
	const data: IntermediateJSON = JSON.parse(raw);

	console.log(`  Transforming ${data.moduleId} (${data.nodes.length} nodes, ${data.edges.length} edges)...`);

	const { elkGraph, nodeMap, edgeTypes, nodeModifiers } = toElkGraph(data);

	const elk = new ELK();
	const layouted = await elk.layout(elkGraph);

	const svg = renderSvg(layouted, data, nodeMap, edgeTypes, nodeModifiers);

	const outDir = dirname(outputPath);
	if (!existsSync(outDir)) mkdirSync(outDir, { recursive: true });
	writeFileSync(outputPath, svg, 'utf-8');

	console.log(`  -> ${outputPath} (${svg.length} bytes)`);
}

async function main() {
	const args = process.argv.slice(2);

	if (args.length < 2) {
		console.log('Usage: npx tsx src/render.ts <input.json|dir> <output.svg|dir> [--budget documentation|thumbnail|overview]');
		process.exit(1);
	}

	const [inputArg, outputArg] = args;
	const input = resolve(inputArg);
	const output = resolve(outputArg);

	if (statSync(input).isDirectory()) {
		// Batch mode: render all .json files in directory
		const files = readdirSync(input).filter(f => f.endsWith('.json'));
		console.log(`Batch rendering ${files.length} files from ${input}`);
		for (const f of files) {
			const name = basename(f, '.json');
			await renderFile(join(input, f), join(output, `${name}.svg`));
		}
	} else {
		// Single file mode
		await renderFile(input, output);
	}

	console.log('Done.');
}

main().catch(err => {
	console.error('Error:', err);
	process.exit(1);
});
