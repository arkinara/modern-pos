import type { Metadata } from 'next';
import { SignInForm } from '@/components/sign-in-form';

export const metadata: Metadata = { title: 'Sign in' };

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-12">
      <div className="w-full max-w-sm">
        <div className="mb-8">
          <p className="text-xs font-medium uppercase tracking-[0.18em] text-muted">Modern POS</p>
          <h1 className="mt-2 text-3xl font-semibold text-text">Sign in</h1>
          <p className="mt-2 text-sm text-muted">Access the owner back office for your outlet.</p>
        </div>
        <SignInForm />
      </div>
    </main>
  );
}
