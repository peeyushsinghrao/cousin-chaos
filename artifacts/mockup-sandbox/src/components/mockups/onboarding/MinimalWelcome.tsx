import React, { useState } from 'react';
import { Sparkles, Skull, Bomb, Users, Flame, Dice5, ArrowRight, User } from 'lucide-react';

export function MinimalWelcome() {
  const [step, setStep] = useState(0);
  const [crewName, setCrewName] = useState('');

  const colors = {
    bg: '#0A0512',
    primary: '#DDB7FF',
    cyan: '#92DBFF',
    pink: '#FF5167',
    text: '#EADEF3',
    muted: '#988D9F'
  };

  const gameModes = [
    { name: 'Truth', icon: <User size={16} />, color: colors.cyan },
    { name: 'Dare', icon: <Flame size={16} />, color: colors.pink },
    { name: 'Impostor', icon: <Skull size={16} />, color: colors.primary },
    { name: 'Bomb', icon: <Bomb size={16} />, color: '#FFB84C' },
    { name: 'Alibi', icon: <Users size={16} />, color: colors.cyan },
    { name: 'More...', icon: <Dice5 size={16} />, color: colors.muted },
  ];

  const suggestedNames = ["The Cousins", "Squad Goals", "Night Crew"];

  return (
    <div 
      className="flex flex-col h-[800px] w-[375px] max-w-full mx-auto relative overflow-hidden font-sans"
      style={{ backgroundColor: colors.bg, color: colors.text }}
    >
      {/* Abstract background glows */}
      <div 
        className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-[300px] opacity-20 blur-[80px] pointer-events-none"
        style={{ background: `radial-gradient(circle, ${colors.primary} 0%, transparent 70%)` }}
      />
      <div 
        className="absolute bottom-0 right-0 w-[250px] h-[250px] opacity-10 blur-[80px] pointer-events-none"
        style={{ background: `radial-gradient(circle, ${colors.cyan} 0%, transparent 70%)` }}
      />

      {/* Screen 1: Welcome */}
      <div 
        className={`absolute inset-0 flex flex-col p-6 transition-all duration-700 ease-in-out ${step === 0 ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-full pointer-events-none'}`}
      >
        <div className="flex-1 flex flex-col items-center pt-8">
          <h1 
            className="text-xs tracking-[0.3em] font-bold uppercase mb-auto"
            style={{ color: colors.primary }}
          >
            Cousin Chaos
          </h1>

          <div className="w-full mb-12">
            <div className="grid grid-cols-2 gap-3">
              {gameModes.map((mode, idx) => (
                <div 
                  key={idx}
                  className="flex items-center gap-3 p-4 rounded-2xl border border-white/5 backdrop-blur-md"
                  style={{ backgroundColor: 'rgba(255,255,255,0.03)' }}
                >
                  <div style={{ color: mode.color }}>{mode.icon}</div>
                  <span className="text-sm font-medium tracking-wide">{mode.name}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="text-center mb-8">
            <h2 className="text-2xl font-semibold tracking-tight mb-2">6 game modes.</h2>
            <h2 className="text-2xl font-semibold tracking-tight text-white/50">1 epic night.</h2>
          </div>
        </div>

        <div className="mt-auto flex flex-col gap-4">
          <button 
            onClick={() => setStep(1)}
            className="w-full py-4 rounded-full flex items-center justify-center gap-2 font-bold tracking-wide transition-transform active:scale-[0.98]"
            style={{ 
              background: `linear-gradient(135deg, ${colors.primary}, ${colors.cyan})`,
              color: colors.bg,
              boxShadow: `0 8px 32px -12px ${colors.primary}`
            }}
          >
            GET STARTED <ArrowRight size={18} />
          </button>
          <p className="text-xs text-center font-medium" style={{ color: colors.muted }}>
            No signup needed
          </p>
        </div>
      </div>

      {/* Screen 2: Name your crew */}
      <div 
        className={`absolute inset-0 flex flex-col p-6 transition-all duration-700 ease-in-out ${step === 1 ? 'opacity-100 translate-x-0' : 'opacity-0 translate-x-full pointer-events-none'}`}
      >
        <div className="pt-8 mb-12">
          <button 
            onClick={() => setStep(0)}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-white/5 mb-8"
          >
            <ArrowRight size={16} className="rotate-180" style={{ color: colors.muted }} />
          </button>

          <h2 className="text-3xl font-bold tracking-tight mb-8">
            What should we call<br/>your group?
          </h2>

          <div className="relative mb-8">
            <input 
              type="text"
              value={crewName}
              onChange={(e) => setCrewName(e.target.value)}
              placeholder="Enter crew name..."
              className="w-full bg-transparent border-none text-2xl outline-none pb-2 placeholder:text-white/20"
              style={{ color: colors.cyan }}
            />
            <div className="absolute bottom-0 left-0 w-full h-[2px] bg-white/10">
              <div 
                className="h-full transition-all duration-300"
                style={{ 
                  width: crewName.length > 0 ? '100%' : '0%',
                  backgroundColor: colors.cyan,
                  boxShadow: `0 0 10px ${colors.cyan}`
                }}
              />
            </div>
          </div>

          <div className="flex flex-wrap gap-2">
            {suggestedNames.map((name) => (
              <button
                key={name}
                onClick={() => setCrewName(name)}
                className="px-4 py-2 rounded-full text-sm font-medium border border-white/10 transition-colors"
                style={{ 
                  backgroundColor: crewName === name ? 'rgba(255,255,255,0.1)' : 'transparent',
                  color: crewName === name ? colors.text : colors.muted
                }}
              >
                {name}
              </button>
            ))}
          </div>
        </div>

        <div className="mt-auto">
          <button 
            className="w-full py-4 rounded-full flex items-center justify-center gap-2 font-bold tracking-wide transition-all"
            style={{ 
              background: crewName.length > 0 ? `linear-gradient(135deg, ${colors.primary}, ${colors.pink})` : 'rgba(255,255,255,0.05)',
              color: crewName.length > 0 ? colors.bg : colors.muted,
              boxShadow: crewName.length > 0 ? `0 8px 32px -12px ${colors.pink}` : 'none'
            }}
          >
            LET'S PLAY <ArrowRight size={18} />
          </button>
        </div>
      </div>
    </div>
  );
}
