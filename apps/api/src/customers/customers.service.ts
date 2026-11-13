import { Injectable } from '@nestjs/common';
import { ChannelPaymentStatus, CustomerContactType } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import {
  CustomerCreateDto,
  CustomerListQueryDto,
  RetentionPolicyUpdateDto,
} from './dto/customer.dto';

const DAY_MS = 24 * 60 * 60 * 1000;

export interface CustomerResponse {
  id: string;
  outletId: string;
  name: string;
  email: string | null;
  phone: string | null;
  consentAt: string;
  consentSource: string;
  anonymizedAt: string | null;
  createdAt: string;
}

export interface CustomerListResponse {
  items: CustomerResponse[];
}

export interface RetentionPolicyResponse {
  outletId: string;
  customerRetentionDays: number;
  receiptRetentionDays: number;
  receiptLinkTtlMinutes: number;
  version: number;
  updatedAt: string | null;
  defaults: boolean;
}

export interface PurgeResponse {
  ranAt: string;
  customersAnonymised: number;
  receiptsPurged: number;
  policy: RetentionPolicyResponse;
}

function normaliseContact(
  contact: string,
  type: CustomerContactType,
): { normalised: string; email: string | null; phone: string | null } {
  const trimmed = contact.trim();

  if (type === CustomerContactType.EMAIL) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
      throw apiError(422, 'CUSTOMER_CONTACT_INVALID', 'Email contact is not a valid address');
    }
    const email = trimmed.toLowerCase();
    return { normalised: email, email, phone: null };
  }

  const phone = trimmed.replace(/[\s().-]/g, '');
  if (!/^\+?\d{7,20}$/.test(phone)) {
    throw apiError(422, 'CUSTOMER_CONTACT_INVALID', 'Phone contact is not a valid number');
  }
  return { normalised: phone.replace(/^\+/, ''), email: null, phone };
}

