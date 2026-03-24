// Intermediate JSON types matching doc_builders/module-enrichment/intermediate-format.md

export type NodeType =
	| 'io'
	| 'external_input'
	| 'midi_event'
	| 'audio'
	| 'modulation'
	| 'filter'
	| 'gain'
	| 'waveshaper'
	| 'delay_line'
	| 'table'
	| 'parameter'
	| 'decision';

export type Scope = 'shared_resource' | 'per_voice' | 'monophonic' | 'parameter';

export type EdgeType = 'signal' | 'feedback' | 'bypass' | 'modulation' | 'sidechain';

export type GroupStyle = 'polyphonic' | 'shared_region' | 'dashed_outline';

export interface Condition {
	parameter: string;
	whenTrue: string;
	whenFalse: string;
}

export interface Node {
	id: string;
	label: string;
	type: NodeType;
	detail?: string;
	scope: Scope;
	parameters?: string[];
	importance: number;
	condition?: Condition;
}

export interface Edge {
	from: string;
	to: string;
	type: EdgeType;
	label?: string;
}

export interface Group {
	id: string;
	label: string;
	nodes: string[];
	style: GroupStyle;
}

export interface IntermediateJSON {
	moduleId: string;
	notes?: string;
	nodes: Node[];
	edges: Edge[];
	groups?: Group[];
}
