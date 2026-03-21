'use client';

import { useState, useEffect } from 'react';
import { Bell, BellOff } from 'lucide-react';
import { isPushSupported, isPushPermissionGranted, registerPushSubscription, unregisterPushSubscription } from '@/lib/utils/push';
import { createClient } from '@/lib/supabase/client';

interface NotificationToggleProps {
  userId: string;
  initialActive: boolean;
}

export default function NotificationToggle({ userId, initialActive }: NotificationToggleProps) {
  const [supported, setSupported] = useState(false);
  const [active, setActive] = useState(initialActive);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setSupported(isPushSupported());
  }, []);

  if (!supported) return null;

  async function handleToggle() {
    setLoading(true);
    const supabase = createClient();

    try {
      if (active) {
        // Deactivate
        await unregisterPushSubscription();
        await supabase
          .from('push_subscriptions')
          .update({ is_active: false })
          .eq('user_id', userId);
        setActive(false);
      } else {
        // Activate
        const subscription = await registerPushSubscription();
        if (subscription) {
          await fetch('/api/notifications/subscribe', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId, subscription: subscription.toJSON() }),
          });
          setActive(true);
        }
      }
    } catch (err) {
      console.error('Toggle error:', err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="bg-white border border-border rounded-2xl p-4 flex items-center gap-4">
      <div className={`w-11 h-11 rounded-xl ${active ? 'bg-primary/10' : 'bg-gray-100'} flex items-center justify-center`}>
        {active ? (
          <Bell className="w-5 h-5 text-primary" />
        ) : (
          <BellOff className="w-5 h-5 text-text-secondary" />
        )}
      </div>
      <div className="flex-1">
        <p className="text-sm text-text-secondary">Recordatorios</p>
        <p className="text-sm font-bold text-text">
          {active ? 'Activados' : 'Desactivados'}
        </p>
      </div>
      <button
        onClick={handleToggle}
        disabled={loading}
        className={`relative w-12 h-7 rounded-full transition-colors duration-200 ${
          active ? 'bg-primary' : 'bg-gray-300'
        } ${loading ? 'opacity-50' : ''}`}
      >
        <div
          className={`absolute top-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform duration-200 ${
            active ? 'translate-x-5' : 'translate-x-0.5'
          }`}
        />
      </button>
    </div>
  );
}
