// Requires a built API. Exercises compiled startup and real HTTP routing with
// synthetic provider I/O; no database or actual provider credentials are used.
const assert = require('node:assert/strict');
const path = require('node:path');
const { createRequire } = require('node:module');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const apiRequire = createRequire(path.join(root, 'apps/api/package.json'));
apiRequire('reflect-metadata');
const { Module, ValidationPipe } = apiRequire('@nestjs/common');
const { NestFactory } = apiRequire('@nestjs/core');
const { SandboxProviderController } = require('../apps/api/dist/payments/sandbox-provider.controller');
const { PaymentConfigService } = require('../apps/api/dist/payments/payment-config.service');
const { MockPaymentProviderService } = require('../apps/api/dist/payments/mock-payment-provider.service');
const { ApiExceptionFilter } = require('../apps/api/dist/common/api-exception.filter');

async function main() {
  const result = spawnSync(process.execPath, [path.join(root, 'apps/api/dist/main.js')], {
    cwd: path.join(root, 'apps/api'), encoding: 'utf8', timeout: 15000,
    env: { ...process.env, NODE_ENV: 'production', JWT_SECRET: 'DO-NOT-LOG-STARTUP-TOKEN',
      COOKIE_SECURE: 'false', WEB_ORIGIN: '*', PAYMENT_PROVIDER: 'mock', PAYMENT_MODE: 'sandbox',
      PAYMENT_SANDBOX_ENABLED: 'true', PAYMENT_PROVIDER_API_KEY: 'DO-NOT-LOG-PROVIDER-KEY',
      PAYMENT_WEBHOOK_SECRET: 'DO-NOT-LOG-WEBHOOK', DATABASE_URL: 'postgresql://unused:unused@127.0.0.1:1/unused' },
  });
  const output = (result.stdout ?? '') + (result.stderr ?? '');
  assert.equal(result.status, 1);
  assert.match(output, /Invalid runtime configuration:/);
  assert.doesNotMatch(output, /DO-NOT-LOG|Prisma|listening/);
  console.log('PASS compiled unsafe startup: exit 1 before DB/listener; diagnostics omit submitted secrets');

  const keys = ['NODE_ENV', 'PAYMENT_PROVIDER', 'PAYMENT_MODE', 'PAYMENT_SANDBOX_ENABLED'];
  const saved = Object.fromEntries(keys.map((key) => [key, process.env[key]]));
  try {
    for (const [label, env, expected] of [
      ['production forced MOCK', { NODE_ENV: 'production', PAYMENT_PROVIDER: 'mock', PAYMENT_MODE: 'sandbox', PAYMENT_SANDBOX_ENABLED: 'true' }, [404,404,404]],
      ['production QRIS', { NODE_ENV: 'production', PAYMENT_PROVIDER: 'qris', PAYMENT_MODE: 'live', PAYMENT_SANDBOX_ENABLED: 'false' }, [404,404,404]],
      ['production manual recording', { NODE_ENV: 'production', PAYMENT_PROVIDER: 'manual', PAYMENT_SANDBOX_ENABLED: 'false' }, [404,404,404]],
      ['local no opt-in', { NODE_ENV: 'test', PAYMENT_PROVIDER: 'mock', PAYMENT_MODE: 'sandbox', PAYMENT_SANDBOX_ENABLED: 'false' }, [404,404,404]],
      ['local explicit opt-in', { NODE_ENV: 'test', PAYMENT_PROVIDER: 'mock', PAYMENT_MODE: 'sandbox', PAYMENT_SANDBOX_ENABLED: 'true' }, [201,200,201]],
    ]) {
      Object.assign(process.env, env);
      let calls = 0;
      const payment = { providerRef:'synthetic-ref', amountMinor:1000n, currency:'IDR', status:'PENDING' };
      const provider = { createPayment:async()=>{calls++;return payment;}, fetchPayment:async()=>{calls++;return payment;},
        createEvent:async()=>{calls++;return { eventId:'synthetic-event' };} };
      class SandboxFixtureModule {}
      Module({ controllers:[SandboxProviderController], providers:[
        {provide:PaymentConfigService,useValue:new PaymentConfigService()},
        {provide:MockPaymentProviderService,useValue:provider},
      ] })(SandboxFixtureModule);
      // Bypass only the startup gate in this fixture to prove the independent
      // production route gate still protects a mistakenly selected MOCK mode.
      const app = await NestFactory.create(SandboxFixtureModule,{logger:false});
      try {
        app.setGlobalPrefix('v1');
        app.useGlobalPipes(new ValidationPipe({transform:true,whitelist:true,forbidNonWhitelisted:true}));
        app.useGlobalFilters(new ApiExceptionFilter());
        await app.listen(0,'127.0.0.1');
        const base = await app.getUrl();
        const create = await fetch(base+'/v1/sandbox/provider/payments', {method:'POST',headers:{'Content-Type':'application/json'},
          body:JSON.stringify({idempotencyKey:'11111111-1111-4111-8111-111111111111',amountMinor:1000,currency:'IDR'})});
        const read = await fetch(base+'/v1/sandbox/provider/payments/synthetic-ref');
        const event = await fetch(base+'/v1/sandbox/provider/payments/synthetic-ref/events', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({type:'payment.succeeded'})});
        assert.deepEqual([create.status,read.status,event.status],expected);
        assert.equal(calls,expected[0]===404?0:3);
        const invalidCreate = await fetch(base+'/v1/sandbox/provider/payments', {method:'POST',headers:{'Content-Type':'application/json'},body:'{}'});
        const invalidEvent = await fetch(base+'/v1/sandbox/provider/payments/synthetic-ref/events', {method:'POST',headers:{'Content-Type':'application/json'},body:'{}'});
        assert.deepEqual([invalidCreate.status,invalidEvent.status],expected[0]===404?[404,404]:[400,400]);
        assert.equal(calls,expected[0]===404?0:3);
        await Promise.all([invalidCreate.arrayBuffer(),invalidEvent.arrayBuffer()]);
        await Promise.all([create.arrayBuffer(),read.arrayBuffer(),event.arrayBuffer()]);
        console.log(`PASS HTTP ${label}: ${expected.join('/')} with ${calls} provider calls`);
      } finally { await app.close(); }
    }
  } finally {
    for(const [key,value] of Object.entries(saved)) {
      if(value===undefined)delete process.env[key];else process.env[key]=value;
    }
  }
  console.log('PASS 6 startup/HTTP scenarios; 25 endpoint assertions including invalid payloads; synthetic provider I/O only');
}
main().catch((error)=>{console.error(error);process.exitCode=1;});
