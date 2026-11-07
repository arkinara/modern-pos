'use client';

import { ApiError } from '@modern-pos/api-client';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { useAuth } from '@/lib/auth';

export function SignInForm() {
  const { status, signIn } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/menu');
    }
  }, [router, status]);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault();
    setError(null);
    setPending(true);

    try {
      await signIn(email.trim(), password);
      router.replace('/menu');
    } catch (caught) {
      if (caught instanceof ApiError && caught.status === 401) {
        setError('Email or password is incorrect.');
      } else if (caught instanceof ApiError && caught.status === 429) {
        setError('Too many sign-in attempts. Wait a few minutes and try again.');
      } else {
        setError('Unable to sign in. Check the API connection and try again.');
      }
    } finally {
      setPending(false);
    }
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <form className="flex flex-col gap-5" onSubmit={handleSubmit} noValidate>
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="email">
              Email
            </label>
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="username"
              required
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className="h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted"
              placeholder="owner@example.test"
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="password">
              Password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted"
            />
          </div>

          {error ? (
            <p
              role="alert"
              className="rounded-control bg-danger-soft px-3 py-2 text-sm text-danger"
            >
              {error}
            </p>
          ) : null}

          <Button type="submit" disabled={pending || email.trim() === '' || password === ''}>
            {pending ? 'Signing in' : 'Sign in'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
