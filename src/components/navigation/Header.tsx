import Image from 'next/image';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import PapaLogo from '@/components/mascot/PapaLogo';

export default async function Header() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const displayName = user?.user_metadata?.full_name || 'Usuario';
  const avatarUrl = user?.user_metadata?.avatar_url;

  return (
    <header className="bg-white border-b border-border px-4 py-3 md:ml-64">
      <div className="flex items-center justify-between max-w-4xl mx-auto">
        <Link href="/dashboard" className="flex items-center gap-2 md:hidden">
          <PapaLogo size={32} />
          <h1 className="text-lg font-bold text-primary">IAlingo</h1>
        </Link>
        <div className="flex items-center gap-3">
          <span className="text-sm font-medium text-text-secondary hidden sm:block">
            {displayName}
          </span>
          {avatarUrl ? (
            <Image
              src={avatarUrl}
              alt={displayName}
              width={36}
              height={36}
              className="rounded-full ring-2 ring-primary/20"
            />
          ) : (
            <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center">
              <span className="text-sm font-bold text-primary">
                {displayName.charAt(0).toUpperCase()}
              </span>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
