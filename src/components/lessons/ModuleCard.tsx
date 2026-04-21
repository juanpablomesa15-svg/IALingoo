'use client';

import { useState } from 'react';
import { ChevronDown, Lock } from 'lucide-react';
import TrackIcon from './TrackIcon';
import LessonItem from './LessonItem';
import ProgressBar from '@/components/ui/ProgressBar';
import type { ModuleWithLessons } from '@/lib/types/database';

interface ModuleCardProps {
  module: ModuleWithLessons;
  defaultOpen?: boolean;
}

export default function ModuleCard({ module, defaultOpen = false }: ModuleCardProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);
  const totalLessons = module.lessons.length;
  const progress = totalLessons > 0 ? (module.completedCount / totalLessons) * 100 : 0;
  const isLocked = module.is_locked;
  const accent = module.color_hex ?? '#6366F1';

  return (
    <div
      className={`rounded-2xl border overflow-hidden transition-all duration-200 ${
        isLocked
          ? 'bg-gray-50 border-gray-200 opacity-75'
          : 'bg-white border-border shadow-sm hover:shadow-md'
      }`}
    >
      {/* Module header */}
      <button
        onClick={() => !isLocked && setIsOpen(!isOpen)}
        disabled={isLocked}
        className={`w-full flex items-center gap-4 p-5 text-left transition-colors ${
          isLocked ? 'cursor-not-allowed' : 'hover:bg-gray-50/50'
        }`}
      >
        <div
          className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0"
          style={
            isLocked
              ? { backgroundColor: '#E5E7EB', color: '#9CA3AF' }
              : { backgroundColor: `${accent}18`, color: accent }
          }
        >
          {isLocked ? (
            <Lock className="w-5 h-5" />
          ) : (
            <TrackIcon name={module.icon_name} size={24} strokeWidth={2.2} />
          )}
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h3 className={`font-bold text-base ${isLocked ? 'text-gray-400' : 'text-text'}`}>
              {module.title}
            </h3>
            {progress === 100 && (
              <span className="text-sm">✅</span>
            )}
          </div>
          <p className={`text-sm mt-0.5 ${isLocked ? 'text-gray-400' : 'text-text-secondary'}`}>
            {module.description}
          </p>
          {!isLocked && totalLessons > 0 && (
            <div className="mt-2.5">
              <ProgressBar
                progress={progress}
                color="success"
                size="sm"
                label={`${module.completedCount}/${totalLessons} lecciones`}
              />
            </div>
          )}
          {!isLocked && totalLessons === 0 && (
            <p className="mt-2 text-xs font-medium text-text-secondary/70">
              Lecciones en producción
            </p>
          )}
        </div>

        {!isLocked && totalLessons > 0 && (
          <ChevronDown
            className={`w-5 h-5 text-gray-400 shrink-0 transition-transform duration-200 ${
              isOpen ? 'rotate-180' : ''
            }`}
          />
        )}
      </button>

      {/* Lessons list */}
      {isOpen && !isLocked && totalLessons > 0 && (
        <div className="border-t border-border">
          {module.lessons.map((lesson, index) => {
            const isAvailable =
              lesson.status !== 'completed' &&
              (index === 0 || module.lessons[index - 1].status === 'completed');

            return (
              <LessonItem
                key={lesson.id}
                lesson={lesson}
                index={index + 1}
                isLast={index === module.lessons.length - 1}
                isAvailable={isAvailable}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}
