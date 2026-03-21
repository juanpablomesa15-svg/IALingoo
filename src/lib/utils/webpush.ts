import webpush from 'web-push';

let initialized = false;

export function getWebPush() {
  if (!initialized) {
    const publicKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
    const privateKey = process.env.VAPID_PRIVATE_KEY;
    if (publicKey && privateKey) {
      webpush.setVapidDetails('mailto:noreply@ialingo.app', publicKey, privateKey);
      initialized = true;
    }
  }
  return webpush;
}
