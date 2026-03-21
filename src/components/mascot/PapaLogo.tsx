'use client';

import { useId } from 'react';

export default function PapaLogo({ size = 32 }: { size?: number }) {
  const uid = useId().replace(/:/g, '');

  return (
    <svg viewBox="0 0 100 100" width={size} height={size} xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id={`l${uid}`} x1="50%" y1="0%" x2="50%" y2="100%">
          <stop offset="0%" stopColor="#60A5FA" />
          <stop offset="100%" stopColor="#2563EB" />
        </linearGradient>
      </defs>

      <g style={{ animation: 'papa-float-small 3s ease-in-out infinite' }}>
        {/* Ears */}
        <circle cx={23} cy={50} r={6} fill="#1D4ED8" />
        <circle cx={77} cy={50} r={6} fill="#1D4ED8" />

        {/* Body */}
        <rect x={24} y={24} width={52} height={62} rx={22} fill={`url(#l${uid})`} />

        {/* Screen panel */}
        <rect x={30} y={36} width={40} height={38} rx={10}
          fill="white" opacity={0.08}
          stroke="white" strokeWidth={0.8} strokeOpacity={0.12} />

        {/* Antenna */}
        <rect x={48} y={14} width={4} height={12} rx={2} fill="#1D4ED8" />
        <circle cx={50} cy={12} r={5} fill="#FBBF24" />
        <circle cx={48.5} cy={10.5} r={1.5} fill="white" opacity={0.4} />

        {/* Left eye */}
        <ellipse cx={42} cy={50} rx={5.5} ry={6} fill="white" />
        <ellipse cx={42} cy={51} rx={3.8} ry={4.2} fill="#0F172A" />
        <circle cx={40.5} cy={48.5} r={1.5} fill="white" opacity={0.9} />

        {/* Right eye */}
        <ellipse cx={58} cy={50} rx={5.5} ry={6} fill="white" />
        <ellipse cx={58} cy={51} rx={3.8} ry={4.2} fill="#0F172A" />
        <circle cx={56.5} cy={48.5} r={1.5} fill="white" opacity={0.9} />

        {/* Smile */}
        <path d="M42,64 Q50,72 58,64" stroke="white" strokeWidth={1.5}
          fill="none" strokeLinecap="round" opacity={0.8} />
      </g>
    </svg>
  );
}
