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

    const today = new Date().toISOString().split('T')[0];
    const wp = getWebPush();

    let sent = 0;
    let skipped = 0;
    let failed = 0;

    for (const sub of subscriptions) {
      try {
        // Check if user completed something today
        const { data: todayProgress } = await supabase
          .from('lesson_progress')
          .select('id')
          .eq('user_id', sub.user_id)
          .eq('status', 'completed')
          .gte('completed_at', `${today}T00:00:00`)
          .limit(1);

        if (todayProgress && todayProgress.length > 0) {
          skipped++;
          continue;
        }

        // Get streak info
        const { data: streak } = await supabase
          .from('streaks')
          .select('current_streak')
          .eq('user_id', sub.user_id)
          .single();

        const currentStreak = streak?.current_streak ?? 0;

        let body: string;
        let tag: string;

        if (currentStreak > 0) {
          body = `¡Tu racha de ${currentStreak} día${currentStreak !== 1 ? 's' : ''} está en peligro! Entra antes de medianoche`;
          tag = 'streak-danger';
        } else {
          body = '¡No pierdas tu racha! Solo te falta una lección';
          tag = 'evening-reminder';
        }

        const payload = JSON.stringify({
          title: 'IAlingo',
          body,
          url: '/dashboard',
          tag,
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

    return NextResponse.json({ sent, skipped, failed });
  } catch (err) {
    console.error('Evening notifications error:', err);
    return NextResponse.json({ error: 'Server error' }, { status: 500 });
  }
}
