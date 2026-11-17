const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const ledger = JSON.parse(fs.readFileSync(path.join(root, 'docs/implementation-evidence.json'), 'utf8'));
const expected = [...Array.from({ length: 30 }, (_, i) => i + 1), 56, 57, 58, 59, 60];
assert.deepEqual(ledger.issues.map((issue) => issue.number), expected);
for (const issue of ledger.issues) {
  assert.equal(issue.state, 'closed');
  assert.match(issue.commit, /^[a-f0-9]{40}$/);
  execFileSync('git', ['cat-file', '-e', `${issue.commit}^{commit}`], { cwd: root });
  execFileSync('git', ['merge-base', '--is-ancestor', issue.commit, ledger.mainCommit], { cwd: root });
  assert.ok(issue.pendingAcceptance.length > 0);
  for (const ticket of issue.pendingAcceptance) assert.ok(ticket >= 66 && ticket <= 78);
}

const files = [
  'README.md', 'ARCHITECTURE.md', 'HANDOFF.md', 'docs/implementation-evidence.md',
  'docs/known-limitations.md', 'docs/sale-reversal.md', 'docs/promotions-refunds.md',
  'docs/printer-validation.md',
];
let localLinks = 0;
for (const file of files) {
  const content = fs.readFileSync(path.join(root, file), 'utf8');
  for (const match of content.matchAll(/\[[^\]]*\]\(([^)\s]+)\)/g)) {
    const target = match[1];
    if (/^(https?:|#)/.test(target)) continue;
    const relative = decodeURIComponent(target.split('#')[0]);
    assert.ok(fs.existsSync(path.resolve(root, path.dirname(file), relative)), `${file} links to missing ${target}`);
    localLinks++;
  }
}
const readme = fs.readFileSync(path.join(root, 'README.md'), 'utf8');
assert.doesNotMatch(readme, /not a working POS|specifications awaiting implementation|services\/api\//);
const api = JSON.parse(fs.readFileSync(path.join(root, 'apps/api/package.json'), 'utf8'));
for (const match of readme.matchAll(/pnpm --filter @modern-pos\/api ([\w:-]+)/g)) {
  assert.ok(api.scripts[match[1]], `README references missing API script ${match[1]}`);
}
const limitations = fs.readFileSync(path.join(root, 'docs/known-limitations.md'), 'utf8');
assert.doesNotMatch(limitations, /Deferred to #20|LAN and USB printer transports \| Not implemented/);
console.log(`PASS evidence ledger with ${expected.length} closed issues and reachable commits`);
console.log(`PASS ${localLinks} local documentation links and README command references`);
console.log('PASS reconciled source-layout, transport and rollout claims');
