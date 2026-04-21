import { createClient } from '@/lib/supabase/server';
import StreakCard from '@/components/dashboard/StreakCard';
import XPBar from '@/components/dashboard/XPBar';
import NextLessonCard from '@/components/dashboard/NextLessonCard';
import DashboardMascot from '@/components/dashboard/DashboardMascot';
import { BookOpen, CheckCircle2, ExternalLink, GraduationCap } from 'lucide-react';

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // Fetch profile data
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user!.id)
    .single();

  // Fetch streak data
  const { data: streak } = await supabase
    .from('streaks')
    .select('*')
    .eq('user_id', user!.id)
    .single();

  // Fetch lesson progress to find next lesson
  const { data: completedLessons } = await supabase
    .from('lesson_progress')
    .select('lesson_id')
    .eq('user_id', user!.id)
    .eq('status', 'completed');

  const completedLessonIds = new Set((completedLessons || []).map(lp => lp.lesson_id));

  // Fetch all lessons ordered
  const { data: lessons } = await supabase
    .from('lessons')
    .select('*, modules:module_id(title, is_locked)')
    .order('module_id', { ascending: true })
    .order('order_index', { ascending: true });

  // Find next available lesson
  const nextLesson = (lessons || []).find(
    (l) => !completedLessonIds.has(l.id) && !(l.modules as { is_locked: boolean })?.is_locked
  );

  // Count total lessons in unlocked modules
  const totalLessons = (lessons || []).filter(
    (l) => !(l.modules as { is_locked: boolean })?.is_locked
  ).length;

  const displayName = user?.user_metadata?.full_name?.split(' ')[0] || 'Usuario';

  return (
    <div className="space-y-5">
      {/* Mascot */}
      <DashboardMascot
        currentStreak={streak?.current_streak ?? 0}
        lastActivityDate={streak?.last_activity_date ?? null}
        lessonsCompleted={completedLessonIds.size}
        userName={displayName}
      />

      {/* Greeting */}
      <div>
        <h1 className="text-2xl font-bold text-text">
          ¡Hola, {displayName}! 👋
        </h1>
        <p className="text-text-secondary mt-1">
          {completedLessonIds.size === 0
            ? '¡Empecemos tu aventura con la IA!'
            : '¡Sigue aprendiendo hoy!'}
        </p>
      </div>

      {/* Lab10.ai Banner */}
      <a
        href="https://lab10.ai/"
        target="_blank"
        rel="noopener noreferrer"
        className="group block bg-gradient-to-r from-violet-600 to-indigo-600 rounded-2xl p-5 shadow-lg shadow-violet-500/20 hover:shadow-xl hover:shadow-violet-500/30 transition-all duration-300 hover:scale-[1.01] active:scale-[0.99]"
      >
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <GraduationCap size={18} className="text-violet-200" />
              <p className="font-bold text-white">Lab10.ai</p>
            </div>
            <p className="text-sm text-violet-200">Clases y recursos avanzados de IA</p>
            <p className="text-xs text-violet-300/70 mt-1.5">
              Comienza por los módulos de principiante →
            </p>
          </div>
          <ExternalLink size={20} className="text-white/30 group-hover:text-white/50 transition-colors" />
        </div>
      </a>

      {/* Streak */}
      <StreakCard
        currentStreak={streak?.current_streak ?? 0}
        longestStreak={streak?.longest_streak ?? 0}
      />

      {/* XP & Level */}
      <XPBar
        totalXP={profile?.total_xp ?? 0}
        currentLevel={profile?.current_level ?? 1}
      />

      {/* Next Lesson */}
      {nextLesson && (
        <NextLessonCard
          lessonId={nextLesson.id}
          lessonTitle={nextLesson.title}
          moduleTitle={(nextLesson.modules as { title: string })?.title ?? ''}
          estimatedMinutes={nextLesson.estimated_minutes}
          xpReward={nextLesson.xp_reward}
        />
      )}

      {/* Quick stats */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white border border-border rounded-2xl p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-success/10 flex items-center justify-center">
            <CheckCircle2 className="w-5 h-5 text-success" />
          </div>
          <div>
            <p className="text-xl font-bold text-text">{completedLessonIds.size}</p>
            <p className="text-xs text-text-secondary">Completadas</p>
          </div>
        </div>
        <div className="bg-white border border-border rounded-2xl p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
            <BookOpen className="w-5 h-5 text-primary" />
          </div>
          <div>
            <p className="text-xl font-bold text-text">{totalLessons}</p>
            <p className="text-xs text-text-secondary">Total lecciones</p>
          </div>
        </div>
      </div>
    </div>
  );
}
