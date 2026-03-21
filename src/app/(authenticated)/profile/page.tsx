import { createClient } from '@/lib/supabase/server';
import Image from 'next/image';
import { getLevelTitle } from '@/lib/utils/xp';
import { formatStreak } from '@/lib/utils/streak';
import LogoutButton from './LogoutButton';
import NotificationToggle from '@/components/notifications/NotificationToggle';
import { Star, Flame, BookOpen, Trophy, TrendingUp } from 'lucide-react';

export default async function ProfilePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user!.id)
    .single();

  const { data: streak } = await supabase
    .from('streaks')
    .select('*')
    .eq('user_id', user!.id)
    .single();

  const { data: completedLessons } = await supabase
    .from('lesson_progress')
    .select('id')
    .eq('user_id', user!.id)
    .eq('status', 'completed');

  const { data: unlockedAchievements } = await supabase
    .from('achievements_unlocked')
    .select('id')
    .eq('user_id', user!.id);

  const { data: pushSub } = await supabase
    .from('push_subscriptions')
    .select('is_active')
    .eq('user_id', user!.id)
    .single();

  const notificationsActive = pushSub?.is_active ?? false;

  const displayName = profile?.display_name || user?.user_metadata?.full_name || 'Usuario';
  const avatarUrl = profile?.avatar_url || user?.user_metadata?.avatar_url;
  const levelTitle = getLevelTitle(profile?.current_level ?? 1);

  const stats = [
    {
      icon: Star,
      label: 'XP Total',
      value: (profile?.total_xp ?? 0).toLocaleString(),
      color: 'text-primary',
      bg: 'bg-primary/10',
    },
    {
      icon: TrendingUp,
      label: 'Nivel',
      value: `${profile?.current_level ?? 1} - ${levelTitle}`,
      color: 'text-indigo-500',
      bg: 'bg-indigo-50',
    },
    {
      icon: Flame,
      label: 'Racha actual',
      value: formatStreak(streak?.current_streak ?? 0),
      color: 'text-amber-500',
      bg: 'bg-amber-50',
    },
    {
      icon: Flame,
      label: 'Racha más larga',
      value: formatStreak(streak?.longest_streak ?? 0),
      color: 'text-orange-500',
      bg: 'bg-orange-50',
    },
    {
      icon: BookOpen,
      label: 'Lecciones completadas',
      value: `${completedLessons?.length ?? 0}`,
      color: 'text-success',
      bg: 'bg-success/10',
    },
    {
      icon: Trophy,
      label: 'Logros desbloqueados',
      value: `${unlockedAchievements?.length ?? 0}`,
      color: 'text-accent',
      bg: 'bg-accent/10',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Profile header */}
      <div className="bg-white border border-border rounded-2xl p-6 flex flex-col items-center text-center">
        {avatarUrl ? (
          <Image
            src={avatarUrl}
            alt={displayName}
            width={80}
            height={80}
            className="rounded-full ring-4 ring-primary/20 mb-4"
          />
        ) : (
          <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mb-4">
            <span className="text-3xl font-bold text-primary">
              {displayName.charAt(0).toUpperCase()}
            </span>
          </div>
        )}
        <h1 className="text-xl font-bold text-text">{displayName}</h1>
        <p className="text-sm text-text-secondary mt-1">{user?.email}</p>
        <div className="mt-3 px-4 py-1.5 bg-primary/10 rounded-full">
          <span className="text-sm font-semibold text-primary">
            Nivel {profile?.current_level ?? 1} · {levelTitle}
          </span>
        </div>
      </div>

      {/* Stats */}
      <div className="space-y-3">
        <h2 className="text-lg font-bold text-text">Estadísticas</h2>
        <div className="grid grid-cols-1 gap-3">
          {stats.map((stat) => {
            const Icon = stat.icon;
            return (
              <div
                key={stat.label}
                className="bg-white border border-border rounded-2xl p-4 flex items-center gap-4"
              >
                <div className={`w-11 h-11 rounded-xl ${stat.bg} flex items-center justify-center`}>
                  <Icon className={`w-5 h-5 ${stat.color}`} />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-text-secondary">{stat.label}</p>
                  <p className="text-lg font-bold text-text">{stat.value}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Notifications */}
      <div className="space-y-3">
        <h2 className="text-lg font-bold text-text">Notificaciones</h2>
        <NotificationToggle userId={user!.id} initialActive={notificationsActive} />
      </div>

      {/* Logout */}
      <LogoutButton />
    </div>
  );
}
