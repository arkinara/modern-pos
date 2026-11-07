import type { Metadata } from 'next';
import { AuthProvider } from '@/lib/auth';
import { Providers } from './providers';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'Modern POS Back Office',
    template: '%s · Modern POS',
  },
  description: 'Owner back office for the Modern POS platform.',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <AuthProvider>{children}</AuthProvider>
        </Providers>
      </body>
    </html>
  );
}
