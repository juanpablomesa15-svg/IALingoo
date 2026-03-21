import { createClient } from '@/lib/supabase/server';
import AchievementBadge from '@/components/achievements/AchievementBadge';
import type { AchievementWithStatus } from '@/lib/types/database';
import { Trophy } from 'lucide-react';

export default async function AchievementsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // Fetch all achievements
  const { data: achievements } = await supabase
    .from('achievements')
    .select('*')
    .order('condition_value', { ascending: true });

  // Fetch unlocked achievements
  const { data: unlocked } = await supabase
    .from('achievements_unlocked')
    .select('achievement_id, unlocked_at')
    .eq('user_id', user!.id);

  const unlockedMap = new Map(
    (unlocked || []).map((u) => [u.achievement_id, u.unlocked_at])
  );

  const achievementsWithStatus: AchievementWithStatus[] = (achievements || []).map((a) => ({
    ...a,
    unlocked_at: unlockedMap.get(a.id) || null,
  }));

  // Sort: unlocked first, then by condition_value
  achievementsWithStatus.sort((a, b) => {
    if (a.unlocked_at && !b.unlocked_at) return -1;
    if (!a.unlocked_at && b.unlocked_at) return 1;
    return 0;
  });

  const unlockedCount = achievementsWithStatus.filter((a) => a.unlocked_at).length;
  const totalCount = achievementsWithStatus.length;

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold text-text">Logros</h1>
        <p className="text-text-secondary mt-1">Tu colección de medallas</p>
      </div>

      {/* Summary */}
      <div className="bg-gradient-to-br from-amber-50 to-yellow-50 border border-amber-200/50 rounded-2xl p-5 flex items-center gap-4">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-amber-400 to-yellow-500 flex items-center justify-center shadow-lg shadow-amber-400/20">
          <Trophy className="w-7 h-7 text-white" />
        </div>
        <div>
          <p className="text-3xl font-bold text-amber-600">
            {unlockedCount}
            <span className="text-lg text-amber-400 font-medium"> / {totalCount}</span>
          </p>
          <p className="text-sm text-amber-600/80">
            {unlockedCount === 0
              ? '¡Completa lecciones para ganar logros!'
              : unlockedCount === totalCount
                ? '¡Los tienes todos! Increíble.'
                : '¡Sigue así para desbloquear más!'}
          </p>
        </div>
      </div>

      {/* Achievements grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
        {achievementsWithStatus.map((achievement) => (
          <AchievementBadge key={achievement.id} achievement={achievement} />
        ))}
      </div>
    </div>
  );
}
