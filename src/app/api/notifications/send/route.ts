import { NextRequest, NextResponse } from 'next/server';
import type webpush from 'web-push';
import { getWebPush } from '@/lib/utils/webpush';
import { createClient } from '@supabase/supabase-js';

export async function POST(request: NextRequest) {
  try {
    // Verify API key
    const authHeader = request.headers.get('authorization');
    const apiKey = process.env.CRON_SECRET || process.env.API_SECRET;
    if (!apiKey || authHeader !== `Bearer ${apiKey}`) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { userId, title, body, url, tag } = await request.json();

    if (!userId || !title) {
      return NextResponse.json({ error: 'Missing data' }, { status: 400 });
    }

    const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    const { data: sub } = await supabase
      .from('push_subscriptions')
      .select('subscription_data')
      .eq('user_id', userId)
      .eq('is_active', true)
      .single();

    if (!sub) {
      return NextResponse.json({ error: 'No subscription' }, { status: 404 });
    }

    const wp = getWebPush();
    const payload = JSON.stringify({ title, body, url: url || '/', tag: tag || 'ialingo' });

    await wp.sendNotification(
      sub.subscription_data as webpush.PushSubscription,
      payload
    );

    return NextResponse.json({ ok: true });
  } catch (err: unknown) {
    const statusCode = (err as { statusCode?: number })?.statusCode;
    if (statusCode === 410 || statusCode === 404) {
      return NextResponse.json({ error: 'Subscription expired' }, { status: 410 });
    }
    console.error('Send notification error:', err);
    return NextResponse.json({ error: 'Server error' }, { status: 500 });
  }
}
