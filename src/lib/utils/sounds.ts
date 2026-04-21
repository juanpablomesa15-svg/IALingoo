/**
 * Zero-dependency sound effects generated via Web Audio API.
 * Runs only in the browser; safe to call from event handlers.
 */

type AudioCtxCtor = typeof AudioContext;

function getCtx(): AudioContext | null {
  if (typeof window === 'undefined') return null;
  const w = window as unknown as { AudioContext?: AudioCtxCtor; webkitAudioContext?: AudioCtxCtor };
  const Ctor = w.AudioContext ?? w.webkitAudioContext;
  if (!Ctor) return null;
  const g = globalThis as unknown as { __ialingoAudioCtx?: AudioContext };
  if (!g.__ialingoAudioCtx) g.__ialingoAudioCtx = new Ctor();
  return g.__ialingoAudioCtx;
}

interface ToneSpec {
  freq: number;
  startAt: number;
  durationMs: number;
  type?: OscillatorType;
  peakGain?: number;
  glideTo?: number;
}

function playSequence(tones: ToneSpec[]) {
  const ctx = getCtx();
  if (!ctx) return;
  if (ctx.state === 'suspended') void ctx.resume();
  const now = ctx.currentTime;
  for (const t of tones) {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = t.type ?? 'sine';
    osc.frequency.setValueAtTime(t.freq, now + t.startAt / 1000);
    if (t.glideTo) {
      osc.frequency.linearRampToValueAtTime(
        t.glideTo,
        now + t.startAt / 1000 + t.durationMs / 1000,
      );
    }
    const peak = t.peakGain ?? 0.18;
    gain.gain.setValueAtTime(0, now + t.startAt / 1000);
    gain.gain.linearRampToValueAtTime(peak, now + t.startAt / 1000 + 0.015);
    gain.gain.exponentialRampToValueAtTime(
      0.0001,
      now + t.startAt / 1000 + t.durationMs / 1000,
    );
    osc.connect(gain).connect(ctx.destination);
    osc.start(now + t.startAt / 1000);
    osc.stop(now + t.startAt / 1000 + t.durationMs / 1000 + 0.02);
  }
}

export const sounds = {
  correct() {
    playSequence([
      { freq: 523.25, startAt: 0,   durationMs: 130, type: 'sine', peakGain: 0.2 },
      { freq: 783.99, startAt: 110, durationMs: 220, type: 'sine', peakGain: 0.22 },
    ]);
  },
  wrong() {
    playSequence([
      { freq: 311.13, startAt: 0,   durationMs: 180, type: 'triangle', peakGain: 0.18 },
      { freq: 207.65, startAt: 150, durationMs: 260, type: 'triangle', peakGain: 0.2 },
    ]);
  },
  xpPop() {
    playSequence([
      { freq: 880, startAt: 0, durationMs: 90, type: 'sine', peakGain: 0.14, glideTo: 1174.66 },
    ]);
  },
  levelUp() {
    playSequence([
      { freq: 523.25, startAt: 0,   durationMs: 140, type: 'triangle', peakGain: 0.2 },
      { freq: 659.25, startAt: 140, durationMs: 140, type: 'triangle', peakGain: 0.2 },
      { freq: 783.99, startAt: 280, durationMs: 160, type: 'triangle', peakGain: 0.22 },
      { freq: 1046.5, startAt: 440, durationMs: 420, type: 'triangle', peakGain: 0.24 },
    ]);
  },
  streak() {
    playSequence([
      { freq: 440, startAt: 0,   durationMs: 90, type: 'sawtooth', peakGain: 0.12, glideTo: 660 },
      { freq: 660, startAt: 85,  durationMs: 120, type: 'sawtooth', peakGain: 0.14, glideTo: 880 },
    ]);
  },
  tap() {
    playSequence([
      { freq: 660, startAt: 0, durationMs: 50, type: 'sine', peakGain: 0.08 },
    ]);
  },
};

export type SoundName = keyof typeof sounds;
