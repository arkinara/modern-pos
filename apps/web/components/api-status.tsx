'use client';

import { useQuery } from '@tanstack/react-query';
import { Badge } from '@/components/ui/badge';
import { api } from '@/lib/api';

export function ApiStatus() {
  const { data, isPending, isError } = useQuery({
    queryKey: ['health'],
    queryFn: () => api.getHealth(),
    retry: 1,
    refetchInterval: 30_000,
  });

  if (isPending) {
    return <Badge tone="neutral">Checking API</Badge>;
  }

  if (isError) {
    return <Badge tone="danger">API unreachable</Badge>;
  }

  return <Badge tone="success">API {data.status}</Badge>;
}
