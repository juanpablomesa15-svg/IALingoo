'use client';

import { useState } from 'react';
import { ChevronDown, Lock, Sparkles, Hammer, Zap, Bot, Rocket, type LucideIcon } from 'lucide-react';

const iconMap: Record<string, LucideIcon> = {
  sparkles: Sparkles,
  hammer: Hammer,
  zap: Zap,
  bot: Bot,
  rocket: Rocket,
};
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
          className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 text-2xl ${
            isLocked ? 'bg-gray-200' : 'bg-primary/10'
          }`}
        >
          {isLocked ? <Lock className="w-5 h-5 text-gray-400" /> : (() => {
            const Icon = iconMap[module.icon_name];
            return Icon ? <Icon className="w-6 h-6 text-primary" /> : <span className="text-2xl">{module.icon_name}</span>;
          })()}
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
        </div>

        {!isLocked && (
          <ChevronDown
            className={`w-5 h-5 text-gray-400 shrink-0 transition-transform duration-200 ${
              isOpen ? 'rotate-180' : ''
            }`}
          />
        )}
      </button>

      {/* Lessons list */}
      {isOpen && !isLocked && (
        <div className="border-t border-border">
          {module.lessons.map((lesson, index) => {
            // A lesson is available if:
            // - it's the first lesson and not completed, OR
            // - the previous lesson is completed and this one isn't
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
