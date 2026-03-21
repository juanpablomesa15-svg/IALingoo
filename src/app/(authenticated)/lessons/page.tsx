import { createClient } from '@/lib/supabase/server';
import ModuleCard from '@/components/lessons/ModuleCard';
import { buildModulesWithProgress } from '@/lib/utils/lessons';
import type { LessonStatus } from '@/lib/types/database';

export default async function LessonsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // Fetch modules
  const { data: modules } = await supabase
    .from('modules')
    .select('*')
    .order('order_index', { ascending: true });

  // Fetch lessons
  const { data: lessons } = await supabase
    .from('lessons')
    .select('*')
    .order('module_id', { ascending: true })
    .order('order_index', { ascending: true });

  // Fetch progress
  const { data: progress } = await supabase
    .from('lesson_progress')
    .select('*')
    .eq('user_id', user!.id);

  const progressMap = new Map(
    (progress || []).map((p) => [p.lesson_id, p.status as LessonStatus])
  );

  // Build modules with lessons and progress using shared utility
  const modulesWithLessons = buildModulesWithProgress(
    modules || [],
    lessons || [],
    progressMap
  );

  // First non-locked module that isn't complete should be open by default
  const firstActiveModuleIndex = modulesWithLessons.findIndex(
    (m) => !m.is_locked && m.completedCount < m.lessons.length
  );

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold text-text">Lecciones</h1>
        <p className="text-text-secondary mt-1">Tu camino para dominar la IA</p>
      </div>

      <div className="space-y-4">
        {modulesWithLessons.map((mod, index) => (
          <ModuleCard
            key={mod.id}
            module={mod}
            defaultOpen={index === firstActiveModuleIndex}
          />
        ))}
      </div>
    </div>
  );
}
