import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';
import { createClient } from '@/lib/supabase/server';
import { buildTracksWithProgress } from '@/lib/utils/lessons';
import TrackIcon from '@/components/lessons/TrackIcon';
import ModuleCard from '@/components/lessons/ModuleCard';
import type { LessonStatus, ModuleWithLessons } from '@/lib/types/database';

interface TrackDetailPageProps {
  params: Promise<{ slug: string }>;
}

const LEVEL_LABEL: Record<number, string> = {
  1: 'Principiante',
  2: 'Intermedio',
  3: 'Avanzado',
};

export default async function TrackDetailPage({ params }: TrackDetailPageProps) {
  const { slug } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const [{ data: tracks }, { data: modules }, { data: lessons }, { data: progress }] =
    await Promise.all([
      supabase.from('tracks').select('*').order('order_index', { ascending: true }),
      supabase.from('modules').select('*'),
      supabase.from('lessons').select('*'),
      supabase
        .from('lesson_progress')
        .select('lesson_id, status')
        .eq('user_id', user!.id),
    ]);

  const progressMap = new Map(
    (progress || []).map((p) => [p.lesson_id, p.status as LessonStatus])
  );

  const tracksWithProgress = buildTracksWithProgress(
    tracks || [],
    modules || [],
    lessons || [],
    progressMap
  );

  const track = tracksWithProgress.find((t) => t.slug === slug);
  if (!track) notFound();

  const percent =
    track.totalLessons > 0
      ? Math.round((track.completedLessons / track.totalLessons) * 100)
      : 0;

  // Group modules by level (preserving order within level)
  const modulesByLevel = new Map<number, ModuleWithLessons[]>();
  for (const mod of track.modules) {
    const arr = modulesByLevel.get(mod.level) || [];
    arr.push(mod);
    modulesByLevel.set(mod.level, arr);
  }
  const levels = Array.from(modulesByLevel.keys()).sort((a, b) => a - b);

  return (
    <div className="space-y-5">
      <Link
        href="/lessons"
        className="inline-flex items-center gap-1.5 text-sm font-medium text-text-secondary transition-colors hover:text-primary"
      >
        <ArrowLeft size={16} />
        Todos los tracks
      </Link>

      {/* Hero */}
      <div
        className="relative overflow-hidden rounded-2xl p-6 text-white shadow-lg"
        style={{
          background: `linear-gradient(135deg, ${track.color_hex} 0%, ${track.color_hex}CC 100%)`,
        }}
      >
        <div className="flex items-start gap-4">
          <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-white/20 backdrop-blur-sm">
            <TrackIcon name={track.icon_name} size={32} strokeWidth={2.2} />
          </div>
          <div className="min-w-0 flex-1">
            <h1 className="text-2xl font-bold">{track.title}</h1>
            <p className="mt-1 text-sm text-white/90">{track.description}</p>
          </div>
        </div>

        {track.totalLessons > 0 && (
          <div className="mt-5">
            <div className="mb-1.5 flex items-center justify-between text-xs font-medium text-white/90">
              <span>Progreso del track</span>
              <span>{percent}%</span>
            </div>
            <div className="h-2 overflow-hidden rounded-full bg-white/20">
              <div
                className="h-full rounded-full bg-white transition-all duration-500"
                style={{ width: `${percent}%` }}
              />
            </div>
            <p className="mt-2 text-xs text-white/80">
              {track.completedLessons} de {track.totalLessons} lecciones
            </p>
          </div>
        )}
      </div>

      {track.totalLessons === 0 ? (
        <div className="rounded-2xl border border-border bg-white p-6 text-center">
          <p className="text-base font-semibold text-text">Contenido en camino 🛠️</p>
          <p className="mt-1 text-sm text-text-secondary">
            Los módulos ya están definidos. Las lecciones están en producción y llegarán pronto.
          </p>
          {track.modules.length > 0 && (
            <div className="mt-5 space-y-2 text-left">
              {track.modules.map((mod) => (
                <div
                  key={mod.id}
                  className="flex items-center gap-3 rounded-xl border border-border bg-gray-50 px-4 py-3"
                >
                  <div
                    className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg"
                    style={{
                      backgroundColor: `${track.color_hex}18`,
                      color: track.color_hex,
                    }}
                  >
                    <TrackIcon name={mod.icon_name} size={18} strokeWidth={2.2} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-text">{mod.title}</p>
                    <p className="truncate text-xs text-text-secondary">{mod.description}</p>
                  </div>
                  <span className="shrink-0 rounded-full bg-white px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-text-secondary">
                    {LEVEL_LABEL[mod.level] ?? `N${mod.level}`}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : (
        levels.map((level) => (
          <section key={`level-${level}`} className="space-y-3">
            <div className="flex items-center gap-3">
              <h2 className="text-base font-bold text-text">
                {LEVEL_LABEL[level] ?? `Nivel ${level}`}
              </h2>
              <div className="h-px flex-1 bg-border" />
            </div>
            <div className="space-y-3">
              {modulesByLevel.get(level)!.map((mod, index) => (
                <ModuleCard
                  key={mod.id}
                  module={mod}
                  defaultOpen={index === 0 && level === levels[0]}
                />
              ))}
            </div>
          </section>
        ))
      )}
    </div>
  );
}
