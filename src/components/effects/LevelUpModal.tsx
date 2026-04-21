'use client';

import { useEffect, useState } from 'react';
import PapaMascot from '@/components/mascot/PapaMascot';
import Confetti from '@/components/effects/Confetti';
import { sounds } from '@/lib/utils/sounds';
import { getLevelTitle } from '@/lib/utils/xp';

interface LevelUpModalProps {
  level: number;
  onDismiss?: () => void;
  autoDismissMs?: number;
}

export default function LevelUpModal({
  level,
  onDismiss,
  autoDismissMs = 3800,
}: LevelUpModalProps) {
  const [phase, setPhase] = useState<'enter' | 'visible' | 'leaving'>('enter');

  useEffect(() => {
    sounds.levelUp();
    const t1 = setTimeout(() => setPhase('visible'), 50);
    const t2 = setTimeout(() => setPhase('leaving'), autoDismissMs - 400);
    const t3 = setTimeout(() => onDismiss?.(), autoDismissMs);
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
    };
  }, [autoDismissMs, onDismiss]);

  const title = getLevelTitle(level);

  return (
    <div
      className={`fixed inset-0 z-[200] flex items-center justify-center bg-slate-950/75 backdrop-blur-sm transition-opacity duration-400 ${
        phase === 'visible' ? 'opacity-100' : 'opacity-0'
      }`}
      onClick={onDismiss}
    >
      <Confetti duration={autoDismissMs} />
      <div
        className={`relative flex flex-col items-center gap-4 px-8 py-10 transition-all duration-500 ${
          phase === 'visible' ? 'scale-100 translate-y-0' : 'scale-90 translate-y-6'
        }`}
      >
        {/* Radial glow backdrop */}
        <div
          className="absolute inset-0 -z-10 blur-3xl"
          style={{
            background:
              'radial-gradient(circle, rgba(251,191,36,0.28) 0%, rgba(245,158,11,0.12) 40%, transparent 70%)',
          }}
        />

        <PapaMascot state="proud" size="xl" />

        <div className="text-center space-y-1">
          <p className="text-sm font-semibold tracking-[0.2em] text-amber-300 uppercase">
            ¡Subiste de nivel!
          </p>
          <h2 className="text-5xl font-black text-white drop-shadow-lg">
            Nivel {level}
          </h2>
          <p className="text-xl font-bold text-amber-200 mt-1">
            {title}
          </p>
        </div>

        <button
          onClick={onDismiss}
          className="mt-3 px-6 py-2.5 rounded-full bg-white/15 hover:bg-white/25 text-white text-sm font-semibold backdrop-blur-sm border border-white/20 transition-colors"
        >
          ¡Seguir!
        </button>
      </div>
    </div>
  );
}
