'use client';

import PapaMascot from '@/components/mascot/PapaMascot';
import type { MascotState } from '@/components/mascot/PapaMascot';

interface DashboardMascotProps {
  currentStreak: number;
  lastActivityDate: string | null;
}

function getTimeGreeting(): string {
  const hour = new Date().getHours();
  if (hour >= 4 && hour <= 11) return '¡Buenos días! ¿Listo para aprender?';
  if (hour >= 12 && hour <= 17) return '¡Buena tarde! Una leccioncita no hace daño';
  if (hour >= 18 && hour <= 23) return '¡Buena noche! Cerremos el día aprendiendo';
  return '¡Hola! Empecemos a aprender';
}

function getDaysDiff(dateStr: string): number {
  const last = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - last.getTime();
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

export default function DashboardMascot({
  currentStreak,
  lastActivityDate,
}: DashboardMascotProps) {
  let mascotState: MascotState = 'normal';
  let message = '¡Hola! Empecemos a aprender';

  if (currentStreak === 0 && lastActivityDate && getDaysDiff(lastActivityDate) > 2) {
    mascotState = 'sleeping';
    message = 'En modo standby... ¡reactívame estudiando!';
  } else if (currentStreak >= 7) {
    mascotState = 'streak';
    message = `¡${currentStreak} días! ¡Estamos on fire!`;
  } else if (currentStreak >= 1) {
    mascotState = 'normal';
    message = getTimeGreeting();
  }

  return (
    <div className="flex justify-center mb-4">
      <PapaMascot state={mascotState} size="lg" message={message} />
    </div>
  );
}
