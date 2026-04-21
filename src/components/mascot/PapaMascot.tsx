'use client';

import { useId } from 'react';

export type MascotState =
  | 'normal'
  | 'celebrating'
  | 'thinking'
  | 'sleeping'
  | 'streak'
  | 'oops'
  | 'waving'
  | 'loading'
  | 'talking'
  | 'proud';

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
  waving:      'papa-float 2.8s ease-in-out infinite',
  loading:     'papa-float-small 2.5s ease-in-out infinite',
  talking:     'papa-float-small 3s ease-in-out infinite',
  proud:       'papa-float-big 2.8s ease-in-out infinite',
};

const SHADOW: Record<MascotState, string> = {
  normal:      'papa-shadow 3s ease-in-out infinite',
  celebrating: 'papa-shadow-big 2s ease-in-out infinite',
  thinking:    'papa-shadow-small 4s ease-in-out infinite',
  sleeping:    'papa-shadow-small 5s ease-in-out infinite',
  streak:      'papa-shadow 2.5s ease-in-out infinite',
  oops:        'papa-shadow-small 3s ease-in-out infinite',
  waving:      'papa-shadow 2.8s ease-in-out infinite',
  loading:     'papa-shadow-small 2.5s ease-in-out infinite',
  talking:     'papa-shadow-small 3s ease-in-out infinite',
  proud:       'papa-shadow-big 2.8s ease-in-out infinite',
};

