const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const root=__dirname;
const api=JSON.parse(fs.readFileSync(path.join(root,'API.openapi.json'),'utf8'));
const errors=[],ids=new Set();
function walk(value){if(!value||typeof value!=='object')return;if(value.$ref){let target=api;for(const piece of value.$ref.slice(2).split('/'))target=target?.[piece];if(!target)errors.push('Unresolved reference '+value.$ref)}if(value.required&&value.properties)for(const r of value.required)if(!value.properties[r])errors.push('Unknown required field '+r);Object.values(value).forEach(walk)}
walk(api);
let operations=0;
for(const [route,methods] of Object.entries(api.paths))for(const [method,op]of Object.entries(methods)){operations++;if(ids.has(op.operationId))errors.push('Duplicate operation ID');ids.add(op.operationId);for(const m of route.matchAll(/\{([^}]+)\}/g))if(!op.parameters.some(p=>p.in==='path'&&p.name===m[1]&&p.required))errors.push('Missing required path parameter '+m[1]);if(!Object.keys(op.responses).some(s=>/^2/.test(s)))errors.push('No success response '+op.operationId)}
const html=fs.readFileSync(path.join(root,'prototype.html'),'utf8');
for(const m of html.matchAll(/<script>([\s\S]*?)<\/script>/g))new vm.Script(m[1]);
const tokens=JSON.parse(fs.readFileSync(path.join(root,'design-tokens.json'),'utf8'));
function luminance(hex){const rgb=hex.slice(1).match(/../g).map(n=>parseInt(n,16)/255).map(n=>n<=.04045?n/12.92:((n+.055)/1.055)**2.4);return rgb[0]*.2126+rgb[1]*.7152+rgb[2]*.0722}
const pairs=[['text','surface'],['textMuted','surface'],['textMuted','canvas'],['surface','accent'],['accent','accentSoft'],['danger','dangerSoft'],['warning','warningSoft']];
const contrast=pairs.map(([a,b])=>{let x=luminance(tokens.color[a]),y=luminance(tokens.color[b]),ratio=(Math.max(x,y)+.05)/(Math.min(x,y)+.05);if(ratio<4.5)errors.push('Contrast below 4.5 '+a+'/'+b);return `${a}/${b}: ${ratio.toFixed(2)}:1`});
const output={date:'2026-11-07',contract:{paths:Object.keys(api.paths).length,operations,schemas:Object.keys(api.components.schemas).length,checks:['JSON parsing','local $ref resolution','required schema properties','unique operation IDs','required path parameters','success response presence']},prototype:{scriptSyntax:'valid'},contrast,errors,limitations:['This structural contract check is not a complete OpenAPI meta-schema validator.','No backend, Flutter application, database or real printer is implemented by these deliverables.','Browser interaction and responsive checks are recorded separately in HANDOFF.md.']};
fs.writeFileSync(path.join(root,'VALIDATION.json'),JSON.stringify(output,null,2)+'\n');
console.log(JSON.stringify(output,null,2));if(errors.length)process.exitCode=1;

