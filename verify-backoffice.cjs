const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const html = fs.readFileSync('prototype.html', 'utf8');
const nodes = new Map(), handlers = {};
function node(selector) {
  if (!nodes.has(selector)) nodes.set(selector, {innerHTML:'',dataset:{},style:{setProperty(){}},classList:{toggle(){}},addEventListener(){},focus(){},contains(){return false},showModal(){this.open=true},close(){this.open=false},querySelector(){return node('summary')}});
  return nodes.get(selector);
}
const context = vm.createContext({document:{querySelector:node,body:node('body'),documentElement:node('html'),addEventListener(type,fn){(handlers[type]??=[]).push(fn)}},window:{addEventListener(type,fn){handlers[type]=[fn]}},location:{hash:'#cashier'},history:{pushState(){}},setTimeout(){},clearTimeout(){},Intl,Date,FormData:class{constructor(form){this.values=form.values}get(key){return this.values[key]}}});
vm.runInContext(html.match(/<script>([\s\S]*?)<\/script>/)[1],context);
const run = code => vm.runInContext(code,context);
assert.equal(run('page'),'menu');
assert.equal(run('typeof checkout'),'undefined');
assert.equal(run('typeof cashierScreen'),'undefined');
assert(!node('#nav').innerHTML.includes('Cashier'));
assert(!html.includes('id="mobile-order"'));
for(const page of ['menu','stock','reports','printers']) for(const state of ['ready','loading','empty','error']) {
 run(`screenState='${state}';navigate('${page}')`);
 assert(node('#main').innerHTML.length>100);
 assert(!/data-page="cashier"|data-action="checkout"|data-action="new-sale"/.test(node('#main').innerHTML));
}
run("navigate('cashier')");assert.equal(run('page'),'menu');
handlers.popstate[0]();assert.equal(run('page'),'menu');
run("screenState='ready';navigate('reports');showReceipt(sales[0])");
assert(node('#dialog').innerHTML.includes('Rp52.000'));
run("reportDate='2000-01-01';render()");assert(node('#main').innerHTML.includes('No recorded sales yet'));
run("editMenu('flat');adjustStock('milk');online=false;render()");assert.equal(node('#offline-banner').hidden,false);
const submit = form => handlers.submit[0]({preventDefault(){},target:form});
submit({id:'menu-form',dataset:{id:'flat'},values:{name:'Updated coffee',category:'Coffee','price-flat-r':'29000','price-flat-l':'33000'}});
assert.equal(run('products[0].name'),'Updated coffee');assert.equal(run('sales[0].lines[0].price'),28000);
submit({id:'stock-form',dataset:{id:'milk'},values:{quantity:'500',direction:'1',reason:'Delivery'}});
assert.equal(run("stock.find(s=>s.id==='milk').qty"),1700);
assert.equal(run('sales.length'),1);
console.log('Back-office regression checks passed: routes, four screens/states, receipt/report, menu edit, stock adjustment, offline banner.');
