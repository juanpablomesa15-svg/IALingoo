'use client';

import Link from 'next/link';
import { Play, Clock, Sparkles } from 'lucide-react';

interface NextLessonCardProps {
  lessonId: number;
  lessonTitle: string;
  moduleTitle: string;
  estimatedMinutes: number;
  xpReward: number;
}

export default function NextLessonCard({
  lessonId,
  lessonTitle,
  moduleTitle,
  estimatedMinutes,
  xpReward,
}: NextLessonCardProps) {
  return (
    <Link href={`/lessons/${lessonId}`} className="block">
      <div className="bg-gradient-to-br from-primary to-blue-600 rounded-2xl p-5 text-white shadow-lg shadow-primary/25 hover:shadow-xl hover:scale-[1.01] active:scale-[0.99] transition-all duration-200">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <Sparkles size={16} className="text-blue-200" />
              <span className="text-sm font-medium text-blue-200">
                Siguiente lección
              </span>
            </div>
            <h3 className="text-lg font-bold mb-1">{lessonTitle}</h3>
            <p className="text-sm text-blue-200">{moduleTitle}</p>

            <div className="flex items-center gap-4 mt-4">
              <div className="flex items-center gap-1.5">
                <Clock size={14} className="text-blue-200" />
                <span className="text-sm text-blue-100">{estimatedMinutes} min</span>
              </div>
              <div className="flex items-center gap-1.5">
                <StarIcon size={14} className="text-amber-300" />
                <span className="text-sm text-blue-100">+{xpReward} XP</span>
              </div>
            </div>
          </div>

          <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center ml-4 shrink-0">
            <Play size={24} className="text-white ml-0.5" />
          </div>
        </div>
      </div>
    </Link>
  );
}

function StarIcon({ size, className }: { size: number; className: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="currentColor"
      className={className}
    >
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  );
}
