import { createClient } from '@/lib/supabase/server';
import TrackCard from '@/components/lessons/TrackCard';
import { buildTracksWithProgress } from '@/lib/utils/lessons';
import type { LessonStatus } from '@/lib/types/database';

export default async function LessonsPage() {
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

  const requiredTrack = tracksWithProgress.find((t) => t.is_required);
  const freeTracks = tracksWithProgress.filter((t) => !t.is_required);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text">Aprende IA</h1>
        <p className="mt-1 text-text-secondary">
          Elige tu camino. Cada track es independiente — ve al que más te interese.
        </p>
      </div>

      {requiredTrack && (
        <section className="space-y-3">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-text-secondary">
            Empieza por acá
          </h2>
          <TrackCard track={requiredTrack} />
        </section>
      )}

      {freeTracks.length > 0 && (
        <section className="space-y-3">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-text-secondary">
            Especialízate
          </h2>
          <div className="grid gap-3 sm:grid-cols-2">
            {freeTracks.map((track) => (
              <TrackCard key={track.id} track={track} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