@Injectable()
export class CustomersService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    outletId: string,
    query: CustomerListQueryDto,
    user: AuthenticatedUser,
  ): Promise<CustomerListResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const search = query.search?.trim();
    const items = await this.prisma.customer.findMany({
      where: {
        outletId,
        businessId: user.businessId,
        ...(search
          ? {
              OR: [
                { name: { contains: search, mode: 'insensitive' } },
                { email: { contains: search, mode: 'insensitive' } },
                { phone: { contains: search } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: query.limit ?? 50,
    });

    return { items: items.map((item) => this.toResponse(item)) };
  }

  async get(
    outletId: string,
    customerId: string,
    user: AuthenticatedUser,
  ): Promise<CustomerResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const item = await this.prisma.customer.findFirst({
      where: { id: customerId, outletId, businessId: user.businessId },
    });

    if (!item) {
      throw apiError(404, 'NOT_FOUND', 'Customer not found');
    }

    return this.toResponse(item);
  }

  async create(
    outletId: string,
    dto: CustomerCreateDto,
    user: AuthenticatedUser,
  ): Promise<CustomerResponse> {
    await this.requireOutlet(outletId, user.businessId);

    if (!dto.consent) {
      throw apiError(
        422,
        'CUSTOMER_CONSENT_REQUIRED',
        'Customer records are opt-in and require explicit consent',
      );
    }

    const contact = normaliseContact(dto.contact, dto.contactType);
    const existing = await this.prisma.customer.findUnique({
      where: { outletId_contactNormalized: { outletId, contactNormalized: contact.normalised } },
    });

    if (existing) {
      throw apiError(409, 'CUSTOMER_EXISTS', 'A customer with this contact already exists');
    }

    const created = await this.prisma.customer.create({
      data: {
        businessId: user.businessId,
        outletId,
        name: dto.name.trim(),
        contactType: dto.contactType,
        contactNormalized: contact.normalised,
        email: contact.email,
        phone: contact.phone,
        consentAt: new Date(),
        consentSource: dto.consentSource,
      },
    });

    return this.toResponse(created);
  }

  async getPolicy(outletId: string, user: AuthenticatedUser): Promise<RetentionPolicyResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const policy = await this.prisma.customerRetentionPolicy.findUnique({ where: { outletId } });
    return this.toPolicy(outletId, policy);
  }

  async updatePolicy(
    outletId: string,
    dto: RetentionPolicyUpdateDto,
    user: AuthenticatedUser,
  ): Promise<RetentionPolicyResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const policy = await this.prisma.customerRetentionPolicy.upsert({
      where: { outletId },
      create: {
        businessId: user.businessId,
        outletId,
        customerRetentionDays: dto.customerRetentionDays,
        receiptRetentionDays: dto.receiptRetentionDays,
        receiptLinkTtlMinutes: dto.receiptLinkTtlMinutes,
      },
      update: {
        customerRetentionDays: dto.customerRetentionDays,
        receiptRetentionDays: dto.receiptRetentionDays,
        receiptLinkTtlMinutes: dto.receiptLinkTtlMinutes,
        version: { increment: 1 },
      },
    });

    return this.toPolicy(outletId, policy);
  }

  async purge(outletId: string, user: AuthenticatedUser): Promise<PurgeResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const policyRow = await this.prisma.customerRetentionPolicy.findUnique({ where: { outletId } });
    const policy = this.toPolicy(outletId, policyRow);
    const now = new Date();
    const customerCutoff = new Date(now.getTime() - policy.customerRetentionDays * DAY_MS);
    const receiptCutoff = new Date(now.getTime() - policy.receiptRetentionDays * DAY_MS);

    const expiredCustomers = await this.prisma.customer.findMany({
      where: {
        outletId,
        businessId: user.businessId,
        anonymizedAt: null,
        createdAt: { lt: customerCutoff },
      },
      select: { id: true },
    });

    let customersAnonymised = 0;
    for (const customer of expiredCustomers) {
      await this.prisma.customer.update({
        where: { id: customer.id },
        data: {
          name: 'Anonymised customer',
          email: null,
          phone: null,
          contactNormalized: `anon:${customer.id}`,
          anonymizedAt: now,
        },
      });
      customersAnonymised += 1;
    }

    const receipts = await this.prisma.digitalReceipt.deleteMany({
      where: {
        outletId,
        businessId: user.businessId,
        OR: [{ issuedAt: { lt: receiptCutoff } }, { expiresAt: { lt: now } }],
      },
    });

    return {
      ranAt: now.toISOString(),
      customersAnonymised,
      receiptsPurged: receipts.count,
      policy,
    };
  }

  private async requireOutlet(outletId: string, businessId: string): Promise<void> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private toResponse(item: {
    id: string;
    outletId: string;
    name: string;
    email: string | null;
    phone: string | null;
    consentAt: Date;
    consentSource: string;
    anonymizedAt: Date | null;
    createdAt: Date;
  }): CustomerResponse {
    return {
      id: item.id,
      outletId: item.outletId,
      name: item.name,
      email: item.email,
      phone: item.phone,
      consentAt: item.consentAt.toISOString(),
      consentSource: item.consentSource,
      anonymizedAt: item.anonymizedAt?.toISOString() ?? null,
      createdAt: item.createdAt.toISOString(),
    };
  }

  private toPolicy(
    outletId: string,
    policy: {
      customerRetentionDays: number;
      receiptRetentionDays: number;
      receiptLinkTtlMinutes: number;
      version: number;
      updatedAt: Date;
    } | null,
  ): RetentionPolicyResponse {
    return policy
      ? {
          outletId,
          customerRetentionDays: policy.customerRetentionDays,
          receiptRetentionDays: policy.receiptRetentionDays,
          receiptLinkTtlMinutes: policy.receiptLinkTtlMinutes,
          version: policy.version,
          updatedAt: policy.updatedAt.toISOString(),
          defaults: false,
        }
      : {
          outletId,
          customerRetentionDays: 365,
          receiptRetentionDays: 90,
          receiptLinkTtlMinutes: 1440,
          version: 0,
          updatedAt: null,
          defaults: true,
        };
  }
}
