export function formatStreak(streak: number): string {
  if (streak === 0) return 'Sin racha';
  if (streak === 1) return '1 día';
  return `${streak} días`;
}

export function getStreakMessage(streak: number): string {
  if (streak === 0) return '¡Empieza hoy tu racha!';
  if (streak <= 2) return '¡Buen comienzo!';
  if (streak <= 6) return '¡Vas muy bien!';
  if (streak <= 13) return '¡Más de una semana seguida!';
  if (streak <= 29) return '¡Impresionante constancia!';
  return '¡Racha legendaria!';
}

export function getStreakEmoji(streak: number): string {
  if (streak === 0) return '❄️';
  if (streak <= 2) return '🔥';
  if (streak <= 6) return '🔥🔥';
  if (streak <= 13) return '🔥🔥🔥';
  return '⚡';
}
