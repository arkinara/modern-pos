'use client';

import { LogOut } from 'lucide-react';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/lib/auth';

export function UserMenu() {
  const { user, signOut } = useAuth();
  const [pending, setPending] = useState(false);

  if (!user) {
    return null;
  }

  async function handleSignOut(): Promise<void> {
    setPending(true);
    try {
      await signOut();
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="flex flex-col gap-2">
      <div className="min-w-0">
        <p className="truncate text-sm font-medium text-surface">{user.email}</p>
        <p className="text-xs uppercase tracking-[0.16em] text-ink-muted">{user.role}</p>
      </div>
      <Button
        type="button"
        variant="ghost"
        size="sm"
        className="justify-start text-nav-text hover:bg-surface/10 hover:text-surface"
        onClick={handleSignOut}
        disabled={pending}
      >
        <LogOut aria-hidden="true" className="size-4" strokeWidth={1.75} />
        {pending ? 'Signing out' : 'Sign out'}
      </Button>
    </div>
  );
}
