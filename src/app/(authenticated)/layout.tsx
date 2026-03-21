import BottomNav from '@/components/navigation/BottomNav';
import Header from '@/components/navigation/Header';
import NotificationPrompt from '@/components/notifications/NotificationPrompt';
import { createClient } from '@/lib/supabase/server';

export default async function AuthenticatedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <BottomNav />

      {/* Main content area */}
      <main className="md:ml-64 pb-24 md:pb-8">
        <div className="max-w-4xl mx-auto px-4 py-6">
          {children}
        </div>
      </main>

      {/* Notification prompt (shows once for new users) */}
      {user && <NotificationPrompt userId={user.id} />}
    </div>
  );
}
