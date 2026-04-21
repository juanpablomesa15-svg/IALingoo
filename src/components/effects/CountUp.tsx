'use client';

import { useEffect, useRef, useState } from 'react';

interface CountUpProps {
  to: number;
  from?: number;
  durationMs?: number;
  formatter?: (n: number) => string;
  className?: string;
  startOnMount?: boolean;
}

// Ease-out cubic
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

export default function CountUp({
  to,
  from = 0,
  durationMs = 1200,
  formatter,
  className,
  startOnMount = true,
}: CountUpProps) {
  const [value, setValue] = useState<number>(startOnMount ? from : to);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    if (!startOnMount) {
      setValue(to);
      return;
    }
    const start = performance.now();
    const delta = to - from;
    const step = (now: number) => {
      const elapsed = now - start;
      const t = Math.min(1, elapsed / durationMs);
      const eased = easeOut(t);
      setValue(from + delta * eased);
      if (t < 1) {
        rafRef.current = requestAnimationFrame(step);
      } else {
        setValue(to);
        rafRef.current = null;
      }
    };
    rafRef.current = requestAnimationFrame(step);
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, [to, from, durationMs, startOnMount]);

  const display = formatter
    ? formatter(Math.round(value))
    : Math.round(value).toLocaleString();

  return <span className={className}>{display}</span>;
}
