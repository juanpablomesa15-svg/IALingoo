import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import { ArrowLeft, Clock, Star } from 'lucide-react';
import Link from 'next/link';
import LessonStepper from '@/components/lessons/LessonStepper';

export default async function LessonPage({
  params,
  searchParams,
}: {
  params: Promise<{ lessonId: string }>;
  searchParams: Promise<{ review?: string }>;
}) {
  const { lessonId } = await params;
  const { review } = await searchParams;
  const isReview = review === '1';
  const lessonIdNum = parseInt(lessonId, 10);

  if (isNaN(lessonIdNum)) {
    redirect('/lessons');
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  // Fetch the lesson
  const { data: lesson } = await supabase
    .from('lessons')
    .select('*, modules:module_id(title, is_locked, order_index)')
    .eq('id', lessonIdNum)
    .single();

  if (!lesson) {
    redirect('/lessons');
  }

  // Check if module is locked
  const mod = lesson.modules as { title: string; is_locked: boolean; order_index: number } | null;
  if (mod?.is_locked) {
    redirect('/lessons');
  }

  // Check if lesson is available (previous lesson must be completed)
  const { data: sameLessons } = await supabase
    .from('lessons')
    .select('id, order_index')
    .eq('module_id', lesson.module_id)
    .order('order_index', { ascending: true });

  const lessonIndex = (sameLessons || []).findIndex((l) => l.id === lessonIdNum);

  if (lessonIndex > 0) {
    const prevLessonId = sameLessons![lessonIndex - 1].id;
    const { data: prevProgress } = await supabase
      .from('lesson_progress')
      .select('status')
      .eq('user_id', user.id)
      .eq('lesson_id', prevLessonId)
      .single();

    if (prevProgress?.status !== 'completed') {
      redirect('/lessons');
    }
  }

  // Check if already completed
  const { data: existingProgress } = await supabase
    .from('lesson_progress')
    .select('status')
    .eq('user_id', user.id)
    .eq('lesson_id', lessonIdNum)
    .single();

  const isCompleted = existingProgress?.status === 'completed';

  // Block entry if completed and not in review mode
  if (isCompleted && !isReview) {
    redirect('/lessons');
  }

  // Reject ?review=1 if the lesson hasn't been completed yet
  if (isReview && !isCompleted) {
    redirect(`/lessons/${lessonIdNum}`);
  }

  // Only mark in_progress on a real attempt (not review)
  if (!isReview) {
    await supabase.from('lesson_progress').upsert({
      user_id: user.id,
      lesson_id: lessonIdNum,
      status: 'in_progress',
      started_at: new Date().toISOString(),
    }, { onConflict: 'user_id,lesson_id' });
  }

  // Fetch quizzes for this lesson
  const { data: quizzes } = await supabase
    .from('quizzes')
    .select('*')
    .eq('lesson_id', lessonIdNum)
    .order('order_index', { ascending: true });

  // Fetch all achievements + already unlocked (for checking new unlocks)
  const { data: allAchievements } = await supabase
    .from('achievements')
    .select('*');

  const { data: unlockedAchievements } = await supabase
    .from('achievements_unlocked')
    .select('achievement_id')
    .eq('user_id', user.id);

  const alreadyUnlockedIds = (unlockedAchievements || []).map((u) => u.achievement_id);

  // Find next lesson ID
  let nextLessonId: number | null = null;
  if (lessonIndex < (sameLessons || []).length - 1) {
    nextLessonId = sameLessons![lessonIndex + 1].id;
  } else {
    // Last lesson in module — find the first lesson of the next module
    // (it will be unlocked by LessonStepper when this module is completed)
    const { data: nextModuleLessons } = await supabase
      .from('lessons')
      .select('id, modules:module_id(order_index)')
      .order('module_id', { ascending: true })
      .order('order_index', { ascending: true });

    if (nextModuleLessons) {
      const currentModuleOrder = mod?.order_index ?? 0;
      const nextModuleLesson = nextModuleLessons.find((l) => {
        const lMod = l.modules as unknown as { order_index: number } | null;
        return lMod && lMod.order_index > currentModuleOrder;
      });
      if (nextModuleLesson) {
        nextLessonId = nextModuleLesson.id;
      }
    }
  }

  return (
    <div>
      {/* Header */}
      <div className="flex items-center gap-3 mb-2">
        <Link
          href="/lessons"
          className="w-10 h-10 rounded-xl bg-white border border-border flex items-center justify-center hover:bg-gray-50 transition-colors shrink-0"
        >
          <ArrowLeft size={20} className="text-text" />
        </Link>
        <div className="flex-1 min-w-0">
          <h1 className="text-lg font-bold text-text truncate">{lesson.title}</h1>
          <p className="text-sm text-text-secondary">{mod?.title}</p>
        </div>
      </div>

      {/* Badges */}
      <div className="flex items-center gap-3 mb-6">
        <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 text-amber-700 rounded-full text-sm font-medium">
          <Star size={14} fill="currentColor" />
          {lesson.xp_reward} XP
        </span>
        <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-primary rounded-full text-sm font-medium">
          <Clock size={14} />
          ~{lesson.estimated_minutes} min
        </span>
      </div>

      {isReview && (
        <div className="mb-4 px-4 py-3 rounded-xl bg-blue-50 border border-blue-100 text-sm text-primary font-medium flex items-center gap-2">
          <span>🔁</span>
          <span>Modo repaso — tu progreso ya está guardado, no se otorga XP nuevamente.</span>
        </div>
      )}

      {/* Stepper */}
      <LessonStepper
        lesson={lesson}
        quizzes={quizzes || []}
        userId={user.id}
        allAchievements={allAchievements || []}
        alreadyUnlockedIds={alreadyUnlockedIds}
        nextLessonId={nextLessonId}
        reviewMode={isReview}
      />
    </div>
  );
}
