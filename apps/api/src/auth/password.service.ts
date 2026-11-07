import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import argon2, { type HashOptions } from 'argon2';

// The argon2 package defaults to Argon2id when no type is supplied.
const ARGON2_OPTIONS: HashOptions = {
  memoryCost: 19_456,
  timeCost: 2,
  parallelism: 1,
};

@Injectable()
export class PasswordService implements OnModuleInit {
  private readonly logger = new Logger(PasswordService.name);
  private dummyHash = '';

  async onModuleInit(): Promise<void> {
    this.dummyHash = await this.hash('modern-pos-dummy-password');
  }

  async hash(password: string): Promise<string> {
    return argon2.hash(password, ARGON2_OPTIONS);
  }

  async verify(hash: string, password: string): Promise<boolean> {
    if (hash.length === 0) {
      return false;
    }

    try {
      return await argon2.verify(hash, password);
    } catch (error) {
      this.logger.warn(`Rejected malformed password hash: ${(error as Error).message}`);
      return false;
    }
  }

  /**
   * Performs a real Argon2id verification for unknown accounts so response
   * timing does not reveal whether an email exists.
   */
  async verifyDummy(password: string): Promise<void> {
    if (this.dummyHash === '') {
      this.dummyHash = await this.hash('modern-pos-dummy-password');
    }

    try {
      await argon2.verify(this.dummyHash, password);
    } catch {
      // The result is intentionally ignored.
    }
  }
}
