import React, { useState } from 'react';
import { MessageCircle, UserX, Bomb, HelpCircle, Hand, Shield, Flame, Users, Archive, Settings, User } from 'lucide-react';

const COLORS = {
  bg: '#0A0512',
  primary: '#DDB7FF',
  containerPrimary: '#B76DFF',
  cyan: '#92DBFF',
  containerCyan: '#00C4FD',
  pink: '#FF5167',
  gold: '#FFD700',
  text: '#EADEF3',
  muted: '#988D9F',
  surface: 'rgba(255,255,255,0.05)',
  border: 'rgba(255,255,255,0.15)',
};

export function HomeScreen() {
  const [activeTab, setActiveTab] = useState('chaos');

  const modes = [
    { name: 'Truth or Dare', tag: 'CLASSIC', icon: MessageCircle, gradient: 'from-[#00C4FD] to-[#0052FF]' },
    { name: 'Impostor', tag: 'SOCIAL', icon: UserX, gradient: 'from-[#00FF87] to-[#008A4A]' },
    { name: 'Bomb Pass', tag: 'STRESS', icon: Bomb, gradient: 'from-[#FF5167] to-[#FF9E00]' },
    { name: 'Would You Rather', tag: 'DILEMMA', icon: HelpCircle, gradient: 'from-[#B76DFF] to-[#6000FF]' },
    { name: 'Never Have I Ever', tag: 'EXPOSE', icon: Hand, gradient: 'from-[#FF5167] to-[#FF00D4]' },
    { name: 'Alibi', tag: 'DECEPTION', icon: Shield, gradient: 'from-[#00C4FD] to-[#00FFB3]' },
  ];

  return (
    <div style={{ backgroundColor: COLORS.bg, color: COLORS.text, fontFamily: '"Plus Jakarta Sans", sans-serif' }} className="w-full max-w-[390px] h-[844px] relative mx-auto overflow-hidden flex flex-col shadow-2xl ring-1 ring-white/10 sm:rounded-[40px]">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Anybody:wght@900&family=Sora:wght@600&family=Plus+Jakarta+Sans:wght@400;500;700&display=swap');
        .font-anybody { font-family: 'Anybody', sans-serif; }
        .font-sora { font-family: 'Sora', sans-serif; }
        .glow-text { text-shadow: 0 0 15px rgba(221, 183, 255, 0.5); }
        .glass-card {
          background: ${COLORS.surface};
          border: 1px solid ${COLORS.border};
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
        }
        .pulse-red {
          animation: pulse-red 2s infinite;
        }
        @keyframes pulse-red {
          0% { box-shadow: 0 0 0 0 rgba(255, 81, 103, 0.7); }
          70% { box-shadow: 0 0 0 6px rgba(255, 81, 103, 0); }
          100% { box-shadow: 0 0 0 0 rgba(255, 81, 103, 0); }
        }
        /* Hide scrollbar for Chrome, Safari and Opera */
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        /* Hide scrollbar for IE, Edge and Firefox */
        .no-scrollbar {
          -ms-overflow-style: none;  /* IE and Edge */
          scrollbar-width: none;  /* Firefox */
        }
      `}</style>

      {/* Radial Gradient BG */}
      <div className="absolute top-[-10%] left-1/2 -translate-x-1/2 w-[300px] h-[300px] bg-[#B76DFF] rounded-full blur-[100px] opacity-30 pointer-events-none" />

      {/* Main Scrollable Area */}
      <div className="flex-1 overflow-y-auto pb-[100px] no-scrollbar relative z-10">
        {/* Header */}
        <div className="flex items-center justify-between p-6 pt-12">
          <h1 className="text-2xl font-anybody tracking-wider glow-text" style={{ color: COLORS.primary }}>
            COUSIN CHAOS
          </h1>
          <button className="w-10 h-10 rounded-full flex items-center justify-center glass-card hover:bg-white/10 transition-colors">
            <User size={20} color={COLORS.primary} />
          </button>
        </div>

        {/* Chaos Meter */}
        <div className="px-6 mb-8">
          <div className="glass-card rounded-2xl p-5">
            <div className="flex justify-between items-end mb-3">
              <div>
                <div className="text-[10px] font-sora tracking-widest mb-1" style={{ color: COLORS.muted }}>CURRENT STATUS</div>
                <div className="text-lg font-sora tracking-wide">CHAOS LEVEL</div>
              </div>
              <div className="px-3 py-1 rounded-full text-[10px] font-sora font-bold tracking-widest pulse-red bg-[#FF5167]/20 text-[#FF5167] border border-[#FF5167]/30">
                CRITICAL
              </div>
            </div>
            
            <div className="h-4 rounded-full bg-black/40 border border-white/5 overflow-hidden">
              <div 
                className="h-full rounded-full bg-gradient-to-r from-[#B76DFF] via-[#00C4FD] to-[#FF5167]"
                style={{ width: '85%', boxShadow: '0 0 10px rgba(255, 81, 103, 0.5)' }}
              />
            </div>
          </div>
        </div>

        {/* Game Modes */}
        <div className="px-6">
          <h2 className="text-xs font-sora font-bold tracking-widest mb-4" style={{ color: COLORS.muted }}>CHOOSE YOUR CHAOS</h2>
          
          <div className="grid grid-cols-2 gap-4 pb-6">
            {modes.map((mode, i) => (
              <div key={i} className="glass-card rounded-2xl overflow-hidden flex flex-col group cursor-pointer hover:bg-white/10 transition-colors">
                <div className={\`h-24 bg-gradient-to-br \${mode.gradient} flex items-center justify-center relative\`}>
                  <div className="absolute inset-0 bg-black/20 mix-blend-overlay" />
                  <mode.icon size={36} color="white" className="relative z-10 opacity-90 group-hover:scale-110 transition-transform duration-300" />
                </div>
                <div className="p-4 flex-1 flex flex-col gap-1">
                  <div className="text-[9px] font-sora tracking-widest font-bold" style={{ color: COLORS.primary }}>
                    {mode.tag}
                  </div>
                  <div className="font-sora text-sm leading-tight mt-auto">
                    {mode.name}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Nav */}
      <div className="absolute bottom-6 left-6 right-6 h-[72px] glass-card rounded-full flex items-center justify-between px-2 z-20">
        {[
          { id: 'chaos', icon: Flame, label: 'Chaos' },
          { id: 'crew', icon: Users, label: 'Crew' },
          { id: 'vault', icon: Archive, label: 'Vault' },
          { id: 'settings', icon: Settings, label: 'Settings' },
        ].map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className="flex-1 flex flex-col items-center justify-center h-full gap-1 relative"
          >
            {activeTab === tab.id && (
              <div className="absolute inset-0 bg-white/5 rounded-full" />
            )}
            <tab.icon 
              size={24} 
              color={activeTab === tab.id ? COLORS.primary : COLORS.muted} 
              className={activeTab === tab.id ? 'relative z-10' : 'relative z-10 opacity-70'}
              style={activeTab === tab.id ? { filter: 'drop-shadow(0 0 8px rgba(221,183,255,0.8))' } : {}}
            />
            <span 
              className="text-[10px] font-sora font-medium relative z-10"
              style={{ color: activeTab === tab.id ? COLORS.primary : COLORS.muted, opacity: activeTab === tab.id ? 1 : 0.7 }}
            >
              {tab.label}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

export default HomeScreen;
