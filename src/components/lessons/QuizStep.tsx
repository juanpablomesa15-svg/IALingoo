'use client';

import { useState, useEffect } from 'react';
import { ChevronRight, CheckCircle2, XCircle } from 'lucide-react';
import PapaMascot from '@/components/mascot/PapaMascot';
import type { MascotState } from '@/components/mascot/PapaMascot';
import type { Quiz } from '@/lib/types/database';

interface QuizStepProps {
  quiz: Quiz;
  questionNumber: number;
  totalQuestions: number;
  onAnswer: (selectedIndex: number, isCorrect: boolean) => void;
  onNext: () => void;
}

export default function QuizStep({
  quiz,
  questionNumber,
  totalQuestions,
  onAnswer,
  onNext,
}: QuizStepProps) {
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [answered, setAnswered] = useState(false);
  const [mascotState, setMascotState] = useState<MascotState>('thinking');

  const options: string[] = typeof quiz.options === 'string'
    ? JSON.parse(quiz.options)
    : quiz.options;

  const isCorrect = selectedIndex === quiz.correct_index;

  // Reset mascot state when quiz changes
  useEffect(() => {
    setMascotState('thinking');
  }, [quiz.id]);

  function handleSelect(index: number) {
    if (answered) return;
    setSelectedIndex(index);
    setAnswered(true);
    const correct = index === quiz.correct_index;
    onAnswer(index, correct);

    // Show reaction, then return to thinking after 2s
    setMascotState(correct ? 'celebrating' : 'oops');
    setTimeout(() => setMascotState('thinking'), 2000);
  }

  function getOptionStyle(index: number) {
    if (!answered) {
      return 'bg-white border-border hover:border-primary hover:bg-blue-50/50';
    }
    if (index === quiz.correct_index) {
      return 'bg-emerald-50 border-success';
    }
    if (index === selectedIndex && !isCorrect) {
      return 'bg-red-50 border-danger';
    }
    return 'bg-white border-border opacity-50';
  }

  function getOptionIcon(index: number) {
    if (!answered) return null;
    if (index === quiz.correct_index) {
      return <CheckCircle2 className="w-5 h-5 text-success shrink-0" />;
    }
    if (index === selectedIndex && !isCorrect) {
      return <XCircle className="w-5 h-5 text-danger shrink-0" />;
    }
    return null;
  }

  return (
    <div className="flex flex-col min-h-[calc(100dvh-10rem)]">
      <div className="flex-1 overflow-y-auto pb-6">
        {/* Progress indicator */}
        <div className="flex items-center gap-2 mb-6">
          {Array.from({ length: totalQuestions }).map((_, i) => (
            <div
              key={i}
              className={`h-1.5 flex-1 rounded-full transition-colors ${
                i < questionNumber ? 'bg-success' : i === questionNumber ? 'bg-primary' : 'bg-gray-200'
              }`}
            />
          ))}
        </div>

        {/* Question number */}
        <p className="text-sm font-semibold text-primary mb-2">
          Pregunta {questionNumber + 1} de {totalQuestions}
        </p>

        {/* Mascot */}
        <div className="flex justify-center mb-4">
          <PapaMascot state={mascotState} size="md" />
        </div>

        {/* Question */}
        <h2 className="text-xl font-bold text-text mb-6 leading-snug">
          {quiz.question}
        </h2>

        {/* Options */}
        <div className="space-y-3">
          {options.map((option, index) => (
            <button
              key={index}
              onClick={() => handleSelect(index)}
              disabled={answered}
              className={`w-full text-left p-4 rounded-2xl border-2 transition-all duration-200 flex items-center gap-3 min-h-[56px] ${getOptionStyle(index)} ${
                !answered ? 'active:scale-[0.98] cursor-pointer' : ''
              }`}
            >
              <span className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 text-sm font-bold ${
                answered && index === quiz.correct_index
                  ? 'bg-success text-white'
                  : answered && index === selectedIndex && !isCorrect
                    ? 'bg-danger text-white'
                    : 'bg-gray-100 text-text-secondary'
              }`}>
                {String.fromCharCode(65 + index)}
              </span>
              <span className="flex-1 text-[15px] font-medium text-text leading-snug">
                {option}
              </span>
              {getOptionIcon(index)}
            </button>
          ))}
        </div>

        {/* Feedback */}
        {answered && (
          <div
            className={`mt-6 p-4 rounded-2xl ${
              isCorrect
                ? 'bg-emerald-50 border border-success/30'
                : 'bg-red-50 border border-danger/30'
            }`}
          >
            <div className="flex items-center gap-2 mb-1">
              {isCorrect ? (
                <CheckCircle2 className="w-5 h-5 text-success" />
              ) : (
                <XCircle className="w-5 h-5 text-danger" />
              )}
              <p className={`font-bold text-sm ${isCorrect ? 'text-success' : 'text-danger'}`}>
                {isCorrect ? '¡Correcto!' : 'Incorrecto'}
              </p>
            </div>
            <p className="text-sm text-text-secondary mt-1">
              {quiz.explanation}
            </p>
          </div>
        )}
      </div>

      {answered && (
        <div className="sticky bottom-0 pt-4 pb-2 bg-gradient-to-t from-background via-background to-transparent">
          <button
            onClick={onNext}
            className="w-full py-4 bg-primary hover:bg-primary-dark text-white font-bold rounded-2xl flex items-center justify-center gap-2 transition-colors active:scale-[0.98]"
          >
            {questionNumber < totalQuestions - 1 ? 'Siguiente pregunta' : 'Ver resultados'}
            <ChevronRight size={20} />
          </button>
        </div>
      )}
    </div>
  );
}
