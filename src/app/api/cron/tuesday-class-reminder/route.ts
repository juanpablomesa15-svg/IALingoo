import { NextRequest, NextResponse } from 'next/server';
import type webpush from 'web-push';
import { getWebPush } from '@/lib/utils/webpush';
import { createClient } from '@supabase/supabase-js';

export async function GET(request: NextRequest) {
  // Verify CRON secret
  const authHeader = request.headers.get('authorization');
  const cronSecret = process.env.CRON_SECRET;
  if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Only run on Tuesdays (day 2)
  const today = new Date();
  if (today.getDay() !== 2) {
    return NextResponse.json({ skipped: true, reason: 'Not Tuesday' });
  }

  try {
    const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    const { data: subscriptions } = await supabase
      .from('push_subscriptions')
      .select('user_id, subscription_data')
      .eq('is_active', true);

    if (!subscriptions || subscriptions.length === 0) {
      return NextResponse.json({ sent: 0 });
    }

    const wp = getWebPush();
    let sent = 0;
    let failed = 0;

    for (const sub of subscriptions) {
      try {
        const payload = JSON.stringify({
          title: 'IAlingo - Martes de clase',
          body: '¡Es martes! Ingresa a Lab10.ai y avanza en tus módulos. Empieza por los Beginner si aún no lo has hecho.',
          url: 'https://lab10.ai/',
          tag: 'tuesday-class-reminder',
        });

        await wp.sendNotification(
          sub.subscription_data as webpush.PushSubscription,
          payload
        );
        sent++;
      } catch (err: unknown) {
        const statusCode = (err as { statusCode?: number })?.statusCode;
        if (statusCode === 410 || statusCode === 404) {
          await supabase
            .from('push_subscriptions')
            .update({ is_active: false })
            .eq('user_id', sub.user_id);
        }
        failed++;
      }
    }

    return NextResponse.json({ sent, failed });
  } catch (err) {
    console.error('Tuesday class reminder error:', err);
    return NextResponse.json({ error: 'Server error' }, { status: 500 });
  }
}
