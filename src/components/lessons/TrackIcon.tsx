'use client';

import {
  Sparkles,
  Brain,
  Palette,
  Globe,
  Workflow,
  Database,
  Bot,
  Rocket,
  MessageSquare,
  Code,
  Plug,
  Image as ImageIcon,
  Video,
  LayoutDashboard,
  Layout,
  Zap,
  Webhook,
  Shield,
  Server,
  Cpu,
  Network,
  Lightbulb,
  Target,
  BookOpen,
  type LucideIcon,
} from 'lucide-react';

const ICONS: Record<string, LucideIcon> = {
  sparkles: Sparkles,
  brain: Brain,
  palette: Palette,
  globe: Globe,
  workflow: Workflow,
  database: Database,
  bot: Bot,
  rocket: Rocket,
  'message-square': MessageSquare,
  code: Code,
  plug: Plug,
  image: ImageIcon,
  video: Video,
  'layout-dashboard': LayoutDashboard,
  layout: Layout,
  zap: Zap,
  webhook: Webhook,
  shield: Shield,
  server: Server,
  cpu: Cpu,
  network: Network,
  lightbulb: Lightbulb,
  target: Target,
};

interface TrackIconProps {
  name: string;
  size?: number;
  className?: string;
  strokeWidth?: number;
}

export default function TrackIcon({
  name,
  size = 24,
  className,
  strokeWidth = 2,
}: TrackIconProps) {
  const Icon = ICONS[name] ?? BookOpen;
  return <Icon size={size} className={className} strokeWidth={strokeWidth} />;
}
