import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthConfigModule } from './auth-config.module';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { PasswordService } from './password.service';
import { SessionService } from './session.service';
import { SignInRateLimiter } from './sign-in-rate-limiter.service';
import { TokenService } from './token.service';

@Module({
  imports: [
    AuthConfigModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [AuthConfigModule],
      inject: [AUTH_CONFIG],
      useFactory: (config: AuthConfig) => ({
        secret: config.jwtSecret,
        signOptions: { issuer: config.jwtIssuer },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    PasswordService,
    TokenService,
    SessionService,
    SignInRateLimiter,
    JwtStrategy,
  ],
  exports: [AuthConfigModule, AuthService, SessionService],
})
export class AuthModule {}
