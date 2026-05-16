import React, { useState } from 'react';
import { Skull, Users, Gamepad2, Zap } from 'lucide-react';

const slides = [
  {
    id: 1,
    icon: <Skull size={80} color="#DDB7FF" style={{ filter: 'drop-shadow(0 0 20px #DDB7FF)' }} />,
    title: "COUSIN CHAOS",
    subtitle: "The party game that ruins friendships.",
  },
  {
    id: 2,
    icon: <Users size={80} color="#92DBFF" style={{ filter: 'drop-shadow(0 0 20px #92DBFF)' }} />,
    title: "ADD YOUR CREW",
    subtitle: "Who's brave enough to play today?",
  },
  {
    id: 3,
    icon: <Gamepad2 size={80} color="#FF5167" style={{ filter: 'drop-shadow(0 0 20px #FF5167)' }} />,
    title: "PICK A MODE",
    subtitle: "Truth or Dare, Impostor, or Bomb Pass.",
  },
  {
    id: 4,
    icon: <Zap size={80} color="#DDB7FF" style={{ filter: 'drop-shadow(0 0 20px #DDB7FF)' }} />,
    title: "START THE CHAOS",
    subtitle: "No rules. No mercy. Just chaos.",
  }
];

export function SwipeCards() {
  const [currentSlide, setCurrentSlide] = useState(0);

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(prev => prev + 1);
    } else {
      // End of onboarding action could go here
      setCurrentSlide(0); // Reset for mockup purposes
    }
  };

  const slide = slides[currentSlide];

  return (
    <div 
      className="flex flex-col h-[100dvh] w-full overflow-hidden relative"
      style={{ 
        backgroundColor: '#0A0512',
        color: '#EADEF3',
        fontFamily: 'Sora, sans-serif'
      }}
    >
      {/* Background ambient glow */}
      <div 
        className="absolute top-[-20%] left-[-20%] w-[140%] h-[140%] opacity-20 pointer-events-none"
        style={{
          background: 'radial-gradient(circle at 50% 50%, #DDB7FF 0%, transparent 60%)',
          filter: 'blur(80px)'
        }}
      />

      <div className="flex-1 flex flex-col items-center justify-center p-8 z-10">
        <div 
          className="w-full max-w-sm rounded-3xl p-8 flex flex-col items-center text-center transition-all duration-500 transform"
          style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(10px)',
            boxShadow: '0 20px 40px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.1)'
          }}
        >
          <div className="mb-8 p-6 rounded-full bg-black/40 border border-white/5 relative">
            {slide.icon}
          </div>
          
          <h1 
            className="text-4xl mb-4 uppercase tracking-wider font-bold"
            style={{ 
              fontFamily: 'Anybody, sans-serif',
              textShadow: '0 0 20px rgba(255, 255, 255, 0.3)'
            }}
          >
            {slide.title}
          </h1>
          
          <p 
            className="text-lg leading-relaxed"
            style={{ color: '#CFC2D6' }}
          >
            {slide.subtitle}
          </p>
        </div>
      </div>

      <div className="p-8 z-10 flex flex-col items-center gap-8 pb-12">
        {/* Pagination Dots */}
        <div className="flex gap-3">
          {slides.map((s, i) => (
            <div 
              key={s.id}
              className={`h-2 rounded-full transition-all duration-300 ${i === currentSlide ? 'w-8' : 'w-2'}`}
              style={{
                backgroundColor: i === currentSlide ? '#DDB7FF' : 'rgba(255, 255, 255, 0.2)',
                boxShadow: i === currentSlide ? '0 0 10px #DDB7FF' : 'none'
              }}
            />
          ))}
        </div>

        {/* Action Button */}
        <button
          onClick={handleNext}
          className="w-full max-w-sm py-4 rounded-xl text-xl font-bold uppercase tracking-widest transition-all active:scale-95 hover:brightness-110"
          style={{
            backgroundColor: '#FF5167',
            color: '#ffffff',
            fontFamily: 'Anybody, sans-serif',
            boxShadow: '0 0 20px rgba(255, 81, 103, 0.4), inset 0 2px 0 rgba(255, 255, 255, 0.2)'
          }}
        >
          {currentSlide === slides.length - 1 ? "Let's Chaos!" : "Next"}
        </button>
      </div>
    </div>
  );
}

export default SwipeCards;