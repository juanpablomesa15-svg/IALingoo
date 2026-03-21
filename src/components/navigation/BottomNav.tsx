'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import PapaLogo from '@/components/mascot/PapaLogo';
import { Home, BookOpen, Trophy, User, ExternalLink } from 'lucide-react';

const navItems = [
  { href: '/dashboard', label: 'Inicio', icon: Home },
  { href: '/lessons', label: 'Lecciones', icon: BookOpen },
  { href: '/achievements', label: 'Logros', icon: Trophy },
  { href: '/profile', label: 'Perfil', icon: User },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <>
      {/* Mobile bottom nav */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-border z-50 md:hidden safe-area-bottom">
        <div className="flex items-center justify-around py-2 px-2">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-colors min-w-[64px] ${
                  isActive
                    ? 'text-primary bg-primary/10'
                    : 'text-text-secondary hover:text-primary'
                }`}
              >
                <Icon size={24} strokeWidth={isActive ? 2.5 : 2} />
                <span className={`text-xs ${isActive ? 'font-semibold' : 'font-medium'}`}>
                  {item.label}
                </span>
              </Link>
            );
          })}
        </div>
      </nav>

      {/* Desktop sidebar */}
      <nav className="hidden md:flex fixed left-0 top-0 bottom-0 w-64 bg-white border-r border-border flex-col p-6 z-50">
        <Link href="/dashboard" className="flex items-center gap-3 mb-10">
          <PapaLogo size={40} />
          <span className="text-xl font-bold text-text">IAlingo</span>
        </Link>

        <div className="space-y-2 flex-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 ${
                  isActive
                    ? 'bg-primary text-white shadow-md shadow-primary/25'
                    : 'text-text-secondary hover:bg-gray-50 hover:text-text'
                }`}
              >
                <Icon size={22} />
                <span className="font-medium text-base">{item.label}</span>
              </Link>
            );
          })}
        </div>

        {/* Lab10.ai link */}
        <a
          href="https://lab10.ai/"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-3 px-4 py-3 rounded-xl text-text-secondary hover:bg-violet-50 hover:text-violet-600 transition-all duration-200 mt-2 border border-transparent hover:border-violet-200"
        >
          <ExternalLink size={20} />
          <span className="font-medium text-sm">Lab10.ai</span>
        </a>
      </nav>
    </>
  );
}
