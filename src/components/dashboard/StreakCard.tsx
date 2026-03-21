'use client';

import { Flame } from 'lucide-react';
import { formatStreak, getStreakMessage } from '@/lib/utils/streak';

interface StreakCardProps {
  currentStreak: number;
  longestStreak: number;
}

export default function StreakCard({ currentStreak, longestStreak }: StreakCardProps) {
  return (
    <div className="bg-gradient-to-br from-amber-50 to-orange-50 border border-amber-200/50 rounded-2xl p-5">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-amber-700 mb-1">Racha diaria</p>
          <div className="flex items-baseline gap-1.5">
            <span className="text-4xl font-bold text-amber-600">
              {currentStreak}
            </span>
            <span className="text-lg text-amber-500 font-medium">
              {currentStreak === 1 ? 'día' : 'días'}
            </span>
          </div>
          <p className="text-sm text-amber-600/80 mt-1">
            {getStreakMessage(currentStreak)}
          </p>
        </div>
        <div className="relative">
          <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${
            currentStreak > 0
              ? 'bg-gradient-to-br from-amber-400 to-orange-500 shadow-lg shadow-amber-400/30'
              : 'bg-gray-200'
          }`}>
            <Flame
              className={currentStreak > 0 ? 'text-white' : 'text-gray-400'}
              size={32}
            />
          </div>
          {currentStreak >= 7 && (
            <span className="absolute -top-1 -right-1 text-lg">⚡</span>
          )}
        </div>
      </div>
      {longestStreak > 0 && (
        <p className="text-xs text-amber-600/60 mt-3 pt-3 border-t border-amber-200/40">
          Racha más larga: {formatStreak(longestStreak)}
        </p>
      )}
    </div>
  );
}
