-- =============================================
-- IALingoo — Tracks restructure (2026-04-21)
-- Wipes existing learning content and creates
-- a tracks-based structure. Run once in Supabase
-- SQL Editor. Idempotent: safe to re-run.
-- =============================================

-- 1. Wipe existing learning content ------------------------------------------
-- (user already reset progress; this clears modules/lessons for the rewrite)

DELETE FROM quiz_attempts;
DELETE FROM achievements_unlocked;
DELETE FROM lesson_progress;
DELETE FROM quizzes;
DELETE FROM lessons;
DELETE FROM modules;

-- Reset XP/streak so stats reflect the new curriculum
UPDATE profiles SET total_xp = 0, current_level = 1;
UPDATE streaks  SET current_streak = 0, longest_streak = 0, last_activity_date = NULL;


-- 2. tracks table -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tracks (
  id            SERIAL PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  title         TEXT NOT NULL,
  description   TEXT NOT NULL,
  icon_name     TEXT NOT NULL,
  color_hex     TEXT NOT NULL,
  order_index   INT  NOT NULL,
  is_required   BOOLEAN NOT NULL DEFAULT false,
  is_locked     BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tracks_read_all ON tracks;
CREATE POLICY tracks_read_all ON tracks FOR SELECT USING (true);


-- 3. modules: add track_id, level, color_hex ----------------------------------

ALTER TABLE modules
  ADD COLUMN IF NOT EXISTS track_id   INT REFERENCES tracks(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS level      INT NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS color_hex  TEXT;

-- Drop prior check (if re-running) and re-add
ALTER TABLE modules DROP CONSTRAINT IF EXISTS modules_level_check;
ALTER TABLE modules ADD CONSTRAINT modules_level_check CHECK (level BETWEEN 1 AND 3);

CREATE INDEX IF NOT EXISTS idx_modules_track_id ON modules(track_id);


-- 4. Seed the 8 tracks (base + 7 parallel) ------------------------------------

INSERT INTO tracks (slug, title, description, icon_name, color_hex, order_index, is_required) VALUES
  ('base',     'La Base',           'Fundamentos de IA y prompting. Empezamos por acá.',              'sparkles',  '#8B5CF6', 0, true),
  ('claude',   'Claude Mastery',    'Usa Claude como tu coworker: chat, código, artefactos, MCP.',    'brain',     '#F59E0B', 1, false),
  ('visual',   'Creador Visual',    'Imágenes, video y branding profesional con IA.',                 'palette',   '#EC4899', 2, false),
  ('web',      'Builder Web',       'Landing pages, hosting y dominios sin saber programar.',         'globe',     '#06B6D4', 3, false),
  ('n8n',      'Automatizador n8n', 'Workflows reales que ahorran horas cada semana.',                'workflow',  '#F43F5E', 4, false),
  ('data',     'Datos & Backend',   'Supabase: tablas, auth y edge functions sin código.',            'database',  '#10B981', 5, false),
  ('agents',   'AI Agents & MCP',   'Agentes autónomos con herramientas y memoria.',                  'bot',       '#6366F1', 6, false),
  ('business', 'Negocio con IA',    'Modelo, nicho, MVP y lanzamiento paso a paso.',                  'rocket',    '#F97316', 7, false)
ON CONFLICT (slug) DO UPDATE SET
  title        = EXCLUDED.title,
  description  = EXCLUDED.description,
  icon_name    = EXCLUDED.icon_name,
  color_hex    = EXCLUDED.color_hex,
  order_index  = EXCLUDED.order_index,
  is_required  = EXCLUDED.is_required;


-- 5. Seed placeholder modules (lesson content comes in Phase 2) ---------------
-- All modules start unlocked so learners can explore tracks freely.

INSERT INTO modules (track_id, title, description, order_index, icon_name, color_hex, is_locked, level)
SELECT t.id, m.title, m.description, m.order_index, m.icon_name, t.color_hex, false, m.level
FROM tracks t
JOIN (VALUES
  -- track slug, title, description, order, icon, level
  ('base',     'Primeros pasos',       'Qué es IA, cómo funciona, cómo pedirle cosas.',       0, 'sparkles',          1),

  ('claude',   'Claude Básico',        'Chat, proyectos, artefactos.',                         0, 'message-square',    1),
  ('claude',   'Claude Code',          'Editor con IA — construye software real.',             1, 'code',              2),
  ('claude',   'MCPs y extensiones',   'Conecta Claude a tus apps y datos.',                   2, 'plug',              3),

  ('visual',   'Imágenes con IA',      'Midjourney, Nano Banana y estilos propios.',           0, 'image',             1),
  ('visual',   'Video con IA',         'Sora, Kling, Runway: de imagen a clip.',               1, 'video',             2),
  ('visual',   'Branding Pro',         'Logo, paleta e identidad completa.',                   2, 'palette',           3),

  ('web',      'Landing en 10 min',    'Primera web pública con Lovable o v0.',                0, 'layout-dashboard',  1),
  ('web',      'Hosting y dominio',    'Vercel, Netlify y conecta tu dominio.',                1, 'globe',             2),
  ('web',      'Sitio completo',       'Navegación, formularios e integraciones.',             2, 'layout',            3),

  ('n8n',      'n8n desde cero',       'Primer workflow, nodos y triggers.',                   0, 'zap',               1),
  ('n8n',      'Webhooks y APIs',      'Integra WhatsApp, Gmail y Sheets.',                    1, 'webhook',           2),
  ('n8n',      'Workflows reales',     'Sistema de leads, ventas y atención 24/7.',            2, 'workflow',          3),

  ('data',     'Supabase básico',      'Crea tablas, inserta y lee datos.',                    0, 'database',          1),
  ('data',     'Auth y seguridad',     'Login, RLS y roles.',                                   1, 'shield',            2),
  ('data',     'Edge Functions',       'Código serverless disparado por eventos.',             2, 'server',            3),

  ('agents',   'Qué es un agente',     'Diferencia entre chat, asistente y agente.',           0, 'bot',               1),
  ('agents',   'Tu primer agente',     'Herramientas, memoria y bucle de decisión.',           1, 'cpu',               2),
  ('agents',   'Agentes multi-paso',   'MCP, subagentes y tareas largas.',                     2, 'network',           3),

  ('business', 'Modelo de negocio IA', 'Productos, servicios y recurrentes.',                  0, 'lightbulb',         1),
  ('business', 'Encuentra tu nicho',   'Valida, prueba y pivota.',                              1, 'target',            2),
  ('business', 'Lanza tu MVP',         'Web, cobros y primeros clientes.',                     2, 'rocket',            3)
) AS m(track_slug, title, description, order_index, icon_name, level)
  ON m.track_slug = t.slug
ON CONFLICT DO NOTHING;
