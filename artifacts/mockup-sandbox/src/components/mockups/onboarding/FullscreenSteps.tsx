import React, { useState } from 'react';
import { Flame, Users, Gamepad2, ArrowRight } from 'lucide-react';

export function FullscreenSteps() {
  const [step, setStep] = useState(1);

  const nextStep = () => {
    if (step < 3) {
      setStep(step + 1);
    }
  };

  const steps = [
    {
      id: 1,
      title: "THE CHAOS AWAITS",
      subtitle: "party games for groups",
      icon: <Flame size={120} color="#DDB7FF" />,
      bgGradient: "radial-gradient(circle at top, #3A1C61 0%, #0A0512 80%)",
      glowColor: "rgba(221, 183, 255, 0.4)",
    },
    {
      id: 2,
      title: "YOUR CREW, YOUR RULES",
      subtitle: "add players & customize",
      icon: <Users size={120} color="#92DBFF" />,
      bgGradient: "radial-gradient(circle at top, #14496B 0%, #0A0512 80%)",
      glowColor: "rgba(146, 219, 255, 0.4)",
    },
    {
      id: 3,
      title: "READY TO PLAY",
      subtitle: "6 game modes await",
      icon: <Gamepad2 size={120} color="#FF5167" />,
      bgGradient: "radial-gradient(circle at top, #661931 0%, #3A1C61 80%)",
      glowColor: "rgba(255, 81, 103, 0.4)",
    }
  ];

  const currentStepData = steps[step - 1];

  return (
    <div 
      className="relative w-full h-[100dvh] flex flex-col text-[#EADEF3] overflow-hidden transition-all duration-700 ease-in-out font-sans"
      style={{ background: currentStepData.bgGradient }}
    >
      <style>
        {`
          @keyframes floatPulse {
            0% { transform: translateY(0px) scale(1); filter: drop-shadow(0 0 20px var(--glow)); }
            50% { transform: translateY(-15px) scale(1.05); filter: drop-shadow(0 0 50px var(--glow)); }
            100% { transform: translateY(0px) scale(1); filter: drop-shadow(0 0 20px var(--glow)); }
          }
          .animate-float-pulse {
            animation: floatPulse 4s ease-in-out infinite;
          }
          @keyframes slideUpFade {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
          }
          .animate-slide-up {
            animation: slideUpFade 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
          }
        `}
      </style>

      {/* Top Bar */}
      <div className="absolute top-0 w-full p-6 flex justify-end z-10">
        <div className="text-sm tracking-[0.2em] font-medium opacity-60">
          {step} / 3
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col items-center justify-center p-6 text-center z-10">
        <div 
          className="mt-16 mb-12 relative flex items-center justify-center w-full max-w-[200px] aspect-square"
          style={{ '--glow': currentStepData.glowColor } as React.CSSProperties}
        >
          {/* Background blurred glow */}
          <div 
            className="absolute inset-0 rounded-full blur-[60px] opacity-60 transition-colors duration-700"
            style={{ backgroundColor: currentStepData.glowColor }}
          />
          <div className="relative z-10 animate-float-pulse transition-all duration-700">
            {currentStepData.icon}
          </div>
        </div>

        <div className="flex-1 flex flex-col justify-end pb-8 w-full animate-slide-up" key={`content-\${step}`}>
          <h1 className="text-5xl sm:text-6xl font-black uppercase tracking-tighter leading-[0.9] mb-6 drop-shadow-lg">
            {currentStepData.title}
          </h1>
          <p className="text-xl sm:text-2xl font-light tracking-wide opacity-80 mb-4">
            {currentStepData.subtitle}
          </p>
        </div>
      </div>

      {/* Bottom Area */}
      <div className="w-full p-6 pb-10 z-10">
        <button
          onClick={nextStep}
          className="group relative w-full overflow-hidden rounded-full font-bold text-lg tracking-wider uppercase h-16 flex items-center justify-center transition-transform active:scale-95"
          style={{
            background: step === 3 ? "linear-gradient(90deg, #FF5167, #DDB7FF)" : "linear-gradient(90deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05))",
            color: step === 3 ? "#0A0512" : "#EADEF3",
            boxShadow: step === 3 ? "0 0 30px rgba(255, 81, 103, 0.4)" : "inset 0 0 0 1px rgba(255,255,255,0.2)"
          }}
        >
          <span className="relative z-10 flex items-center gap-3">
            {step === 3 ? "UNLEASH THE CHAOS" : "Continue"} 
            {step < 3 && <ArrowRight className="group-hover:translate-x-1 transition-transform" />}
          </span>
          {step < 3 && (
            <div className="absolute inset-0 bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity" />
          )}
        </button>
      </div>
    </div>
  );
}

export default FullscreenSteps;