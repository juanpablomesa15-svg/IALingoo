'use client';

import { Star } from 'lucide-react';
import { getXPForCurrentLevel, getLevelTitle } from '@/lib/utils/xp';
import ProgressBar from '@/components/ui/ProgressBar';
import CountUp from '@/components/effects/CountUp';

interface XPBarProps {
  totalXP: number;
  currentLevel: number;
}

export default function XPBar({ totalXP, currentLevel }: XPBarProps) {
  const { currentLevelXP, nextLevelXP, progress } = getXPForCurrentLevel(totalXP);
  const levelTitle = getLevelTitle(currentLevel);

  return (
    <div className="bg-white border border-border rounded-2xl p-5">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2.5">
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
            <Star className="w-5 h-5 text-primary" fill="currentColor" />
          </div>
          <div>
            <p className="text-sm font-medium text-text-secondary">Nivel {currentLevel}</p>
            <p className="text-base font-bold text-text">{levelTitle}</p>
          </div>
        </div>
        <div className="text-right">
          <p className="text-2xl font-bold text-primary">
            <CountUp to={totalXP} durationMs={1400} />
          </p>
          <p className="text-xs text-text-secondary">XP total</p>
        </div>
      </div>

      <ProgressBar
        progress={progress}
        color="primary"
        size="md"
        label={`${currentLevelXP} / ${nextLevelXP} XP`}
      />
    </div>
  );
}
