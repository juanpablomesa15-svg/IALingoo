'use client';

import { Flame } from 'lucide-react';
import { formatStreak, getStreakMessage } from '@/lib/utils/streak';

interface StreakCardProps {
  currentStreak: number;
  longestStreak: number;
}

export default function StreakCard({ currentStreak, longestStreak }: StreakCardProps) {
  const isActive = currentStreak > 0;
  const isStrong = currentStreak >= 3;
  const isBlazing = currentStreak >= 7;
  const isLegendary = currentStreak >= 30;

  const flameClass = isBlazing
    ? 'streak-flame-strong'
    : isActive
      ? 'streak-flame'
      : '';

  const iconSize = isBlazing ? 36 : 32;

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
          {/* Pulsing ring for blazing streaks */}
          {isBlazing && (
            <div className="absolute inset-0 rounded-2xl streak-ring pointer-events-none" />
          )}

          <div
            className={`relative w-16 h-16 rounded-2xl flex items-center justify-center overflow-visible ${
              isBlazing
                ? 'bg-gradient-to-br from-orange-500 via-red-500 to-amber-400 shadow-lg shadow-orange-500/40'
                : isActive
                  ? 'bg-gradient-to-br from-amber-400 to-orange-500 shadow-lg shadow-amber-400/30'
                  : 'bg-gray-200'
            }`}
          >
            {/* Embers rising for blazing */}
            {isBlazing && (
              <>
                <span
                  className="absolute left-1/2 bottom-2 w-1 h-1 rounded-full bg-amber-200 streak-ember"
                  style={{ animationDelay: '0s' }}
                />
                <span
                  className="absolute left-[35%] bottom-2 w-1 h-1 rounded-full bg-orange-200 streak-ember"
                  style={{ animationDelay: '0.4s' }}
                />
                <span
                  className="absolute left-[65%] bottom-2 w-0.5 h-0.5 rounded-full bg-yellow-200 streak-ember"
                  style={{ animationDelay: '0.8s' }}
                />
              </>
            )}

            <Flame
              className={`${isActive ? 'text-white' : 'text-gray-400'} ${flameClass}`}
              size={iconSize}
              fill={isStrong ? 'currentColor' : 'none'}
              strokeWidth={isStrong ? 1.5 : 2}
            />
          </div>

          {/* Milestone badges */}
          {isLegendary ? (
            <span className="absolute -top-1 -right-1 text-lg drop-shadow">👑</span>
          ) : isBlazing ? (
            <span className="absolute -top-1 -right-1 text-lg drop-shadow">⚡</span>
          ) : null}
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
