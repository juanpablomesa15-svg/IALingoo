'use client';

import { useState, useCallback } from 'react';
import { createClient } from '@/lib/supabase/client';
import { checkNewAchievements } from '@/lib/utils/achievements';
import { getLevelFromXP } from '@/lib/utils/xp';
import TheoryStep from './TheoryStep';
import PracticalTaskStep from './PracticalTaskStep';
import QuizStep from './QuizStep';
import CompletionStep from './CompletionStep';
import type { Lesson, Quiz, Achievement } from '@/lib/types/database';

/**
 * When a module is fully completed, unlock the next module (by order_index).
 */
async function unlockNextModules(
  supabase: ReturnType<typeof createClient>,
  completedModuleIds: number[],
) {
  if (completedModuleIds.length === 0) return;

  // Fetch all modules ordered by order_index
  const { data: allModules } = await supabase
    .from('modules')
    .select('id, order_index, is_locked')
    .order('order_index', { ascending: true });

  if (!allModules) return;

  for (const completedId of completedModuleIds) {
    const idx = allModules.findIndex((m) => m.id === completedId);
    if (idx < 0 || idx >= allModules.length - 1) continue;

    const nextModule = allModules[idx + 1];
    if (nextModule.is_locked) {
      await supabase
        .from('modules')
        .update({ is_locked: false })
        .eq('id', nextModule.id);
    }
  }
}

interface LessonStepperProps {
  lesson: Lesson;
  quizzes: Quiz[];
  userId: string;
  allAchievements: Achievement[];
  alreadyUnlockedIds: number[];
  nextLessonId: number | null;
  reviewMode?: boolean;
}

type StepType = 'theory' | 'practical' | 'quiz' | 'completed';

interface StepDef {
  type: StepType;
  quizIndex?: number;
}

