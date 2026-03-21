'use client';

import { useState } from 'react';
import { ChevronRight, Wrench, CheckSquare, Square } from 'lucide-react';

interface PracticalTaskStepProps {
  task: string;
  onNext: () => void;
}

export default function PracticalTaskStep({ task, onNext }: PracticalTaskStepProps) {
  const [completed, setCompleted] = useState(false);

  return (
    <div className="flex flex-col min-h-[calc(100dvh-10rem)]">
      <div className="flex-1 overflow-y-auto pb-6">
        {/* Header */}
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 rounded-2xl bg-amber-100 flex items-center justify-center">
            <Wrench className="w-6 h-6 text-amber-600" />
          </div>
          <div>
            <h2 className="text-lg font-bold text-text">Tarea Práctica</h2>
            <p className="text-sm text-text-secondary">Pon en práctica lo aprendido</p>
          </div>
        </div>

        {/* Task card */}
        <div className="bg-amber-50 border border-amber-200/50 rounded-2xl p-5">
          <div className="text-text whitespace-pre-line text-[15px] leading-relaxed">
            {task}
          </div>
        </div>

        {/* Completion checkbox */}
        <button
          onClick={() => setCompleted(!completed)}
          className="mt-6 w-full flex items-center gap-3 p-4 bg-white border border-border rounded-2xl hover:bg-gray-50 transition-colors"
        >
          {completed ? (
            <CheckSquare className="w-6 h-6 text-success shrink-0" />
          ) : (
            <Square className="w-6 h-6 text-gray-300 shrink-0" />
          )}
          <span className={`font-semibold text-sm ${completed ? 'text-success' : 'text-text'}`}>
            Ya completé la tarea práctica
          </span>
        </button>
      </div>

      <div className="sticky bottom-0 pt-4 pb-2 bg-gradient-to-t from-background via-background to-transparent">
        <button
          onClick={onNext}
          disabled={!completed}
          className={`w-full py-4 font-bold rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-[0.98] ${
            completed
              ? 'bg-primary hover:bg-primary-dark text-white'
              : 'bg-gray-200 text-gray-400 cursor-not-allowed'
          }`}
        >
          Siguiente
          <ChevronRight size={20} />
        </button>
      </div>
    </div>
  );
}
