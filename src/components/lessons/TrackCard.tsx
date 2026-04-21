import Link from 'next/link';
import TrackIcon from './TrackIcon';
import ProgressBar from '@/components/ui/ProgressBar';
import type { TrackWithProgress } from '@/lib/types/database';

interface TrackCardProps {
  track: TrackWithProgress;
}

export default function TrackCard({ track }: TrackCardProps) {
  const progress =
    track.totalLessons > 0
      ? Math.round((track.completedLessons / track.totalLessons) * 100)
      : 0;
  const isDone = progress === 100 && track.totalLessons > 0;
  const hasContent = track.totalLessons > 0;

  return (
    <Link
      href={`/tracks/${track.slug}`}
      className="group block"
      aria-label={`Abrir track ${track.title}`}
    >
      <div
        className="relative overflow-hidden rounded-2xl border border-border bg-white p-5 shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:shadow-md active:scale-[0.99]"
      >
        {/* Color accent bar */}
        <div
          className="absolute inset-x-0 top-0 h-1"
          style={{ backgroundColor: track.color_hex }}
        />

        <div className="flex items-start gap-4">
          {/* Icon tile */}
          <div
            className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl shadow-sm"
            style={{
              backgroundColor: `${track.color_hex}15`,
              color: track.color_hex,
            }}
          >
            <TrackIcon name={track.icon_name} size={28} strokeWidth={2.2} />
          </div>

          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-2">
              <h3 className="truncate text-base font-bold text-text">
                {track.title}
              </h3>
              {track.is_required && (
                <span className="rounded-full bg-amber-100 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-amber-700">
                  Empieza aquí
                </span>
              )}
              {isDone && <span aria-hidden>✅</span>}
            </div>
            <p className="mt-1 text-sm text-text-secondary line-clamp-2">
              {track.description}
            </p>

            <div className="mt-3">
              {hasContent ? (
                <ProgressBar
                  progress={progress}
                  color="primary"
                  size="sm"
                  label={`${track.completedLessons}/${track.totalLessons} lecciones`}
                />
              ) : (
                <p className="text-xs font-medium text-text-secondary/70">
                  Próximamente — contenido en camino
                </p>
              )}
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
