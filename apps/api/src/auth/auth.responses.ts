import type { Role } from '@prisma/client';

export interface AuthUserProfile {
  id: string;
  email: string;
  role: Role;
  outletIds: string[];
}

export interface SignInResult {
  accessToken: string;
  refreshToken: string;
  expiresInSeconds: number;
  refreshExpiresAt: Date;
  csrfToken?: string;
  user: AuthUserProfile;
}

export interface WebSessionResponse {
  accessToken: string;
  expiresInSeconds: number;
  user: AuthUserProfile;
}

export interface MobileSessionResponse extends WebSessionResponse {
  refreshToken: string;
}
