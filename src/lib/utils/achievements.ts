import type { Achievement, AchievementWithStatus } from '@/lib/types/database';

interface UserStats {
  lessonsCompleted: number;
  totalXP: number;
  currentStreak: number;
  quizzesCorrectFirstTry: number;
  modulesCompleted: number[];
  hasCompletedQuiz: boolean;
}

/**
 * Checks which achievements should be newly unlocked based on current user stats.
 * Returns only achievements that are NOT already unlocked.
 */
export function checkNewAchievements(
  allAchievements: Achievement[],
  alreadyUnlocked: Set<number>,
  stats: UserStats
): Achievement[] {
  const newlyUnlocked: Achievement[] = [];

  for (const achievement of allAchievements) {
    if (alreadyUnlocked.has(achievement.id)) continue;

    const shouldUnlock = evaluateAchievement(achievement, stats);
    if (shouldUnlock) {
      newlyUnlocked.push(achievement);
    }
  }

  return newlyUnlocked;
}

function evaluateAchievement(achievement: Achievement, stats: UserStats): boolean {
  switch (achievement.condition_type) {
    case 'first_lesson':
      return stats.lessonsCompleted >= 1;

    case 'lessons_completed':
      return stats.lessonsCompleted >= achievement.condition_value;

    case 'total_xp':
      return stats.totalXP >= achievement.condition_value;

    case 'streak_days':
      return stats.currentStreak >= achievement.condition_value;

    case 'module_completed':
      return stats.modulesCompleted.includes(achievement.condition_value);

    case 'first_quiz':
      return stats.hasCompletedQuiz;

    case 'quizzes_perfect':
      return stats.quizzesCorrectFirstTry >= achievement.condition_value;

    default:
      return false;
  }
}

/**
 * Sorts achievements: unlocked first (by date desc), then locked (by condition_value asc).
 */
export function sortAchievements(achievements: AchievementWithStatus[]): AchievementWithStatus[] {
  return [...achievements].sort((a, b) => {
    if (a.unlocked_at && !b.unlocked_at) return -1;
    if (!a.unlocked_at && b.unlocked_at) return 1;
    if (a.unlocked_at && b.unlocked_at) {
      return new Date(b.unlocked_at).getTime() - new Date(a.unlocked_at).getTime();
    }
    return a.condition_value - b.condition_value;
  });
}
