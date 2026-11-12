import Link from 'next/link';

const links = [
  { href: '/shifts', label: 'Shifts' },
  { href: '/attendance', label: 'Attendance' },
  { href: '/permissions', label: 'Permissions' },
  { href: '/audit', label: 'Audit search' },
];

export function OperationsLinks() {
  return (
    <nav aria-label="Staff operations" className="flex flex-wrap gap-2">
      {links.map((link) => (
        <Link
          key={link.href}
          href={link.href}
          className="inline-flex min-h-9 items-center rounded-control border border-control bg-surface px-3 text-sm font-medium text-text transition-colors hover:bg-surface-muted"
        >
          {link.label}
        </Link>
      ))}
    </nav>
  );
}
