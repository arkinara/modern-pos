import 'dotenv/config';
import { type INestApplication, RequestMethod, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { RuntimeConfigurationError, validateRuntimeConfig } from './config/runtime-config';

export async function bootstrap(
  createApp: () => Promise<INestApplication> = () =>
    NestFactory.create(AppModule, { rawBody: true }),
): Promise<void> {
  const runtime = validateRuntimeConfig();
  const app = await createApp();

  app.use(cookieParser());
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  );
  app.useGlobalFilters(new ApiExceptionFilter());

  app.setGlobalPrefix('v1', {
    exclude: [{ path: 'health', method: RequestMethod.GET }],
  });

  const allowedOrigins = runtime.allowedOrigins;

  app.enableCors({
    origin: allowedOrigins.length > 0 ? allowedOrigins : true,
    credentials: true,
    exposedHeaders: ['Content-Disposition'],
  });

  app.enableShutdownHooks();

  const port = Number(process.env.PORT ?? 4000);
  await app.listen(port);
  console.log(`Modern POS API listening on http://localhost:${port}`);
}

if (require.main === module) {
  void bootstrap().catch((error: unknown) => {
    console.error(
      error instanceof RuntimeConfigurationError ? error.message : 'API startup failed',
    );
    process.exitCode = 1;
  });
}
