import type { LessonWithProgress, ModuleWithLessons, Module, Lesson, LessonStatus } from '@/lib/types/database';

/**
 * Determines lesson availability based on linear progression within a module.
 * A lesson is available if:
 * - It's the first lesson in an unlocked module, OR
 * - The previous lesson (by order_index) in the same module is completed
 */
export function buildModulesWithProgress(
  modules: Module[],
  lessons: Lesson[],
  progressMap: Map<number, LessonStatus>
): ModuleWithLessons[] {
  return modules.map((mod) => {
    const moduleLessons = lessons.filter((l) => l.module_id === mod.id);

    let previousCompleted = true;
    const lessonsWithProgress: LessonWithProgress[] = moduleLessons.map((lesson) => {
      const dbStatus = progressMap.get(lesson.id);

      if (dbStatus === 'completed') {
        previousCompleted = true;
        return { ...lesson, status: 'completed' as const };
      }

      if (previousCompleted && !mod.is_locked) {
        previousCompleted = false;
        return { ...lesson, status: dbStatus === 'in_progress' ? 'in_progress' as const : 'not_started' as const };
      }

      previousCompleted = false;
      return { ...lesson, status: 'not_started' as const };
    });

    const completedCount = lessonsWithProgress.filter((l) => l.status === 'completed').length;

    return { ...mod, lessons: lessonsWithProgress, completedCount };
  });
}

/**
 * Checks if a specific lesson is available for a user to start.
 */
export function isLessonAvailable(
  lessonId: number,
  modules: ModuleWithLessons[]
): boolean {
  for (const mod of modules) {
    if (mod.is_locked) continue;
    for (let i = 0; i < mod.lessons.length; i++) {
      const lesson = mod.lessons[i];
      if (lesson.id === lessonId) {
        if (lesson.status === 'completed') return true;
        if (i === 0) return true;
        return mod.lessons[i - 1].status === 'completed';
      }
    }
  }
  return false;
}

/**
 * Finds the next lesson the user should do.
 */
export function getNextLesson(
  modules: ModuleWithLessons[]
): (LessonWithProgress & { moduleTitle: string }) | null {
  for (const mod of modules) {
    if (mod.is_locked) continue;
    for (const lesson of mod.lessons) {
      if (lesson.status !== 'completed') {
        return { ...lesson, moduleTitle: mod.title };
      }
    }
  }
  return null;
}
