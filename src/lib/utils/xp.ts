// XP needed per level: each level requires more XP
// Level 1: 0 XP, Level 2: 100 XP, Level 3: 250 XP, etc.
const XP_THRESHOLDS = [
  0,     // Level 1
  100,   // Level 2
  250,   // Level 3
  500,   // Level 4
  800,   // Level 5
  1200,  // Level 6
  1700,  // Level 7
  2300,  // Level 8
  3000,  // Level 9
  4000,  // Level 10
];

export function getLevelFromXP(totalXP: number): number {
  for (let i = XP_THRESHOLDS.length - 1; i >= 0; i--) {
    if (totalXP >= XP_THRESHOLDS[i]) {
      return i + 1;
    }
  }
  return 1;
}

export function getXPForCurrentLevel(totalXP: number): {
  currentLevelXP: number;
  nextLevelXP: number;
  progress: number;
} {
  const level = getLevelFromXP(totalXP);
  const currentThreshold = XP_THRESHOLDS[level - 1] ?? 0;
  const nextThreshold = XP_THRESHOLDS[level] ?? XP_THRESHOLDS[XP_THRESHOLDS.length - 1] + 1000;

  const xpInLevel = totalXP - currentThreshold;
  const xpNeeded = nextThreshold - currentThreshold;
  const progress = Math.min((xpInLevel / xpNeeded) * 100, 100);

  return {
    currentLevelXP: xpInLevel,
    nextLevelXP: xpNeeded,
    progress,
  };
}

export function getLevelTitle(level: number): string {
  const titles: Record<number, string> = {
    1: 'Novato',
    2: 'Aprendiz',
    3: 'Explorador',
    4: 'Practicante',
    5: 'Conocedor',
    6: 'Avanzado',
    7: 'Experto',
    8: 'Maestro',
    9: 'Gurú',
    10: 'Leyenda IA',
  };
  return titles[level] ?? 'Leyenda IA';
}
