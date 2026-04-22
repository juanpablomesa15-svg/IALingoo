'use client';

import { useEffect, useState } from 'react';
import { Download, Share, Plus, X, Smartphone } from 'lucide-react';

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
};

type Platform = 'android' | 'ios' | 'desktop' | 'unsupported';

const DISMISS_KEY = 'ialingo_pwa_install_dismissed';
const DISMISS_DAYS = 7;

function detectPlatform(): Platform {
  if (typeof window === 'undefined') return 'unsupported';
  const ua = window.navigator.userAgent.toLowerCase();
  const isIOS = /iphone|ipad|ipod/.test(ua) || (ua.includes('mac') && 'ontouchend' in document);
  const isAndroid = /android/.test(ua);
  const isStandalone =
    window.matchMedia('(display-mode: standalone)').matches ||
    // @ts-expect-error — iOS-only property
    window.navigator.standalone === true;

  if (isStandalone) return 'unsupported';
  if (isIOS) return 'ios';
  if (isAndroid) return 'android';
  return 'desktop';
}

function isRecentlyDismissed(): boolean {
  if (typeof window === 'undefined') return true;
  const raw = window.localStorage.getItem(DISMISS_KEY);
  if (!raw) return false;
  const ts = Number(raw);
  if (!Number.isFinite(ts)) return false;
  const ageDays = (Date.now() - ts) / (1000 * 60 * 60 * 24);
  return ageDays < DISMISS_DAYS;
}

export default function InstallPWAPrompt() {
  const [platform, setPlatform] = useState<Platform>('unsupported');
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [visible, setVisible] = useState(false);
  const [showIOSModal, setShowIOSModal] = useState(false);

  useEffect(() => {
    if (isRecentlyDismissed()) return;

    const detected = detectPlatform();
    setPlatform(detected);

    if (detected === 'ios') {
      setVisible(true);
      return;
    }

    if (detected === 'android' || detected === 'desktop') {
      const handler = (e: Event) => {
        e.preventDefault();
        setDeferredPrompt(e as BeforeInstallPromptEvent);
        setVisible(true);
      };
      window.addEventListener('beforeinstallprompt', handler);
      return () => window.removeEventListener('beforeinstallprompt', handler);
    }
  }, []);

  const dismiss = () => {
    window.localStorage.setItem(DISMISS_KEY, String(Date.now()));
    setVisible(false);
    setShowIOSModal(false);
  };

  const handleInstallClick = async () => {
    if (platform === 'ios') {
      setShowIOSModal(true);
      return;
    }
    if (!deferredPrompt) return;
    await deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') {
      window.localStorage.setItem(DISMISS_KEY, String(Date.now()));
      setVisible(false);
    }
    setDeferredPrompt(null);
  };

  if (!visible) return null;

  return (
    <>
      <div className="fixed bottom-4 left-4 right-4 z-50 mx-auto max-w-md rounded-2xl border border-white/10 bg-slate-900/95 px-4 py-3 shadow-2xl backdrop-blur-lg sm:left-auto sm:right-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-500/20 text-blue-300">
            <Smartphone size={20} />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-white">Instalá IAlingo</p>
            <p className="truncate text-xs text-blue-200/70">
              {platform === 'ios' ? 'Agregala a tu pantalla de inicio' : 'Acceso rápido desde tu pantalla'}
            </p>
          </div>
          <button
            onClick={handleInstallClick}
            className="flex items-center gap-1.5 rounded-xl bg-blue-500 px-3 py-2 text-sm font-semibold text-white transition hover:bg-blue-400 active:scale-95"
          >
            <Download size={14} />
            Instalar
          </button>
          <button
            onClick={dismiss}
            aria-label="Cerrar"
            className="rounded-lg p-1.5 text-blue-200/60 transition hover:bg-white/5 hover:text-white"
          >
            <X size={16} />
          </button>
        </div>
      </div>

      {showIOSModal && (
        <div
          className="fixed inset-0 z-[60] flex items-end justify-center bg-black/70 backdrop-blur-sm sm:items-center"
          onClick={dismiss}
        >
          <div
            className="w-full max-w-md rounded-t-3xl border border-white/10 bg-slate-900 p-6 shadow-2xl sm:rounded-3xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mb-5 flex items-center justify-between">
              <h2 className="text-lg font-bold text-white">Instalar en iPhone</h2>
              <button
                onClick={dismiss}
                aria-label="Cerrar"
                className="rounded-lg p-1.5 text-blue-200/60 hover:bg-white/5 hover:text-white"
              >
                <X size={20} />
              </button>
            </div>

            <ol className="space-y-4">
              <li className="flex items-start gap-3">
                <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-blue-500 text-sm font-bold text-white">
                  1
                </span>
                <div className="pt-0.5">
                  <p className="text-sm text-white">
                    Tocá el botón <span className="font-semibold">Compartir</span>
                  </p>
                  <div className="mt-1 inline-flex items-center gap-1.5 rounded-lg bg-white/5 px-2 py-1 text-xs text-blue-200">
                    <Share size={14} />
                    en la barra inferior de Safari
                  </div>
                </div>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-blue-500 text-sm font-bold text-white">
                  2
                </span>
                <div className="pt-0.5">
                  <p className="text-sm text-white">
                    Buscá <span className="font-semibold">Agregar a pantalla de inicio</span>
                  </p>
                  <div className="mt-1 inline-flex items-center gap-1.5 rounded-lg bg-white/5 px-2 py-1 text-xs text-blue-200">
                    <Plus size={14} />
                    deslizá la lista si no aparece
                  </div>
                </div>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-blue-500 text-sm font-bold text-white">
                  3
                </span>
                <div className="pt-0.5">
                  <p className="text-sm text-white">
                    Tocá <span className="font-semibold">Agregar</span> arriba a la derecha
                  </p>
                  <p className="mt-1 text-xs text-blue-200/70">
                    Listo: IAlingo aparece como una app más en tu iPhone.
                  </p>
                </div>
              </li>
            </ol>

            <button
              onClick={dismiss}
              className="mt-6 w-full rounded-2xl bg-white/10 py-3 text-sm font-semibold text-white transition hover:bg-white/15"
            >
              Entendido
            </button>
          </div>
        </div>
      )}
    </>
  );
}
