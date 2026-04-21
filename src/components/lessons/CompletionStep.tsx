'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Trophy, ArrowRight, Home, Sparkles } from 'lucide-react';
import PapaMascot from '@/components/mascot/PapaMascot';
import Confetti from '@/components/effects/Confetti';
import { sounds } from '@/lib/utils/sounds';
import type { Achievement } from '@/lib/types/database';

interface CompletionStepProps {
  xpEarned: number;
  totalXP: number;
  currentStreak: number;
  correctAnswers: number;
  totalQuestions: number;
  newAchievements: Achievement[];
  nextLessonId: number | null;
}

export default function CompletionStep({
  xpEarned,
  totalXP,
  currentStreak,
  correctAnswers,
  totalQuestions,
  newAchievements,
  nextLessonId,
}: CompletionStepProps) {
  const [animatedXP, setAnimatedXP] = useState(0);
  const [showContent, setShowContent] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setShowContent(true), 300);
    const soundTimer = setTimeout(() => {
      if (newAchievements.length > 0) sounds.levelUp();
      else sounds.correct();
    }, 250);
    return () => {
      clearTimeout(timer);
      clearTimeout(soundTimer);
    };
  }, [newAchievements.length]);

  useEffect(() => {
    if (!showContent) return;
    const duration = 1000;
    const steps = 30;
    const increment = xpEarned / steps;
    let current = 0;
    const interval = setInterval(() => {
      current += increment;
      if (current >= xpEarned) {
        setAnimatedXP(xpEarned);
        clearInterval(interval);
      } else {
        setAnimatedXP(Math.floor(current));
      }
    }, duration / steps);
    return () => clearInterval(interval);
  }, [showContent, xpEarned]);

  const quizPercentage = totalQuestions > 0
    ? Math.round((correctAnswers / totalQuestions) * 100)
    : 0;

  return (
    <div className="flex flex-col items-center min-h-[calc(100dvh-10rem)] pb-6">
      <Confetti />
      {/* Celebration header with mascot */}
      <div
        className={`text-center mt-4 mb-6 transition-all duration-700 ${
          showContent ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
        }`}
      >
        <div className="flex justify-center mb-3">
          <PapaMascot
            state={newAchievements.length > 0 ? 'proud' : 'celebrating'}
            size="xl"
            message={`¡Increíble! +${xpEarned} XP ganados`}
          />
        </div>
        <h1 className="text-2xl font-bold text-text mb-2">
          ¡Lección completada!
        </h1>
        <p className="text-text-secondary">¡Excelente trabajo!</p>
      </div>

      {/* XP earned */}
      <div
        className={`w-full bg-gradient-to-br from-primary to-blue-600 rounded-2xl p-6 text-white text-center mb-4 shadow-lg shadow-primary/25 transition-all duration-700 delay-200 ${
          showContent ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
        }`}
      >
        <div className="flex items-center justify-center gap-2 mb-1">
          <Sparkles size={20} className="text-blue-200" />
          <p className="text-blue-200 font-medium">XP Ganados</p>
        </div>
        <p className="text-5xl font-bold">+{animatedXP}</p>
        <p className="text-sm text-blue-200 mt-2">Total: {totalXP} XP</p>
      </div>

      {/* Stats row */}
      <div
        className={`w-full grid grid-cols-2 gap-3 mb-4 transition-all duration-700 delay-300 ${
          showContent ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
        }`}
      >
        <div className="bg-white border border-border rounded-2xl p-4 text-center">
          <p className="text-2xl font-bold text-amber-500">🔥 {currentStreak}</p>
          <p className="text-xs text-text-secondary mt-1">
            {currentStreak === 1 ? 'día de racha' : 'días de racha'}
          </p>
        </div>
        <div className="bg-white border border-border rounded-2xl p-4 text-center">
          <p className="text-2xl font-bold text-success">{quizPercentage}%</p>
          <p className="text-xs text-text-secondary mt-1">
            Quiz ({correctAnswers}/{totalQuestions})
          </p>
        </div>
      </div>

      {/* New achievements */}
      {newAchievements.length > 0 && (
        <div
          className={`w-full mb-4 transition-all duration-700 delay-500 ${
            showContent ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
          }`}
        >
          <div className="bg-gradient-to-br from-amber-50 to-yellow-50 border border-amber-200/50 rounded-2xl p-5">
            <div className="flex items-center gap-2 mb-3">
              <Trophy className="w-5 h-5 text-amber-500" />
              <p className="font-bold text-amber-700">
                {newAchievements.length === 1 ? '¡Nuevo logro desbloqueado!' : '¡Nuevos logros desbloqueados!'}
              </p>
            </div>
            <div className="space-y-2">
              {newAchievements.map((a) => (
                <div key={a.id} className="flex items-center gap-3 bg-white/60 rounded-xl p-3">
                  <span className="text-2xl">{a.icon_name}</span>
                  <div>
                    <p className="font-bold text-sm text-text">{a.title}</p>
                    <p className="text-xs text-text-secondary">{a.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Action buttons */}
      <div
        className={`w-full mt-auto space-y-3 transition-all duration-700 delay-700 ${
          showContent ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
        }`}
      >
        {nextLessonId ? (
          <Link
            href={`/lessons/${nextLessonId}`}
            className="w-full py-4 bg-primary hover:bg-primary-dark text-white font-bold rounded-2xl flex items-center justify-center gap-2 transition-colors active:scale-[0.98]"
          >
            Siguiente lección
            <ArrowRight size={20} />
          </Link>
        ) : (
          <Link
            href="/lessons"
            className="w-full py-4 bg-primary hover:bg-primary-dark text-white font-bold rounded-2xl flex items-center justify-center gap-2 transition-colors active:scale-[0.98]"
          >
            Ver todas las lecciones
            <ArrowRight size={20} />
          </Link>
        )}
        <Link
          href="/dashboard"
          className="w-full py-4 bg-white border border-border hover:bg-gray-50 text-text font-bold rounded-2xl flex items-center justify-center gap-2 transition-colors active:scale-[0.98]"
        >
          <Home size={20} />
          Volver al inicio
        </Link>
      </div>
    </div>
  );
}