// Rounded-square silhouette — matches PapaLogo proportions (rx ≈ 42% of width)
// Bounding box: 32,38 → 168,214 (136 wide × 176 tall), corner radius 58
const BODY_PATH =
  'M 90 38 H 110 A 58 58 0 0 1 168 96 V 156 A 58 58 0 0 1 110 214 H 90 A 58 58 0 0 1 32 156 V 96 A 58 58 0 0 1 90 38 Z';

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
    ? { hi: '#A5B4FC', lo: '#6366F1', dk: '#4338CA', ant: '#94A3B8' }
    : state === 'thinking'
    ? { hi: '#818CF8', lo: '#4F46E5', dk: '#3730A3', ant: '#A78BFA' }
    : state === 'proud'
    ? { hi: '#93C5FD', lo: '#3B82F6', dk: '#1E40AF', ant: '#FBBF24' }
    : {
        hi: '#60A5FA', lo: '#2563EB', dk: '#1E40AF',
        ant:
          state === 'oops' ? '#EF4444'
          : state === 'streak' ? '#F97316'
          : state === 'loading' ? '#A78BFA'
          : '#FBBF24',
      };

  const bodyTilt =
    state === 'waving' ? { animation: 'papa-tilt 2s ease-in-out infinite', transformOrigin: '100px 200px' } :
    state === 'oops' ? { animation: 'papa-shake 0.5s ease-in-out' } :
    undefined;

  return (
    <div className={`inline-flex flex-col items-center gap-2 ${className}`}>
      <div className="relative flex items-end gap-2">
        {/* ── Speech bubble ── */}
        {message && (
          <div className="mascot-bubble max-w-[200px] bg-white border border-border rounded-2xl px-3 py-2 shadow-sm relative self-center">
            <p className="text-sm text-text leading-snug">{message}</p>
            <div className="absolute -right-2 bottom-3 w-3 h-3 bg-white border-r border-b border-border rotate-[-45deg]" />
          </div>
        )}

        <svg
          viewBox="0 0 200 230"
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
            <radialGradient id={`g${uid}`} cx="35%" cy="30%" r="55%">
              <stop offset="0%" stopColor="white" stopOpacity="0.35" />
              <stop offset="100%" stopColor="white" stopOpacity="0" />
            </radialGradient>
          </defs>

          {/* ── Ground shadow ── */}
          <ellipse
            cx={100} cy={222} rx={42} ry={6}
            fill={`url(#s${uid})`}
            style={{ animation: SHADOW[state], transformBox: 'fill-box', transformOrigin: 'center' } as React.CSSProperties}
          />

          {/* ── Streak / proud glow ── */}
          {(state === 'streak' || state === 'proud') && (
            <ellipse
              cx={100} cy={128} rx={82} ry={92}
              fill={state === 'streak' ? '#F59E0B' : '#3B82F6'}
              style={{ animation: 'papa-glow 2s ease-in-out infinite' }}
            />
          )}

          {/* ═══ Float group ═══ */}
          <g style={{ animation: FLOAT[state] }}>

            {/* Tilt / shake wrapper */}
            <g style={bodyTilt}>

              {/* Pulse (celebrating / proud) */}
              <g style={
                state === 'celebrating' ? { animation: 'papa-pulse 1.5s ease-in-out infinite', transformOrigin: '100px 130px' } :
                state === 'proud' ? { animation: 'papa-pulse 2.5s ease-in-out infinite', transformOrigin: '100px 130px' } :
                undefined
              }>

                {/* ── Body (egg silhouette) ── */}
                <path d={BODY_PATH} fill={`url(#b${uid})`} />

                {/* ── Body highlight (glass sheen) ── */}
                <path d={BODY_PATH} fill={`url(#g${uid})`} />

                {/* ── Inner face panel (subtle, no hard border) ── */}
                <ellipse cx={100} cy={132} rx={58} ry={52} fill="white" opacity={0.06} />

                {/* ── Antenna ── */}
                <rect x={97} y={22} width={6} height={20} rx={3} fill={p.dk} />
                <circle cx={100} cy={18} r={15} fill={p.ant} opacity={0.22}
                  style={{
                    animation: state === 'loading'
                      ? 'papa-antenna 1s ease-in-out infinite'
                      : 'papa-antenna 2.5s ease-in-out infinite',
                  }} />
                <circle cx={100} cy={18} r={8} fill={p.ant}
                  style={{
                    animation: state === 'loading'
                      ? 'papa-pulse 0.8s ease-in-out infinite'
                      : 'papa-pulse 2s ease-in-out infinite',
                    transformOrigin: '100px 18px',
                  }} />
                <circle cx={97} cy={15} r={2.5} fill="white" opacity={0.5} />

                {/* ── Eyes ── */}
                {state === 'sleeping' ? (
                  <>
                    <path d="M66,118 Q80,110 94,118" stroke="white" strokeWidth={2.5}
                      fill="none" strokeLinecap="round" opacity={0.55} />
                    <path d="M106,118 Q120,110 134,118" stroke="white" strokeWidth={2.5}
                      fill="none" strokeLinecap="round" opacity={0.55} />
                  </>
                ) : state === 'loading' ? (
                  <>
                    {[
                      { cx: 76,  d: 0 },
                      { cx: 100, d: 0.2 },
                      { cx: 124, d: 0.4 },
                    ].map((dot, i) => (
                      <circle key={i} cx={dot.cx} cy={125} r={5} fill="white"
                        style={{ animation: 'papa-dot 1.2s ease-in-out infinite', animationDelay: `${dot.d}s` }}
                      />
                    ))}
                  </>
                ) : (
                  <g style={{
                    animation: 'papa-blink 4s ease-in-out infinite',
                    transformBox: 'fill-box',
                    transformOrigin: 'center',
                  } as React.CSSProperties}>
                    {/* Left eye */}
                    <ellipse cx={80} cy={118} rx={13} ry={14} fill="white" />
                    {state === 'oops' ? (
                      <>
                        <ellipse cx={82} cy={120} rx={10} ry={12} fill="#0F172A" />
                        <circle cx={78} cy={114} r={4} fill="white" opacity={0.95} />
                        <circle cx={85} cy={124} r={1.8} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'thinking' ? (
                      <>
                        <ellipse cx={77} cy={115} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={74} cy={111} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={80} cy={119} r={1.5} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'proud' ? (
                      <>
                        <ellipse cx={80} cy={114} rx={8} ry={9} fill="#0F172A" />
                        <circle cx={77} cy={111} r={3} fill="white" opacity={0.95} />
                      </>
                    ) : (
                      <>
                        <ellipse cx={80} cy={119} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={77} cy={114} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={83} cy={123} r={1.5} fill="white" opacity={0.4} />
                      </>
                    )}

                    {/* Right eye */}
                    <ellipse cx={120} cy={118} rx={13} ry={14} fill="white" />
                    {state === 'oops' ? (
                      <>
                        <ellipse cx={122} cy={122} rx={7.5} ry={8.5} fill="#0F172A" />
                        <circle cx={119} cy={118} r={3} fill="white" opacity={0.95} />
                        <circle cx={124} cy={124} r={1.3} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'thinking' ? (
                      <>
                        <ellipse cx={117} cy={115} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={114} cy={111} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={120} cy={119} r={1.5} fill="white" opacity={0.4} />
                      </>
                    ) : state === 'proud' ? (
                      <>
                        <ellipse cx={120} cy={114} rx={8} ry={9} fill="#0F172A" />
                        <circle cx={117} cy={111} r={3} fill="white" opacity={0.95} />
                      </>
                    ) : (
                      <>
                        <ellipse cx={120} cy={119} rx={8.5} ry={10} fill="#0F172A" />
                        <circle cx={117} cy={114} r={3.5} fill="white" opacity={0.95} />
                        <circle cx={123} cy={123} r={1.5} fill="white" opacity={0.4} />
                      </>
                    )}
                  </g>
                )}

                {/* ── Sunglasses (streak) ── */}
                {state === 'streak' && (
                  <>
                    <rect x={62} y={106} width={30} height={22} rx={5} fill="#0F172A" />
                    <rect x={108} y={106} width={30} height={22} rx={5} fill="#0F172A" />
                    <rect x={66} y={109} width={12} height={5} rx={2.5} fill="white" opacity={0.12} />
                    <rect x={112} y={109} width={12} height={5} rx={2.5} fill="white" opacity={0.12} />
                    <path d="M92,117 L108,117" stroke="#0F172A" strokeWidth={3} strokeLinecap="round" />
                    <path d="M62,113 L52,109" stroke="#0F172A" strokeWidth={2.5} strokeLinecap="round" />
                    <path d="M138,113 L148,109" stroke="#0F172A" strokeWidth={2.5} strokeLinecap="round" />
                  </>
                )}

                {/* ── Crown (proud) ── */}
                {state === 'proud' && (
                  <g transform="translate(82, 84)">
                    <path d="M2,10 L2,3 L10,8 L18,1 L26,8 L34,3 L34,10 Z"
                      fill="#FBBF24" stroke="#D97706" strokeWidth={1.2} strokeLinejoin="round" />
                    <circle cx={10} cy={8} r={1.8} fill="#DC2626" />
                    <circle cx={18} cy={5} r={1.8} fill="#10B981" />
                    <circle cx={26} cy={8} r={1.8} fill="#DC2626" />
                  </g>
                )}

                {/* ── Mouth ── */}
                {state === 'celebrating' || state === 'waving' ? (
                  <>
                    <rect x={88} y={145} width={24} height={18} rx={5} fill="#0F172A" opacity={0.65} />
                    <ellipse cx={100} cy={159} rx={7} ry={4} fill="#F87171" opacity={0.75} />
                  </>
                ) : state === 'streak' ? (
                  <path d="M82,154 Q96,166 120,150" stroke="white" strokeWidth={2.5}
                    fill="none" strokeLinecap="round" opacity={0.9} />
                ) : state === 'oops' ? (
                  <path d="M80,156 Q88,150 96,156 Q104,162 112,156 Q120,150 128,156"
                    stroke="white" strokeWidth={2.5} fill="none" strokeLinecap="round" opacity={0.9} />
                ) : state === 'sleeping' ? (
                  <path d="M88,152 Q100,158 112,152" stroke="white" strokeWidth={2}
                    fill="none" strokeLinecap="round" opacity={0.45} />
                ) : state === 'thinking' ? (
                  <circle cx={100} cy={154} r={5} fill="#0F172A" opacity={0.55} />
                ) : state === 'loading' ? (
                  <path d="M88,152 L112,152" stroke="white" strokeWidth={2.5}
                    fill="none" strokeLinecap="round" opacity={0.6} />
                ) : state === 'proud' ? (
                  <path d="M80,150 Q100,168 120,150" stroke="white" strokeWidth={3}
                    fill="none" strokeLinecap="round" opacity={0.95} />
                ) : state === 'talking' ? (
                  <ellipse cx={100} cy={154} rx={10} ry={5} fill="#0F172A" opacity={0.65}
                    style={{ animation: 'papa-talk 0.35s ease-in-out infinite', transformBox: 'fill-box', transformOrigin: 'center' } as React.CSSProperties}
                  />
                ) : (
                  <path d="M80,152 Q100,168 120,152" stroke="white" strokeWidth={2.5}
                    fill="none" strokeLinecap="round" opacity={0.9} />
                )}

              </g>{/* end pulse */}
            </g>{/* end tilt/shake */}

            {/* ═══ Effects (outside body transforms, inside float) ═══ */}

            {/* Sparkles (celebrating) */}
            {state === 'celebrating' && (
              <>
                {[
                  { x: 30, y: 25, d: 0,    s: 1.1, c: '#FBBF24' },
                  { x: 170, y: 30, d: 0.35, s: 0.9, c: '#3B82F6' },
                  { x: 20, y: 80, d: 0.7,  s: 0.8, c: '#EF4444' },
                  { x: 180, y: 85, d: 0.15, s: 0.7, c: '#10B981' },
                  { x: 45, y: 12, d: 0.5,  s: 1,   c: '#8B5CF6' },
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

            {/* Stars (proud) */}
            {state === 'proud' && (
              <>
                {[
                  { x: 35, y: 50, d: 0,    s: 0.9, c: '#FBBF24' },
                  { x: 165, y: 55, d: 0.4, s: 1,   c: '#FBBF24' },
                  { x: 25, y: 100, d: 0.8, s: 0.7, c: '#F59E0B' },
                  { x: 175, y: 105, d: 0.2, s: 0.8, c: '#F59E0B' },
                ].map((sp, i) => (
                  <path key={i}
                    d="M0,-8 L2,-2.5 8,-2.5 3,1.5 5,8 0,4 -5,8 -3,1.5 -8,-2.5 -2,-2.5 Z"
                    fill={sp.c}
                    transform={`translate(${sp.x},${sp.y}) scale(${sp.s})`}
                    style={{ animation: 'papa-sparkle 2.4s ease-in-out infinite', animationDelay: `${sp.d}s` }}
                  />
                ))}
              </>
            )}

            {/* Greeting sparkle + hand emoji (waving) */}
            {state === 'waving' && (
              <g transform="translate(170, 55)"
                style={{ animation: 'papa-wave 1.6s ease-in-out infinite', transformOrigin: 'center' }}>
                <text x={0} y={0} fontSize={28} textAnchor="middle">👋</text>
              </g>
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

            {/* Loading ring */}
            {state === 'loading' && (
              <g transform="translate(172, 60)">
                <circle cx={0} cy={0} r={11} fill="none" stroke="#E0E7FF" strokeWidth={3} />
                <circle cx={0} cy={0} r={11} fill="none" stroke="#6366F1" strokeWidth={3}
                  strokeDasharray="20 50" strokeLinecap="round"
                  style={{ animation: 'papa-spin 1s linear infinite', transformOrigin: 'center' }}
                />
              </g>
            )}

            {/* Fire particles (streak) */}
            {state === 'streak' && (
              <>
                {[
                  { cx: 78, d: 0,   c: '#F97316' },
                  { cx: 90, d: 0.3, c: '#EF4444' },
                  { cx: 100, d: 0.6, c: '#F97316' },
                  { cx: 110, d: 0.2, c: '#EF4444' },
                  { cx: 122, d: 0.5, c: '#F97316' },
                ].map((f, i) => (
                  <ellipse key={i} cx={f.cx} cy={212} rx={5} ry={8} fill={f.c}
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
                      fill="#60A5FA" opacity={0.65}
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
