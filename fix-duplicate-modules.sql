-- =============================================
-- FIX: Remove duplicate modules and reassign lessons
-- Run in Supabase SQL Editor
-- =============================================

-- Step 1: Preview duplicates (run this first to see the situation)
-- SELECT id, title, description, order_index, icon_name FROM modules ORDER BY title, id;

-- Step 2: Reassign lessons from duplicate modules to the original (lowest id per title)
WITH duplicates AS (
  SELECT title, MIN(id) AS keep_id
  FROM modules
  GROUP BY title
  HAVING COUNT(*) > 1
)
UPDATE lessons l
SET module_id = d.keep_id
FROM duplicates d
JOIN modules m ON m.title = d.title AND m.id != d.keep_id
WHERE l.module_id = m.id;

-- Step 3: Delete duplicate modules (keep only the lowest id per title)
DELETE FROM modules
WHERE id NOT IN (
  SELECT MIN(id) FROM modules GROUP BY title
);

-- Step 4: Fix order_index for all 5 modules
UPDATE modules SET order_index = 1 WHERE title = 'La Base';
UPDATE modules SET order_index = 2 WHERE title = 'Builder';
UPDATE modules SET order_index = 3 WHERE title = 'Automatizador';
UPDATE modules SET order_index = 4 WHERE title = 'AI Agents';
UPDATE modules SET order_index = 5 WHERE title = 'Negocio con IA';

-- Step 5: Update icon_names to Lucide-compatible string keys
UPDATE modules SET icon_name = 'sparkles' WHERE title = 'La Base';
UPDATE modules SET icon_name = 'hammer'   WHERE title = 'Builder';
UPDATE modules SET icon_name = 'zap'      WHERE title = 'Automatizador';
UPDATE modules SET icon_name = 'bot'      WHERE title = 'AI Agents';
UPDATE modules SET icon_name = 'rocket'   WHERE title = 'Negocio con IA';

-- Step 6: Ensure is_locked is correct
UPDATE modules SET is_locked = false WHERE title = 'La Base';
UPDATE modules SET is_locked = true  WHERE title != 'La Base';

-- Step 7: Unlock modules where the previous module is fully completed by ANY user
-- This handles users who completed Module 1 but Module 2 is still locked
DO $$
DECLARE
  v_mod RECORD;
  v_prev_id INT;
  v_total INT;
  v_completed INT;
BEGIN
  FOR v_mod IN SELECT id, order_index FROM modules WHERE is_locked = true ORDER BY order_index LOOP
    SELECT id INTO v_prev_id FROM modules WHERE order_index = v_mod.order_index - 1;
    IF v_prev_id IS NOT NULL THEN
      SELECT COUNT(*) INTO v_total FROM lessons WHERE module_id = v_prev_id;
      SELECT COUNT(DISTINCT lp.lesson_id) INTO v_completed
        FROM lesson_progress lp
        JOIN lessons l ON l.id = lp.lesson_id
        WHERE l.module_id = v_prev_id AND lp.status = 'completed';
      IF v_total > 0 AND v_completed >= v_total THEN
        UPDATE modules SET is_locked = false WHERE id = v_mod.id;
      END IF;
    END IF;
  END LOOP;
END $$;

-- Step 8: Add unique constraints to prevent future duplicates (safe: only runs if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'modules_order_index_unique'
  ) THEN
    ALTER TABLE modules ADD CONSTRAINT modules_order_index_unique UNIQUE (order_index);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'modules_title_unique'
  ) THEN
    ALTER TABLE modules ADD CONSTRAINT modules_title_unique UNIQUE (title);
  END IF;
END $$;

-- Step 9: Verify final state — should show exactly 5 modules with correct lesson counts
SELECT
  m.id,
  m.title,
  m.order_index,
  m.icon_name,
  m.is_locked,
  (SELECT COUNT(*) FROM lessons WHERE module_id = m.id) AS lesson_count
FROM modules m
ORDER BY m.order_index;