export default function LessonStepper({
  lesson,
  quizzes,
  userId,
  allAchievements,
  alreadyUnlockedIds,
  nextLessonId,
  reviewMode = false,
}: LessonStepperProps) {
  // Build the list of steps
  const steps: StepDef[] = [];
  if (lesson.content_md) {
    steps.push({ type: 'theory' });
  }
  if (lesson.practical_task) {
    steps.push({ type: 'practical' });
  }
  quizzes.forEach((_, i) => {
    steps.push({ type: 'quiz', quizIndex: i });
  });
  steps.push({ type: 'completed' });

  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [quizAnswers, setQuizAnswers] = useState<{ quizId: number; selectedIndex: number; isCorrect: boolean }[]>([]);
  const [completionData, setCompletionData] = useState<{
    xpEarned: number;
    totalXP: number;
    currentStreak: number;
    newAchievements: Achievement[];
    leveledUpTo: number | null;
  } | null>(null);
  const [isCompleting, setIsCompleting] = useState(false);

  const currentStep = steps[currentStepIndex];
  const correctAnswers = quizAnswers.filter((a) => a.isCorrect).length;

  const completeLesson = useCallback(async () => {
    if (isCompleting) return;
    setIsCompleting(true);

    const supabase = createClient();

    try {
      // 1. Call complete_lesson RPC
      const { data: result, error: rpcError } = await supabase.rpc('complete_lesson', {
        p_lesson_id: lesson.id,
      });

      if (rpcError) {
        console.error('Error completing lesson:', rpcError);
        // Fallback: try manual completion
        await manualComplete(supabase);
        return;
      }

      const rpcResult = result as { xp_earned: number; total_xp: number; lessons_completed: number; streak: number | { current_streak: number; longest_streak: number; streak_broken: boolean } } | null;

      // 2. Save quiz attempts
      if (quizAnswers.length > 0) {
        const attempts = quizAnswers.map((a) => ({
          user_id: userId,
          quiz_id: a.quizId,
          selected_index: a.selectedIndex,
          is_correct: a.isCorrect,
        }));
        await supabase.from('quiz_attempts').insert(attempts);
      }

      // 3. Check for new achievements
      const xpEarned = rpcResult?.xp_earned ?? lesson.xp_reward;
      const totalXP = rpcResult?.total_xp ?? 0;
      const streakRaw = rpcResult?.streak;
      const currentStreak = typeof streakRaw === 'object' && streakRaw !== null
        ? streakRaw.current_streak
        : (streakRaw ?? 0);
      const lessonsCompleted = rpcResult?.lessons_completed ?? 1;

      // Get modules completed
      const { data: allProgress } = await supabase
        .from('lesson_progress')
        .select('lesson_id, status, lessons:lesson_id(module_id)')
        .eq('user_id', userId)
        .eq('status', 'completed');

      const { data: allLessons } = await supabase
        .from('lessons')
        .select('id, module_id');

      const modulesCompleted: number[] = [];
      if (allLessons && allProgress) {
        const completedLessonIds = new Set(allProgress.map((p) => p.lesson_id));
        const lessonsByModule = new Map<number, number[]>();
        for (const l of allLessons) {
          const arr = lessonsByModule.get(l.module_id) || [];
          arr.push(l.id);
          lessonsByModule.set(l.module_id, arr);
        }
        for (const [moduleId, mLessons] of lessonsByModule) {
          if (mLessons.every((id) => completedLessonIds.has(id))) {
            modulesCompleted.push(moduleId);
          }
        }
      }

      // ── Unlock next modules when a module is fully completed ──
      await unlockNextModules(supabase, modulesCompleted);

      // Count perfect quiz answers
      const { count: perfectCount } = await supabase
        .from('quiz_attempts')
        .select('id', { count: 'exact', head: true })
        .eq('user_id', userId)
        .eq('is_correct', true);

      const alreadySet = new Set(alreadyUnlockedIds);
      const newAchievements = checkNewAchievements(allAchievements, alreadySet, {
        lessonsCompleted,
        totalXP,
        currentStreak,
        quizzesCorrectFirstTry: perfectCount ?? 0,
        modulesCompleted,
        hasCompletedQuiz: quizAnswers.length > 0,
      });

      // 4. Unlock new achievements
      if (newAchievements.length > 0) {
        const unlocks = newAchievements.map((a) => ({
          user_id: userId,
          achievement_id: a.id,
        }));
        await supabase.from('achievements_unlocked').insert(unlocks);
      }

      const previousXP = Math.max(0, totalXP - xpEarned);
      const oldLevel = getLevelFromXP(previousXP);
      const newLevel = getLevelFromXP(totalXP);
      const leveledUpTo = newLevel > oldLevel ? newLevel : null;

      setCompletionData({
        xpEarned,
        totalXP,
        currentStreak,
        newAchievements,
        leveledUpTo,
      });
    } catch (err) {
      console.error('Error in lesson completion:', err);
      setCompletionData({
        xpEarned: lesson.xp_reward,
        totalXP: 0,
        currentStreak: 0,
        newAchievements: [],
        leveledUpTo: null,
      });
    } finally {
      setIsCompleting(false);
    }
  }, [isCompleting, lesson, quizAnswers, userId, allAchievements, alreadyUnlockedIds]);

  async function manualComplete(supabase: ReturnType<typeof createClient>) {
    // Fallback if RPC doesn't exist: manually update tables
    const now = new Date().toISOString();

    // Upsert lesson progress
    await supabase.from('lesson_progress').upsert({
      user_id: userId,
      lesson_id: lesson.id,
      status: 'completed',
      completed_at: now,
      started_at: now,
    }, { onConflict: 'user_id,lesson_id' });

    // Update profile XP
    const { data: profile } = await supabase
      .from('profiles')
      .select('total_xp, current_level')
      .eq('id', userId)
      .single();

    const newXP = (profile?.total_xp ?? 0) + lesson.xp_reward;
    await supabase.from('profiles').update({
      total_xp: newXP,
      last_active_at: now,
    }).eq('id', userId);

    // Update streak
    const today = new Date().toISOString().split('T')[0];
    const { data: streak } = await supabase
      .from('streaks')
      .select('*')
      .eq('user_id', userId)
      .single();

    let currentStreak = 1;
    if (streak) {
      const lastDate = streak.last_activity_date;
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      if (lastDate === today) {
        currentStreak = streak.current_streak;
      } else if (lastDate === yesterdayStr) {
        currentStreak = streak.current_streak + 1;
      }

      await supabase.from('streaks').update({
        current_streak: currentStreak,
        longest_streak: Math.max(streak.longest_streak, currentStreak),
        last_activity_date: today,
      }).eq('user_id', userId);
    }

    // Count completed lessons
    const { count: lessonsCount } = await supabase
      .from('lesson_progress')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('status', 'completed');

    // Save quiz attempts
    if (quizAnswers.length > 0) {
      const attempts = quizAnswers.map((a) => ({
        user_id: userId,
        quiz_id: a.quizId,
        selected_index: a.selectedIndex,
        is_correct: a.isCorrect,
      }));
      await supabase.from('quiz_attempts').insert(attempts);
    }

    // Check achievements
    const { data: allLessons } = await supabase.from('lessons').select('id, module_id');
    const { data: allProgress } = await supabase
      .from('lesson_progress')
      .select('lesson_id')
      .eq('user_id', userId)
      .eq('status', 'completed');

    const completedIds = new Set((allProgress || []).map((p) => p.lesson_id));
    const lessonsByModule = new Map<number, number[]>();
    for (const l of (allLessons || [])) {
      const arr = lessonsByModule.get(l.module_id) || [];
      arr.push(l.id);
      lessonsByModule.set(l.module_id, arr);
    }
    const modulesCompleted: number[] = [];
    for (const [moduleId, mLessons] of lessonsByModule) {
      if (mLessons.every((id) => completedIds.has(id))) {
        modulesCompleted.push(moduleId);
      }
    }

    // ── Unlock next modules when a module is fully completed ──
    await unlockNextModules(supabase, modulesCompleted);

    const { count: perfectCount } = await supabase
      .from('quiz_attempts')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('is_correct', true);

    const alreadySet = new Set(alreadyUnlockedIds);
    const newAchievements = checkNewAchievements(allAchievements, alreadySet, {
      lessonsCompleted: lessonsCount ?? 1,
      totalXP: newXP,
      currentStreak,
      quizzesCorrectFirstTry: perfectCount ?? 0,
      modulesCompleted,
      hasCompletedQuiz: quizAnswers.length > 0,
    });

    if (newAchievements.length > 0) {
      const unlocks = newAchievements.map((a) => ({
        user_id: userId,
        achievement_id: a.id,
      }));
      await supabase.from('achievements_unlocked').insert(unlocks);
    }

    const previousXP = profile?.total_xp ?? 0;
    const oldLevel = getLevelFromXP(previousXP);
    const newLevel = getLevelFromXP(newXP);
    const leveledUpTo = newLevel > oldLevel ? newLevel : null;

    setCompletionData({
      xpEarned: lesson.xp_reward,
      totalXP: newXP,
      currentStreak,
      newAchievements,
      leveledUpTo,
    });
  }

  function handleNext() {
    const nextIndex = currentStepIndex + 1;
    if (nextIndex >= steps.length) return;

    // If the next step is 'completed', trigger the completion flow
    // (skip in review mode — progress is already saved, no XP re-granted)
    if (steps[nextIndex].type === 'completed' && !reviewMode) {
      completeLesson();
    }

    setCurrentStepIndex(nextIndex);
  }

  function handleQuizAnswer(selectedIndex: number, isCorrect: boolean) {
    const quiz = quizzes[currentStep.quizIndex!];
    setQuizAnswers((prev) => [...prev, { quizId: quiz.id, selectedIndex, isCorrect }]);
  }

  // Progress bar
  const totalStepsMinusCompletion = steps.length - 1;
  const progressPercent = totalStepsMinusCompletion > 0
    ? Math.round((currentStepIndex / totalStepsMinusCompletion) * 100)
    : 0;

  return (
    <div>
      {/* Top progress bar */}
      {currentStep.type !== 'completed' && (
        <div className="mb-6">
          <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-primary rounded-full transition-all duration-500 ease-out"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          <p className="text-xs text-text-secondary mt-2 text-center">
            Paso {currentStepIndex + 1} de {totalStepsMinusCompletion}
          </p>
        </div>
      )}

      {/* Step content */}
      {currentStep.type === 'theory' && lesson.content_md && (
        <TheoryStep content={lesson.content_md} onNext={handleNext} />
      )}

      {currentStep.type === 'practical' && lesson.practical_task && (
        <PracticalTaskStep task={lesson.practical_task} onNext={handleNext} />
      )}

      {currentStep.type === 'quiz' && currentStep.quizIndex !== undefined && (
        <QuizStep
          key={quizzes[currentStep.quizIndex].id}
          quiz={quizzes[currentStep.quizIndex]}
          questionNumber={currentStep.quizIndex}
          totalQuestions={quizzes.length}
          onAnswer={handleQuizAnswer}
          onNext={handleNext}
        />
      )}

      {currentStep.type === 'completed' && reviewMode && (
        <div className="flex flex-col items-center justify-center min-h-[50vh] text-center px-6">
          <div className="text-6xl mb-4">🔁</div>
          <h2 className="text-2xl font-bold text-text mb-2">¡Repaso completado!</h2>
          <p className="text-text-secondary mb-8 max-w-sm">
            Tu progreso original sigue intacto. {correctAnswers > 0 && quizzes.length > 0 && (
              <>Acertaste {correctAnswers} de {quizzes.length} esta vez.</>
            )}
          </p>
          <a
            href="/lessons"
            className="px-6 py-3 rounded-xl bg-primary text-white font-semibold hover:bg-primary/90 transition-colors"
          >
            Volver a lecciones
          </a>
        </div>
      )}

      {currentStep.type === 'completed' && !reviewMode && (
        <>
          {isCompleting || !completionData ? (
            <div className="flex flex-col items-center justify-center min-h-[50vh]">
              <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mb-4" />
              <p className="text-text-secondary font-medium">Guardando tu progreso...</p>
            </div>
          ) : (
            <CompletionStep
              xpEarned={completionData.xpEarned}
              totalXP={completionData.totalXP}
              currentStreak={completionData.currentStreak}
              correctAnswers={correctAnswers}
              totalQuestions={quizzes.length}
              newAchievements={completionData.newAchievements}
              nextLessonId={nextLessonId}
              leveledUpTo={completionData.leveledUpTo}
            />
          )}
        </>
      )}
    </div>
  );
}
