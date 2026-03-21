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
          title: 'IAlingo',
          body: '¡Buenos días! Tu lección de IA te espera',
          url: '/dashboard',
          tag: 'morning-reminder',
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
    console.error('Daily notifications error:', err);
    return NextResponse.json({ error: 'Server error' }, { status: 500 });
  }
}
