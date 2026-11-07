import { Role, SessionPlatform } from '@prisma/client';

export interface AccessTokenPayload {
  sub: string;
  sid: string;
  typ: 'access';
  iat?: number;
  exp?: number;
}

export interface AuthenticatedUser {
  id: string;
  businessId: string;
  email: string;
  role: Role;
  outletId: string | null;
  outletIds: string[];
  sessionId: string;
}

export interface SessionUser {
  id: string;
  businessId: string;
  outletId: string | null;
  email: string;
  role: Role;
  active: boolean;
  passwordHash: string;
}

export interface IssuedSession {
  sessionId: string;
  refreshToken: string;
  expiresAt: Date;
  platform: SessionPlatform;
}

export interface SessionResponseUser {
  id: string;
  email: string;
  role: Role;
  outletIds: string[];
}
