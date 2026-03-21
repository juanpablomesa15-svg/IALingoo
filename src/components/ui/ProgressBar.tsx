'use client';

interface ProgressBarProps {
  progress: number; // 0-100
  color?: 'primary' | 'accent' | 'success';
  size?: 'sm' | 'md' | 'lg';
  showLabel?: boolean;
  label?: string;
}

const colorMap = {
  primary: 'bg-primary',
  accent: 'bg-accent',
  success: 'bg-success',
};

const bgColorMap = {
  primary: 'bg-primary-light/30',
  accent: 'bg-accent-light/30',
  success: 'bg-success-light/30',
};

const sizeMap = {
  sm: 'h-2',
  md: 'h-3',
  lg: 'h-4',
};

export default function ProgressBar({
  progress,
  color = 'primary',
  size = 'md',
  showLabel = false,
  label,
}: ProgressBarProps) {
  const clampedProgress = Math.min(100, Math.max(0, progress));

  return (
    <div className="w-full">
      {(showLabel || label) && (
        <div className="flex justify-between items-center mb-1.5">
          {label && <span className="text-sm font-medium text-text-secondary">{label}</span>}
          {showLabel && (
            <span className="text-sm font-semibold text-text">
              {Math.round(clampedProgress)}%
            </span>
          )}
        </div>
      )}
      <div className={`w-full ${bgColorMap[color]} rounded-full ${sizeMap[size]} overflow-hidden`}>
        <div
          className={`${colorMap[color]} ${sizeMap[size]} rounded-full transition-all duration-500 ease-out`}
          style={{ width: `${clampedProgress}%` }}
        />
      </div>
    </div>
  );
}
