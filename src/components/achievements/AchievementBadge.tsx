'use client';

import { Lock } from 'lucide-react';
import type { AchievementWithStatus } from '@/lib/types/database';

interface AchievementBadgeProps {
  achievement: AchievementWithStatus;
}

const iconMap: Record<string, string> = {
  first_lesson: '📖',
  first_quiz: '✏️',
  streak_3: '🔥',
  streak_7: '⚡',
  streak_30: '💎',
  lessons_5: '📚',
  lessons_10: '🎓',
  lessons_24: '🏅',
  module_1: '🌟',
  module_2: '🛠️',
  module_3: '⚙️',
  module_4: '🤖',
  module_5: '🚀',
  xp_500: '💰',
  xp_2000: '👑',
  quiz_perfect: '🎯',
};

export default function AchievementBadge({ achievement }: AchievementBadgeProps) {
  const isUnlocked = !!achievement.unlocked_at;
  const emoji = iconMap[achievement.slug] || '🏆';

  return (
    <div
      className={`relative rounded-2xl border p-4 flex flex-col items-center text-center transition-all duration-300 ${
        isUnlocked
          ? 'bg-white border-accent/30 shadow-sm hover:shadow-md hover:scale-[1.02]'
          : 'bg-gray-50 border-gray-200'
      }`}
    >
      {/* Badge icon */}
      <div
        className={`w-14 h-14 rounded-2xl flex items-center justify-center text-3xl mb-3 ${
          isUnlocked
            ? 'bg-accent/10'
            : 'bg-gray-200'
        }`}
      >
        {isUnlocked ? (
          emoji
        ) : (
          <Lock className="w-6 h-6 text-gray-400" />
        )}
      </div>

      {/* Title */}
      <h3
        className={`font-bold text-sm leading-tight mb-1 ${
          isUnlocked ? 'text-text' : 'text-gray-400'
        }`}
      >
        {achievement.title}
      </h3>

      {/* Description */}
      <p
        className={`text-xs leading-snug ${
          isUnlocked ? 'text-text-secondary' : 'text-gray-400'
        }`}
      >
        {achievement.description}
      </p>

      {/* Unlocked date */}
      {isUnlocked && achievement.unlocked_at && (
        <p className="text-xs text-accent font-medium mt-2">
          {new Date(achievement.unlocked_at).toLocaleDateString('es-ES', {
            day: 'numeric',
            month: 'short',
          })}
        </p>
      )}

      {/* Glow effect for unlocked */}
      {isUnlocked && (
        <div className="absolute inset-0 rounded-2xl bg-accent/5 pointer-events-none" />
      )}
    </div>
  );
}
