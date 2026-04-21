'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import type { MascotState } from './PapaMascot';

type FlashInput = {
  state: MascotState;
  message?: string;
  durationMs?: number;
};

interface UseMascotStateReturn {
  state: MascotState;
  message: string | undefined;
  setState: (state: MascotState, message?: string) => void;
  flash: (input: FlashInput) => void;
  reset: () => void;
}

/**
 * Drives mascot state from app events.
 *
 * setState → persistent change
 * flash    → temporary change that reverts to the previous persistent state
 * reset    → back to initial state and message
 */
export function useMascotState(
  initialState: MascotState = 'normal',
  initialMessage?: string,
): UseMascotStateReturn {
  const [state, setStateRaw] = useState<MascotState>(initialState);
  const [message, setMessageRaw] = useState<string | undefined>(initialMessage);

  const baseStateRef = useRef<MascotState>(initialState);
  const baseMessageRef = useRef<string | undefined>(initialMessage);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const clearTimer = () => {
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  };

  const setState = useCallback((next: MascotState, nextMessage?: string) => {
    clearTimer();
    baseStateRef.current = next;
    baseMessageRef.current = nextMessage;
    setStateRaw(next);
    setMessageRaw(nextMessage);
  }, []);

  const flash = useCallback(({ state: flashState, message: flashMsg, durationMs = 2200 }: FlashInput) => {
    clearTimer();
    setStateRaw(flashState);
    setMessageRaw(flashMsg);
    timerRef.current = setTimeout(() => {
      setStateRaw(baseStateRef.current);
      setMessageRaw(baseMessageRef.current);
      timerRef.current = null;
    }, durationMs);
  }, []);

  const reset = useCallback(() => {
    clearTimer();
    baseStateRef.current = initialState;
    baseMessageRef.current = initialMessage;
    setStateRaw(initialState);
    setMessageRaw(initialMessage);
  }, [initialState, initialMessage]);

  useEffect(() => () => clearTimer(), []);

  return { state, message, setState, flash, reset };
}
