'use client';

import { useState, useEffect } from 'react';
import { Bell, X } from 'lucide-react';
import PapaMascot from '@/components/mascot/PapaMascot';
import { isPushSupported, registerPushSubscription } from '@/lib/utils/push';
import { createClient } from '@/lib/supabase/client';

interface NotificationPromptProps {
  userId: string;
}

export default function NotificationPrompt({ userId }: NotificationPromptProps) {
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Only show if push is supported, not yet asked, and permission not already decided
    if (!isPushSupported()) return;
    if (Notification.permission !== 'default') return;

    // Check if we've already dismissed this prompt
    const dismissed = localStorage.getItem('push-prompt-dismissed');
    if (dismissed) return;

    // Show after a short delay
    const timer = setTimeout(() => setShow(true), 2000);
    return () => clearTimeout(timer);
  }, []);

  async function handleAccept() {
    setLoading(true);
    try {
      const subscription = await registerPushSubscription();
      if (subscription) {
        // Save to API
        await fetch('/api/notifications/subscribe', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            userId,
            subscription: subscription.toJSON(),
          }),
        });
      }
    } catch (err) {
      console.error('Error subscribing:', err);
    } finally {
      setShow(false);
      setLoading(false);
    }
  }

  function handleDismiss() {
    localStorage.setItem('push-prompt-dismissed', 'true');
    setShow(false);
  }

  if (!show) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-4 bg-black/30">
      <div className="w-full max-w-sm bg-white rounded-2xl shadow-xl p-6 relative">
        <button
          onClick={handleDismiss}
          className="absolute top-3 right-3 w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-text-secondary hover:bg-gray-200 transition-colors"
        >
          <X size={16} />
        </button>

        <div className="flex justify-center mb-4">
          <PapaMascot state="normal" size="md" />
        </div>

        <div className="text-center mb-6">
          <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
            <Bell className="w-6 h-6 text-primary" />
          </div>
          <h3 className="text-lg font-bold text-text mb-1">
            ¡No pierdas tu racha!
          </h3>
          <p className="text-sm text-text-secondary">
            Activa recordatorios para no olvidar tu lección diaria y mantener tu racha
          </p>
        </div>

        <div className="space-y-3">
          <button
            onClick={handleAccept}
            disabled={loading}
            className="w-full py-3.5 bg-primary hover:bg-primary-dark text-white font-bold rounded-xl transition-colors active:scale-[0.98] disabled:opacity-60"
          >
            {loading ? 'Activando...' : '¡Sí, recuérdame!'}
          </button>
          <button
            onClick={handleDismiss}
            className="w-full py-3.5 text-text-secondary font-medium hover:text-text transition-colors"
          >
            Ahora no
          </button>
        </div>
      </div>
    </div>
  );
}
