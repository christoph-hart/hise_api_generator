// Detail interpretation rule engine
// Maps node detail strings (and other properties) to visual modifiers.
// Rules are evaluated in priority order (highest first); first match wins.

import type { Node } from './types.js';

export interface VisualModifiers {
	icon?: string;  // SVG <symbol> id (e.g. "icon-voice-start", "icon-sine")
}

interface DetailRule {
	id: string;
	priority: number;
	match: (node: Node) => boolean;
	apply: (node: Node) => VisualModifiers;
}

const DETAIL_RULES: DetailRule[] = [
	{
		id: 'voice-start-mod',
		priority: 10,
		match: (node) => !!node.detail?.match(/VoiceStartModulator/i),
		apply: () => ({ icon: 'icon-voice-start' }),
	},
	{
		id: 'mod-signal',
		priority: 1,
		match: (node) => node.type === 'modulation' || node.type === 'external_input',
		apply: () => ({ icon: 'icon-sine' }),
	},
];

// Sorted once at load time so evaluation is always highest-priority-first
const SORTED_RULES = [...DETAIL_RULES].sort((a, b) => b.priority - a.priority);

/** Return visual modifiers for a node. First matching rule (by priority) wins. */
export function getVisualModifiers(node: Node): VisualModifiers {
	for (const rule of SORTED_RULES) {
		if (rule.match(node)) {
			return rule.apply(node);
		}
	}
	return {};
}
