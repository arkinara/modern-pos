import { Body, Controller, Get, Headers, HttpCode, Inject, Post, Req, Res } from '@nestjs/common';
import type { CookieOptions, Request, Response } from 'express';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { apiError } from '../common/api-error';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';
import {
  AuthUserProfile,
  MobileSessionResponse,
  WebSessionResponse,
  type SignInResult,
} from './auth.responses';
import type { AuthenticatedUser } from './auth.types';
import { AuthService } from './auth.service';
import { MobileLoginDto } from './dto/mobile-login.dto';
import { MobileRefreshDto } from './dto/mobile-refresh.dto';
import { WebLoginDto } from './dto/web-login.dto';

const REFRESH_COOKIE_PATH = '/v1/auth';

type RequestWithCookies = Request & {
  cookies?: Record<string, string | undefined>;
};

@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    @Inject(AUTH_CONFIG) private readonly config: AuthConfig,
  ) {}

  @Public()
  @Post('mobile/login')
  @HttpCode(200)
  async mobileLogin(
    @Body() dto: MobileLoginDto,
    @Req() request: Request,
  ): Promise<MobileSessionResponse> {
    const result = await this.auth.signInMobile(dto, { ip: request.ip ?? 'unknown' });
    return this.mobileResponse(result);
  }

  @Public()
  @Post('mobile/refresh')
  @HttpCode(200)
  async mobileRefresh(@Body() dto: MobileRefreshDto): Promise<MobileSessionResponse> {
    const result = await this.auth.refreshMobile(dto.refreshToken, dto.deviceId);
    return this.mobileResponse(result);
  }

  @Public()
  @Post('web/login')
  @HttpCode(200)
  async webLogin(
    @Body() dto: WebLoginDto,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ): Promise<WebSessionResponse> {
    const result = await this.auth.signInWeb(dto, { ip: request.ip ?? 'unknown' });
    this.setWebCookies(response, result);
    return this.webResponse(result);
  }

  @Public()
  @Post('web/refresh')
  @HttpCode(200)
  async webRefresh(
    @Req() request: RequestWithCookies,
    @Headers('x-csrf-token') csrfHeader: string | undefined,
    @Res({ passthrough: true }) response: Response,
  ): Promise<WebSessionResponse> {
    const refreshToken = request.cookies?.[this.config.refreshCookieName];
    const csrfCookie = request.cookies?.[this.config.csrfCookieName];

    if (!refreshToken) {
      throw apiError(401, 'INVALID_REFRESH_TOKEN', 'Refresh session is not valid');
    }

    if (!csrfHeader || !csrfCookie || csrfHeader !== csrfCookie) {
      throw apiError(403, 'CSRF_INVALID', 'CSRF token is missing or invalid');
    }

    const result = await this.auth.refreshWeb(refreshToken, csrfHeader);
    this.setWebCookies(response, result);
    return this.webResponse(result);
  }

  @Post('logout')
  @HttpCode(204)
  async logout(
    @CurrentUser() user: AuthenticatedUser,
    @Res({ passthrough: true }) response: Response,
  ): Promise<void> {
    await this.auth.signOut(user);
    this.clearWebCookies(response);
  }

  @Get('me')
  me(@CurrentUser() user: AuthenticatedUser): AuthUserProfile {
    return {
      id: user.id,
      email: user.email,
      role: user.role,
      outletIds: user.outletIds,
    };
  }

  private mobileResponse(result: SignInResult): MobileSessionResponse {
    return {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      expiresInSeconds: result.expiresInSeconds,
      user: result.user,
    };
  }

  private webResponse(result: SignInResult): WebSessionResponse {
    return {
      accessToken: result.accessToken,
      expiresInSeconds: result.expiresInSeconds,
      user: result.user,
    };
  }

  private refreshCookieOptions(result: SignInResult): CookieOptions {
    const maxAge = Math.max(0, result.refreshExpiresAt.getTime() - Date.now());
    return {
      httpOnly: true,
      secure: this.config.cookieSecure,
      sameSite: 'lax',
      path: REFRESH_COOKIE_PATH,
      maxAge,
      ...(this.config.cookieDomain ? { domain: this.config.cookieDomain } : {}),
    };
  }

  private csrfCookieOptions(result: SignInResult): CookieOptions {
    const maxAge = Math.max(0, result.refreshExpiresAt.getTime() - Date.now());
    return {
      httpOnly: false,
      secure: this.config.cookieSecure,
      sameSite: 'lax',
      path: '/',
      maxAge,
      ...(this.config.cookieDomain ? { domain: this.config.cookieDomain } : {}),
    };
  }

  private setWebCookies(response: Response, result: SignInResult): void {
    response.cookie(
      this.config.refreshCookieName,
      result.refreshToken,
      this.refreshCookieOptions(result),
    );

    if (result.csrfToken) {
      response.cookie(this.config.csrfCookieName, result.csrfToken, this.csrfCookieOptions(result));
    }
  }

  private clearWebCookies(response: Response): void {
    const base: CookieOptions = {
      httpOnly: true,
      secure: this.config.cookieSecure,
      sameSite: 'lax',
      path: REFRESH_COOKIE_PATH,
      ...(this.config.cookieDomain ? { domain: this.config.cookieDomain } : {}),
    };
    response.clearCookie(this.config.refreshCookieName, base);
    response.clearCookie(this.config.csrfCookieName, {
      ...base,
      httpOnly: false,
      path: '/',
    });
  }
}
