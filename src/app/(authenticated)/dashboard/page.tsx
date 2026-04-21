import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import StreakCard from '@/components/dashboard/StreakCard';
import XPBar from '@/components/dashboard/XPBar';
import NextLessonCard from '@/components/dashboard/NextLessonCard';
import DashboardMascot from '@/components/dashboard/DashboardMascot';
import TrackIcon from '@/components/lessons/TrackIcon';
import { buildTracksWithProgress, getNextLesson } from '@/lib/utils/lessons';
import { BookOpen, CheckCircle2, ExternalLink, GraduationCap, ArrowRight } from 'lucide-react';
import type { LessonStatus } from '@/lib/types/database';

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const [
    { data: profile },
    { data: streak },
    { data: tracks },
    { data: modules },
    { data: lessons },
    { data: completedLessons },
  ] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', user!.id).single(),
    supabase.from('streaks').select('*').eq('user_id', user!.id).single(),
    supabase.from('tracks').select('*').order('order_index', { ascending: true }),
    supabase.from('modules').select('*'),
    supabase.from('lessons').select('*'),
    supabase
      .from('lesson_progress')
      .select('lesson_id, status')
      .eq('user_id', user!.id),
  ]);

  const progressMap = new Map(
    (completedLessons || []).map((p) => [p.lesson_id, p.status as LessonStatus])
  );

  const tracksWithProgress = buildTracksWithProgress(
    tracks || [],
    modules || [],
    lessons || [],
    progressMap
  );

  // Next lesson across all tracks (required track first, then by order)
  const orderedModules = tracksWithProgress.flatMap((t) => t.modules);
  const nextLesson = getNextLesson(orderedModules);
  const nextLessonModule = nextLesson
    ? orderedModules.find((m) => m.lessons.some((l) => l.id === nextLesson.id))
    : null;
  const nextLessonTrack = nextLessonModule
    ? tracksWithProgress.find((t) => t.id === nextLessonModule.track_id)
    : null;

  const totalLessons = tracksWithProgress.reduce((sum, t) => sum + t.totalLessons, 0);
  const completedLessonsCount = progressMap.size === 0
    ? 0
    : Array.from(progressMap.values()).filter((s) => s === 'completed').length;

  const displayName = user?.user_metadata?.full_name?.split(' ')[0] || 'Usuario';

  // Three featured tracks for the dashboard (skip required + show most interesting)
  const featuredTracks = tracksWithProgress.filter((t) => !t.is_required).slice(0, 3);

  return (
    <div className="space-y-5">
      <DashboardMascot
        currentStreak={streak?.current_streak ?? 0}
        lastActivityDate={streak?.last_activity_date ?? null}
        lessonsCompleted={completedLessonsCount}
        userName={displayName}
      />

      <div>
        <h1 className="text-2xl font-bold text-text">
          ¡Hola, {displayName}! 👋
        </h1>
        <p className="text-text-secondary mt-1">
          {completedLessonsCount === 0
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

      <StreakCard
        currentStreak={streak?.current_streak ?? 0}
        longestStreak={streak?.longest_streak ?? 0}
      />

      <XPBar
        totalXP={profile?.total_xp ?? 0}
        currentLevel={profile?.current_level ?? 1}
      />

      {/* Next lesson OR tracks teaser when no content yet */}
      {nextLesson && nextLessonModule ? (
        <NextLessonCard
          lessonId={nextLesson.id}
          lessonTitle={nextLesson.title}
          moduleTitle={
            nextLessonTrack
              ? `${nextLessonTrack.title} · ${nextLessonModule.title}`
              : nextLessonModule.title
          }
          estimatedMinutes={nextLesson.estimated_minutes}
          xpReward={nextLesson.xp_reward}
        />
      ) : (
        <Link
          href="/lessons"
          className="block rounded-2xl bg-gradient-to-br from-primary to-blue-600 p-5 text-white shadow-lg shadow-primary/25 transition-all duration-200 hover:shadow-xl hover:scale-[1.01] active:scale-[0.99]"
        >
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-blue-200">Explora los tracks</p>
              <p className="mt-1 text-lg font-bold">Elige tu camino de aprendizaje</p>
              <p className="mt-1 text-sm text-blue-200">
                7 tracks: Claude, visual, web, n8n, datos, agentes y negocio
              </p>
            </div>
            <ArrowRight size={28} className="shrink-0 text-white" />
          </div>
        </Link>
      )}

      {/* Featured tracks */}
      {featuredTracks.length > 0 && (
        <section className="space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold uppercase tracking-wide text-text-secondary">
              Descubre tracks
            </h2>
            <Link
              href="/lessons"
              className="text-xs font-semibold text-primary hover:underline"
            >
              Ver todos
            </Link>
          </div>
          <div className="grid grid-cols-3 gap-2">
            {featuredTracks.map((track) => (
              <Link
                key={track.id}
                href={`/tracks/${track.slug}`}
                className="group flex flex-col items-center gap-2 rounded-2xl border border-border bg-white p-3 text-center transition-all hover:-translate-y-0.5 hover:shadow-md"
              >
                <div
                  className="flex h-10 w-10 items-center justify-center rounded-xl"
                  style={{
                    backgroundColor: `${track.color_hex}18`,
                    color: track.color_hex,
                  }}
                >
                  <TrackIcon name={track.icon_name} size={20} strokeWidth={2.4} />
                </div>
                <p className="line-clamp-2 text-xs font-semibold text-text">
                  {track.title}
                </p>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* Quick stats */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white border border-border rounded-2xl p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-success/10 flex items-center justify-center">
            <CheckCircle2 className="w-5 h-5 text-success" />
          </div>
          <div>
            <p className="text-xl font-bold text-text">{completedLessonsCount}</p>
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
