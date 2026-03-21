export type LessonStatus = 'not_started' | 'in_progress' | 'completed';

export interface Profile {
  id: string;
  display_name: string;
  avatar_url: string | null;
  total_xp: number;
  current_level: number;
  created_at: string;
  last_active_at: string;
}

export interface Module {
  id: number;
  title: string;
  description: string;
  order_index: number;
  icon_name: string;
  is_locked: boolean;
}

export interface Lesson {
  id: number;
  module_id: number;
  title: string;
  content_md: string | null;
  order_index: number;
  xp_reward: number;
  practical_task: string | null;
  estimated_minutes: number;
}

export interface LessonProgress {
  id: number;
  user_id: string;
  lesson_id: number;
  status: LessonStatus;
  started_at: string | null;
  completed_at: string | null;
}

export interface Quiz {
  id: number;
  lesson_id: number;
  question: string;
  options: string[];
  correct_index: number;
  order_index: number;
  explanation: string;
}

export interface QuizAttempt {
  id: number;
  user_id: string;
  quiz_id: number;
  selected_index: number;
  is_correct: boolean;
  attempted_at: string;
}

export interface Streak {
  user_id: string;
  current_streak: number;
  longest_streak: number;
  last_activity_date: string;
}

export interface Achievement {
  id: number;
  slug: string;
  title: string;
  description: string;
  icon_name: string;
  condition_type: string;
  condition_value: number;
}

export interface AchievementUnlocked {
  id: number;
  user_id: string;
  achievement_id: number;
  unlocked_at: string;
}

export interface PushSubscription {
  id: number;
  user_id: string;
  subscription_data: Record<string, unknown>;
  is_active: boolean;
}

// Joined types for UI
export interface AchievementWithStatus extends Achievement {
  unlocked_at: string | null;
}

export interface LessonWithProgress extends Lesson {
  status: LessonStatus;
}

export interface ModuleWithLessons extends Module {
  lessons: LessonWithProgress[];
  completedCount: number;
}

// RPC response types
export interface CompleteLessonResult {
  xp_earned: number;
  total_xp: number;
  lessons_completed: number;
  streak: number;
}

export interface UpdateStreakResult {
  current_streak: number;
  longest_streak: number;
  streak_broken: boolean;
}
