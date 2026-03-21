'use client';

import { useId } from 'react';

export type MascotState = 'normal' | 'celebrating' | 'thinking' | 'sleeping' | 'streak' | 'oops';
export type MascotSize = 'sm' | 'md' | 'lg' | 'xl';

interface PapaMascotProps {
  state?: MascotState;
  size?: MascotSize;
  message?: string;
  className?: string;
}

const sizeMap: Record<MascotSize, number> = { sm: 80, md: 120, lg: 200, xl: 250 };

const FLOAT: Record<MascotState, string> = {
  normal:      'papa-float 3s ease-in-out infinite',
  celebrating: 'papa-float-big 2s ease-in-out infinite',
  thinking:    'papa-float-small 4s ease-in-out infinite',
  sleeping:    'papa-float-small 5s ease-in-out infinite',
  streak:      'papa-float 2.5s ease-in-out infinite',
  oops:        'papa-float-small 3s ease-in-out infinite',
};

const SHADOW: Record<MascotState, string> = {
  normal:      'papa-shadow 3s ease-in-out infinite',
  celebrating: 'papa-shadow-big 2s ease-in-out infinite',
  thinking:    'papa-shadow-small 4s ease-in-out infinite',
  sleeping:    'papa-shadow-small 5s ease-in-out infinite',
  streak:      'papa-shadow 2.5s ease-in-out infinite',
  oops:        'papa-shadow-small 3s ease-in-out infinite',
};

