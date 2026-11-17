import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const dir = path.dirname(fileURLToPath(import.meta.url));
const entries = fs.readdirSync(dir).filter((name) => /^ticket-\d+-context\.json$/.test(name))
  .map((name) => JSON.parse(fs.readFileSync(path.join(dir, name), 'utf8')));
const graphPath = path.join(dir, 'graph.json');
const graph = JSON.parse(fs.readFileSync(graphPath, 'utf8'));
const nodes = [];
const edges = [];
for (const entry of entries) {
  const id = `ticket_execution_${entry.ticket}`;
  // Replace only this ticket's root/edges. Preserve other ticket records and
  // shared file nodes so merging evidence does not drop existing relationships.
  graph.nodes = graph.nodes.filter((node) => node.id !== id);
  graph.links = graph.links.filter((edge) => !(edge._origin === 'ticket_execution' && edge.source === id));
  const root = { id, label: `#${entry.ticket}: ${entry.title}`, source_file: entry.evidence,
    file_type: 'documentation', _origin: 'ticket_execution', metadata: { kind: 'ticket_execution', ...entry } };
  graph.nodes.push(root); nodes.push(root);
  const byFile = new Map(graph.nodes.filter((node) => node.metadata?.kind === 'file').map((node) => [node.source_file, node]));
  for (const source of [entry.evidence, ...entry.sources]) {
    let node = byFile.get(source);
    if (!node) {
      node = { id: `execution_file_${source.replace(/[^a-zA-Z0-9]/g, '_')}`, label: path.basename(source),
        source_file: source, file_type: 'evidence', _origin: 'ticket_execution', metadata: { kind: 'file' } };
      graph.nodes.push(node); byFile.set(source, node);
    }
    if (!nodes.some((n) => n.id === node.id)) nodes.push(node);
    const edge = { source: id, target: node.id, relation: 'supported_by', confidence: 'EXPLICIT',
      _origin: 'ticket_execution', source_file: entry.evidence, weight: 1 };
    graph.links.push(edge); edges.push(edge);
  }
}
graph.graph.ticket_contexts = entries.map((entry) => `graphify-out/ticket-${entry.ticket}-context.json`);
graph.graph.ast_note = 'built_at_commit identifies the historical AST baseline; ticket_execution nodes are evidence overlays, not a full AST rebuild.';
const serialized = JSON.stringify(graph, null, 2).replace(/("(?:weight|confidence_score)": )(\d+)([,\n])/g, '$1$2.0$3');
fs.writeFileSync(graphPath, serialized + '\n');
const htmlPath = path.join(dir, 'graph.html');
let html = fs.readFileSync(htmlPath, 'utf8').replace(/\n?<!-- PER_TICKET_CONTEXT_START -->[\s\S]*?<!-- PER_TICKET_CONTEXT_END -->\n?/g, '\n');
const visualNodes = nodes.map((node) => ({ id: node.id, label: node.label, color: '#d97706', size: 18,
  title: `${node.label}\nEvidence/context: ${node.source_file}`, _source_file: node.source_file, _file_type: node.file_type }));
const visualEdges = edges.map((edge, i) => ({ id: `per_ticket_context_edge_${i}`, from: edge.source, to: edge.target,
  title: 'supported by execution evidence', color: '#d97706', dashes: true }));
const overlay = `\n<!-- PER_TICKET_CONTEXT_START -->\n<script>\nfor (const n of ${JSON.stringify(visualNodes)}) { if (!nodesDS.get(n.id)) nodesDS.add(n); }\nedgesDS.add(${JSON.stringify(visualEdges)});\n</script>\n<!-- PER_TICKET_CONTEXT_END -->\n`;
fs.writeFileSync(htmlPath, html.replace('</body>', overlay + '</body>'));
console.log(`Injected ${entries.length} ticket context(s), ${edges.length} evidence links; historical AST baseline preserved.`);
