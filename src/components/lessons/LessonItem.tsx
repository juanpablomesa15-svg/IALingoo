'use client';

import Link from 'next/link';
import { CheckCircle2, Circle, Lock, Clock, Star, RotateCcw } from 'lucide-react';
import type { LessonWithProgress } from '@/lib/types/database';

interface LessonItemProps {
  lesson: LessonWithProgress;
  index: number;
  isLast: boolean;
  isAvailable: boolean;
}

export default function LessonItem({ lesson, index, isLast, isAvailable }: LessonItemProps) {
  const isCompleted = lesson.status === 'completed';
  const isLocked = !isCompleted && !isAvailable;
  const isClickable = isAvailable || isCompleted;

  const content = (
    <div
      className={`flex items-center gap-4 px-5 py-4 ${
        !isLast ? 'border-b border-border/50' : ''
      } ${isLocked ? 'opacity-50' : ''} ${
        isClickable ? 'hover:bg-blue-50/50 cursor-pointer' : ''
      } transition-colors`}
    >
      {/* Status icon */}
      <div className="shrink-0">
        {isCompleted ? (
          <CheckCircle2 className="w-7 h-7 text-success" fill="currentColor" strokeWidth={0} />
        ) : isLocked ? (
          <div className="w-7 h-7 rounded-full bg-gray-200 flex items-center justify-center">
            <Lock className="w-3.5 h-3.5 text-gray-400" />
          </div>
        ) : (
          <Circle className="w-7 h-7 text-primary" strokeWidth={2} />
        )}
      </div>

      {/* Lesson info */}
      <div className="flex-1 min-w-0">
        <h4 className={`font-semibold text-sm ${
          isCompleted ? 'text-text-secondary line-through' : isLocked ? 'text-gray-400' : 'text-text'
        }`}>
          {index}. {lesson.title}
        </h4>
        <div className="flex items-center gap-3 mt-1">
          <div className="flex items-center gap-1">
            <Clock size={12} className="text-text-secondary" />
            <span className="text-xs text-text-secondary">{lesson.estimated_minutes} min</span>
          </div>
          <div className="flex items-center gap-1">
            <Star size={12} className="text-accent" fill="currentColor" />
            <span className="text-xs text-text-secondary">+{lesson.xp_reward} XP</span>
          </div>
        </div>
      </div>

      {/* Action indicator */}
      {isAvailable && (
        <div className="shrink-0 w-8 h-8 rounded-full bg-primary flex items-center justify-center">
          <svg width="12" height="14" viewBox="0 0 12 14" fill="white">
            <polygon points="0,0 12,7 0,14" />
          </svg>
        </div>
      )}
      {!isAvailable && isCompleted && (
        <div
          className="shrink-0 w-8 h-8 rounded-full bg-success/10 flex items-center justify-center"
          title="Repasar lección"
        >
          <RotateCcw size={14} className="text-success" strokeWidth={2.5} />
        </div>
      )}
    </div>
  );

  if (isClickable) {
    const href = isCompleted && !isAvailable
      ? `/lessons/${lesson.id}?review=1`
      : `/lessons/${lesson.id}`;
    return (
      <Link href={href}>
        {content}
      </Link>
    );
  }

  return content;
}
