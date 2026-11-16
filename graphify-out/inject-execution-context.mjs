import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const dir = path.dirname(fileURLToPath(import.meta.url));
const context = JSON.parse(fs.readFileSync(path.join(dir, 'execution-context.json'), 'utf8'));
const graphPath = path.join(dir, 'graph.json');
const graph = JSON.parse(fs.readFileSync(graphPath, 'utf8'));
// Remove only this script's prior overlay, preserving Graphify's original data.
graph.nodes = graph.nodes.filter((n) => n._origin !== 'ticket_execution');
graph.links = graph.links.filter((e) => e._origin !== 'ticket_execution');
const overlayNodes = [];
const overlayEdges = [];
const byFile = new Map(graph.nodes.filter((n) => n.metadata?.kind === 'file').map((n) => [n.source_file, n]));
const add = (node) => { graph.nodes.push(node); overlayNodes.push(node); return node; };
for (const entry of context.executions) {
  const root = add({ id: `ticket_execution_${entry.ticket}`, label: `#${entry.ticket}: refund execution evidence`,
    file_type: 'documentation', source_file: entry.evidence, _origin: 'ticket_execution',
    metadata: { kind: 'ticket_execution', ...entry } });
  for (const source of [entry.evidence, ...entry.sources]) {
    let node = byFile.get(source);
    if (!node) {
      node = add({ id: `execution_file_${source.replace(/[^a-zA-Z0-9]/g, '_')}`, label: path.basename(source),
        file_type: 'evidence', source_file: source, _origin: 'ticket_execution', metadata: { kind: 'file' } });
      byFile.set(source, node);
    } else if (!overlayNodes.some((n) => n.id === node.id)) overlayNodes.push(node);
    const edge = { source: root.id, target: node.id, relation: 'supported_by',
      confidence: 'EXPLICIT', source_file: entry.evidence, _origin: 'ticket_execution', weight: 1 };
    graph.links.push(edge); overlayEdges.push(edge);
  }
}
graph.graph.execution_context = 'graphify-out/execution-context.json';
graph.graph.ast_note = 'built_at_commit identifies the historical AST baseline; ticket_execution nodes are evidence overlays, not a full AST rebuild.';
// Preserve Graphify's float spelling so evidence injection does not rewrite
// thousands of unrelated weight/confidence lines from the Python serializer.
const serialized = JSON.stringify(graph, null, 2).replace(
  /("(?:weight|confidence_score)": )(\d+)([,\n])/g, '$1$2.0$3',
);
fs.writeFileSync(graphPath, serialized + '\n');
const htmlPath = path.join(dir, 'graph.html');
let html = fs.readFileSync(htmlPath, 'utf8').replace(/\n?<!-- TICKET_EXECUTION_START -->[\s\S]*?<!-- TICKET_EXECUTION_END -->\n?/g, '\n');
const nodes = overlayNodes.map((n) => ({ id: n.id, label: n.label, color: '#d97706', size: 18,
  title: `${n.label}\nEvidence/context: ${n.source_file}`, _source_file: n.source_file, _file_type: n.file_type }));
const edges = overlayEdges.map((e, i) => ({ id: `ticket_execution_edge_${i}`, from: e.source, to: e.target,
  title: 'supported by execution evidence', color: '#d97706', dashes: true }));
const overlay = `\n<!-- TICKET_EXECUTION_START -->\n<script>\nfor (const n of ${JSON.stringify(nodes)}) { if (!nodesDS.get(n.id)) nodesDS.add(n); }\nedgesDS.add(${JSON.stringify(edges)});\n</script>\n<!-- TICKET_EXECUTION_END -->\n`;
html = html.replace('</body>', overlay + '</body>');
fs.writeFileSync(htmlPath, html);
console.log(`Injected ${context.executions.length} ticket execution record(s), ${overlayEdges.length} evidence links into graph.json and graph.html.`);