export default function PapaMascot({
  state = 'normal',
  size = 'md',
  message,
  className = '',
}: PapaMascotProps) {
  const uid = useId().replace(/:/g, '');
  const px = sizeMap[size];

  /* ── Palette per state ── */
  const p = state === 'sleeping'
    ? { hi: '#94A3B8', lo: '#64748B', dk: '#475569', ant: '#94A3B8' }
    : state === 'thinking'
    ? { hi: '#818CF8', lo: '#4F46E5', dk: '#3730A3', ant: '#A78BFA' }
    : {
        hi: '#60A5FA', lo: '#2563EB', dk: '#1D4ED8',
        ant: state === 'oops' ? '#EF4444' : state === 'streak' ? '#F97316' : '#FBBF24',
      };

  const waveArm = state === 'normal' || state === 'celebrating';

  return (
    <div className={`inline-flex flex-col items-center gap-2 ${className}`}>
      <div className="relative flex items-end gap-2">
        {/* ── Speech bubble ── */}
        {message && (
          <div className="mascot-bubble max-w-[180px] bg-white border border-border rounded-2xl px-3 py-2 shadow-sm relative self-center">
            <p className="text-sm text-text leading-snug">{message}</p>
            <div className="absolute -right-2 bottom-3 w-3 h-3 bg-white border-r border-b border-border rotate-[-45deg]" />
          </div>
        )}

        <svg
          viewBox="0 0 200 260"
          width={px}
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          style={{ overflow: 'visible' }}
        >
          <defs>
            <linearGradient id={`b${uid}`} x1="50%" y1="0%" x2="50%" y2="100%">
              <stop offset="0%" stopColor={p.hi} />
              <stop offset="100%" stopColor={p.lo} />
            </linearGradient>
            <radialGradient id={`s${uid}`}>
              <stop offset="0%" stopColor="#000" stopOpacity="0.18" />
              <stop offset="100%" stopColor="#000" stopOpacity="0" />
            </radialGradient>
          </defs>

          {/* ── Ground shadow ── */}
          <ellipse
            cx={100} cy={245} rx={38} ry={7}
            fill={`url(#s${uid})`}
            style={{ animation: SHADOW[state], transformBox: 'fill-box', transformOrigin: 'center' } as React.CSSProperties}
          />

          {/* ── Streak glow ── */}
          {state === 'streak' && (
            <ellipse cx={100} cy={130} rx={78} ry={88} fill="#F59E0B"
              style={{ animation: 'papa-glow 2s ease-in-out infinite' }}
            />
          )}

          {/* ═══ Float group ═══ */}
          <g style={{ animation: FLOAT[state] }}>
            {/* Shake (oops) */}
            <g style={state === 'oops' ? { animation: 'papa-shake 0.5s ease-in-out' } : undefined}>
              {/* Pulse (celebrating) */}
              <g style={state === 'celebrating' ? { animation: 'papa-pulse 1.5s ease-in-out infinite', transformOrigin: '100px 130px' } : undefined}>

                {/* ── Ears (behind body) ── */}
                <circle cx={42} cy={112} r={11} fill={p.dk} />
                <circle cx={158} cy={112} r={11} fill={p.dk} />
                <circle cx={42} cy={112} r={6} fill={p.lo} opacity={0.5} />
                <circle cx={158} cy={112} r={6} fill={p.lo} opacity={0.5} />

                {/* ── Left arm ── */}
                {state === 'thinking' ? (
                  <ellipse cx={32} cy={125} rx={11} ry={7} fill={p.lo}
                    transform="rotate(-45, 32, 125)" />
                ) : (
                  <ellipse cx={32} cy={155} rx={11} ry={7} fill={p.lo}
                    transform="rotate(-15, 32, 155)" />
                )}

                {/* ── Right arm (wave) ── */}
                <g style={waveArm ? { animation: 'papa-wave 2s ease-in-out infinite', transformOrigin: '162px 148px' } : undefined}>
                  <ellipse cx={168} cy={155} rx={11} ry={7} fill={p.lo}
                    transform="rotate(15, 168, 155)" />
                </g>

                {/* ── Body (capsule) ── */}
                <rect x={44} y={52} width={112} height={155} rx={42} fill={`url(#b${uid})`} />

                {/* ── Body sheen ── */}
                <ellipse cx={78} cy={82} rx={22} ry={18} fill="white" opacity={0.12}
                  transform="rotate(-15, 78, 82)" />

                {/* ── Screen panel ── */}
                <rect x={56} y={80} width={88} height={96} rx={18}
                  fill="white" opacity={0.08}
                  stroke="white" strokeWidth={1} strokeOpacity={0.12} />

                {/* ── Antenna ── */}
                <rect x={97} y={32} width={6} height={22} rx={3} fill={p.dk} />
                <circle cx={100} cy={28} r={15} fill={p.ant} opacity={0.2}
                  style={{ animation: 'papa-antenna 2.5s ease-in-out infinite' }} />
                <circle cx={100} cy={28} r={8} fill={p.ant}
                  style={{ animation: 'papa-pulse 2s ease-in-out infinite', transformOrigin: '100px 28px' }} />
                <circle cx={97} cy={25} r={2.5} fill="white" opacity={0.4} />

                {/* ── Eyes ── */}
                {state === 'sleeping' ? (
                  <>
                    <path d="M64,118 Q78,110 92,118" stroke="white" strokeWidth={2.5}
                      fill="none" strokeLinecap="round" opacity={0.5} />
                    <path d="M108,118 Q122,110 136,118" stroke="white" strokeWidth={2.5}
                      fill="none" strokeLinecap="round" opacity={0.5} />
                  </>
                ) : (
                  <g style={{
                    animation: 'papa-blink 4s ease-in-out infinite',
                    transformBox: 'fill-box',
                    transformOrigin: 'center',
                  } as React.CSSProperties}>
                    {/* Left eye */}
                    <ellipse cx={78} cy={116} rx={13} ry={14} fill="white" />
                    {state === 'oops' ? (
                      <>
                        <ellipse cx={80} cy={118} rx={10} ry={12} fill="#0F172A" />
                        <circle cx={76} cy={112} r={4} fill="white" opacity={0.95} />
                        <circle cx={83} cy={122} r={1.8} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'thinking' ? (
                      <>
                        <ellipse cx={75} cy={113} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={72} cy={109} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={78} cy={117} r={1.5} fill="white" opacity={0.4} />
                      </>
                    ) : (
                      <>
                        <ellipse cx={78} cy={117} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={75} cy={112} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={81} cy={121} r={1.5} fill="white" opacity={0.4} />
                      </>
                    )}

                    {/* Right eye */}
                    <ellipse cx={122} cy={116} rx={13} ry={14} fill="white" />
                    {state === 'oops' ? (
                      <>
                        <ellipse cx={124} cy={120} rx={7.5} ry={8.5} fill="#0F172A" />
                        <circle cx={121} cy={116} r={3} fill="white" opacity={0.95} />
                        <circle cx={126} cy={122} r={1.3} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'thinking' ? (
                      <>
                        <ellipse cx={119} cy={113} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={116} cy={109} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={122} cy={117} r={1.5} fill="white" opacity={0.4} />
                      </>
                    ) : (
                      <>
                        <ellipse cx={122} cy={117} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={119} cy={112} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={125} cy={121} r={1.5} fill="white" opacity={0.4} />
                      </>
                    )}
                  </g>
                )}

                {/* ── Sunglasses (streak) ── */}
                {state === 'streak' && (
                  <>
                    <rect x={60} y={104} width={30} height={22} rx={5} fill="#0F172A" />
                    <rect x={110} y={104} width={30} height={22} rx={5} fill="#0F172A" />
                    <rect x={64} y={107} width={12} height={5} rx={2.5} fill="white" opacity={0.1} />
                    <rect x={114} y={107} width={12} height={5} rx={2.5} fill="white" opacity={0.1} />
                    <path d="M90,115 L110,115" stroke="#0F172A" strokeWidth={3} strokeLinecap="round" />
                    <path d="M60,111 L50,107" stroke="#0F172A" strokeWidth={2.5} strokeLinecap="round" />
                    <path d="M140,111 L150,107" stroke="#0F172A" strokeWidth={2.5} strokeLinecap="round" />
                  </>
                )}

                {/* ── Mouth ── */}
                {state === 'celebrating' ? (
                  <>
                    <rect x={88} y={143} width={24} height={18} rx={5} fill="#0F172A" opacity={0.6} />
                    <ellipse cx={100} cy={157} rx={7} ry={4} fill="#F87171" opacity={0.7} />
                  </>
                ) : state === 'streak' ? (
                  <path d="M82,152 Q96,164 120,148" stroke="white" strokeWidth={2.5}
                    fill="none" strokeLinecap="round" opacity={0.85} />
                ) : state === 'oops' ? (
                  <path d="M80,154 Q88,148 96,154 Q104,160 112,154 Q120,148 128,154"
                    stroke="white" strokeWidth={2.5} fill="none" strokeLinecap="round" opacity={0.85} />
                ) : state === 'sleeping' ? (
                  <path d="M88,150 Q100,156 112,150" stroke="white" strokeWidth={2}
                    fill="none" strokeLinecap="round" opacity={0.4} />
                ) : state === 'thinking' ? (
                  <circle cx={100} cy={152} r={5} fill="#0F172A" opacity={0.5} />
                ) : (
                  <path d="M78,150 Q100,166 122,150" stroke="white" strokeWidth={2.5}
                    fill="none" strokeLinecap="round" opacity={0.85} />
                )}

              </g>{/* end pulse */}
            </g>{/* end shake */}

            {/* ═══ Effects (outside body transforms, inside float) ═══ */}

            {/* Sparkles (celebrating) */}
            {state === 'celebrating' && (
              <>
                {[
                  { x: 30, y: 25, d: 0, s: 1.1, c: '#FBBF24' },
                  { x: 170, y: 30, d: 0.35, s: 0.9, c: '#3B82F6' },
                  { x: 20, y: 80, d: 0.7, s: 0.8, c: '#EF4444' },
                  { x: 180, y: 85, d: 0.15, s: 0.7, c: '#10B981' },
                  { x: 45, y: 12, d: 0.5, s: 1, c: '#8B5CF6' },
                  { x: 155, y: 8, d: 0.85, s: 1.2, c: '#F59E0B' },
                ].map((sp, i) => (
                  <path key={i}
                    d="M0,-7 L1.5,-1.5 7,0 1.5,1.5 0,7 -1.5,1.5 -7,0 -1.5,-1.5 Z"
                    fill={sp.c}
                    transform={`translate(${sp.x},${sp.y}) scale(${sp.s})`}
                    style={{ animation: 'papa-sparkle 2s ease-in-out infinite', animationDelay: `${sp.d}s` }}
                  />
                ))}
              </>
            )}

            {/* Thought bubbles (thinking) */}
            {state === 'thinking' && (
              <>
                <circle cx={154} cy={80} r={4} fill="white" stroke="#CBD5E1" strokeWidth={1} />
                <circle cx={166} cy={64} r={7} fill="white" stroke="#CBD5E1" strokeWidth={1} />
                <ellipse cx={182} cy={40} rx={16} ry={14} fill="white" stroke="#CBD5E1" strokeWidth={1.5} />
                <text x={182} y={46} textAnchor="middle" fontSize={16} fontWeight="bold" fill="#6366F1">?</text>
              </>
            )}

            {/* Zzz (sleeping) */}
            {state === 'sleeping' && (
              <>
                {[
                  { x: 150, y: 74, sz: 12, d: 0 },
                  { x: 162, y: 54, sz: 16, d: 0.8 },
                  { x: 174, y: 32, sz: 20, d: 1.6 },
                ].map((z, i) => (
                  <text key={i} x={z.x} y={z.y} fontSize={z.sz} fontWeight="bold" fill="#94A3B8"
                    style={{ animation: 'papa-zzz 2.5s ease-in-out infinite', animationDelay: `${z.d}s` }}
                  >z</text>
                ))}
              </>
            )}

            {/* Fire particles (streak) */}
            {state === 'streak' && (
              <>
                {[
                  { cx: 78, d: 0, c: '#F97316' },
                  { cx: 90, d: 0.3, c: '#EF4444' },
                  { cx: 100, d: 0.6, c: '#F97316' },
                  { cx: 110, d: 0.2, c: '#EF4444' },
                  { cx: 122, d: 0.5, c: '#F97316' },
                ].map((f, i) => (
                  <ellipse key={i} cx={f.cx} cy={205} rx={5} ry={8} fill={f.c}
                    style={{ animation: 'papa-fire 1.5s ease-out infinite', animationDelay: `${f.d}s` }}
                  />
                ))}
              </>
            )}

            {/* Sweat drops (oops) */}
            {state === 'oops' && (
              <>
                {[
                  { x: 152, y: 92, d: 0 },
                  { x: 158, y: 102, d: 0.7 },
                ].map((sw, i) => (
                  <g key={i} style={{ animation: 'papa-sweat 2s ease-in infinite', animationDelay: `${sw.d}s` }}>
                    <path
                      d={`M${sw.x},${sw.y} L${sw.x + 3},${sw.y + 9} Q${sw.x},${sw.y + 13} ${sw.x - 3},${sw.y + 9} Z`}
                      fill="#60A5FA" opacity={0.6}
                    />
                  </g>
                ))}
              </>
            )}

          </g>{/* end float */}
        </svg>
      </div>
    </div>
  );
}
