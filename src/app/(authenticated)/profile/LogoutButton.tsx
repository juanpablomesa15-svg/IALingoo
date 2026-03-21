'use client';

import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { LogOut } from 'lucide-react';

export default function LogoutButton() {
  const router = useRouter();

  const handleLogout = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  return (
    <button
      onClick={handleLogout}
      className="w-full flex items-center justify-center gap-2 bg-white border border-red-200 text-red-500 font-semibold py-3.5 px-6 rounded-2xl hover:bg-red-50 active:scale-[0.98] transition-all duration-200"
    >
      <LogOut size={18} />
      Cerrar sesión
    </button>
  );
}
