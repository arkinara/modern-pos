import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';

@Injectable()
export class TokenService {
  /** Opaque, high-entropy credential returned to the client exactly once. */
  createOpaqueToken(): string {
    return randomBytes(32).toString('base64url');
  }

  createCsrfToken(): string {
    return randomBytes(24).toString('base64url');
  }

  createId(): string {
    return randomUUID();
  }

  /** Refresh tokens and CSRF tokens are persisted only as SHA-256 hashes. */
  hashToken(token: string): string {
    return createHash('sha256').update(token, 'utf8').digest('hex');
  }
}
