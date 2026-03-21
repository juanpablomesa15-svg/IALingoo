'use client';

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { ChevronRight } from 'lucide-react';
import PapaMascot from '@/components/mascot/PapaMascot';

interface TheoryStepProps {
  content: string;
  onNext: () => void;
}

export default function TheoryStep({ content, onNext }: TheoryStepProps) {
  return (
    <div className="relative flex flex-col min-h-[calc(100dvh-10rem)]">
      <div className="flex-1 overflow-y-auto pb-6">
        <div className="prose-lesson">
          <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
        </div>
      </div>

      {/* Floating mascot */}
      <div className="fixed bottom-28 right-4 z-10 opacity-80 pointer-events-none md:right-8">
        <PapaMascot state="thinking" size="sm" />
      </div>

      <div className="sticky bottom-0 pt-4 pb-2 bg-gradient-to-t from-background via-background to-transparent">
        <button
          onClick={onNext}
          className="w-full py-4 bg-primary hover:bg-primary-dark text-white font-bold rounded-2xl flex items-center justify-center gap-2 transition-colors active:scale-[0.98]"
        >
          Siguiente
          <ChevronRight size={20} />
        </button>
      </div>
    </div>
  );
}
