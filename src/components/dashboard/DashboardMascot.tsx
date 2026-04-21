'use client';

import PapaMascot from '@/components/mascot/PapaMascot';
import type { MascotState } from '@/components/mascot/PapaMascot';

interface DashboardMascotProps {
  currentStreak: number;
  lastActivityDate: string | null;
  lessonsCompleted?: number;
  userName?: string;
}

function getTimeGreeting(name?: string): string {
  const hour = new Date().getHours();
  const who = name ? `, ${name}` : '';
  if (hour >= 4 && hour <= 11) return `¡Buenos días${who}! ¿Listo para aprender?`;
  if (hour >= 12 && hour <= 17) return `¡Buena tarde${who}! Una leccioncita no hace daño`;
  if (hour >= 18 && hour <= 23) return `¡Buena noche${who}! Cerremos el día aprendiendo`;
  return `¡Hola${who}! Empecemos a aprender`;
}

function getDaysDiff(dateStr: string): number {
  const last = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - last.getTime();
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

function isSameDay(dateStr: string): boolean {
  const today = new Date().toISOString().split('T')[0];
  return dateStr.startsWith(today);
}

// Stable daily encouragement for active users on their "off" days (no streak active)
const ENCOURAGEMENTS = [
  'Tu futuro yo te lo agradecerá. ¡Vamos!',
  'Pequeños pasos, gran progreso.',
  'Cada lección te deja más listo que ayer.',
  'La IA no intimida si la entiendes. ¡Dale!',
  'Hoy es buen día para aprender algo nuevo.',
];

function dailyEncouragement(): string {
  const day = Math.floor(Date.now() / (1000 * 60 * 60 * 24));
  return ENCOURAGEMENTS[day % ENCOURAGEMENTS.length];
}

export default function DashboardMascot({
  currentStreak,
  lastActivityDate,
  lessonsCompleted = 0,
  userName,
}: DashboardMascotProps) {
  let mascotState: MascotState = 'normal';
  let message = getTimeGreeting(userName);

  const activeToday = lastActivityDate ? isSameDay(lastActivityDate) : false;
  const daysSinceLast = lastActivityDate ? getDaysDiff(lastActivityDate) : null;

  if (lessonsCompleted === 0) {
    // First-time user — welcome + energy
    mascotState = 'waving';
    message = userName
      ? `¡Hola, ${userName}! Soy Lingo, tu guía`
      : '¡Hola! Soy Lingo, tu guía';
  } else if (daysSinceLast !== null && daysSinceLast > 2 && currentStreak === 0) {
    // Been away for a while
    mascotState = 'sleeping';
    message = '¿Dónde andabas? Volvamos a la carga 💪';
  } else if (currentStreak >= 30) {
    mascotState = 'proud';
    message = `¡${currentStreak} días! Eres una leyenda 👑`;
  } else if (currentStreak >= 7) {
    mascotState = 'streak';
    message = `¡${currentStreak} días seguidos! Estás on fire 🔥`;
  } else if (activeToday && currentStreak >= 1) {
    // Already practiced today — celebrate momentum
    mascotState = 'proud';
    message = currentStreak === 1
      ? '¡Bien hecho hoy! Mañana nos vemos para hacer racha'
      : `¡${currentStreak} días seguidos! Sigue así`;
  } else if (currentStreak >= 3) {
    mascotState = 'streak';
    message = `¡${currentStreak} días de racha! No la rompas hoy`;
  } else if (currentStreak >= 1) {
    mascotState = 'normal';
    message = getTimeGreeting(userName);
  } else {
    // Has completed lessons, but streak broken — nudge without guilt
    mascotState = 'normal';
    message = dailyEncouragement();
  }

  return (
    <div className="flex justify-center mb-4">
      <PapaMascot state={mascotState} size="lg" message={message} />
    </div>
  );
}
