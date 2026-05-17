import React from "react";
import { Trophy, Plus, Settings, Gamepad2, ShieldAlert, Zap, Crown } from "lucide-react";

export function CrewScreen() {
  return (
    <div className="relative w-full h-[100dvh] bg-[#0A0512] text-[#EADEF3] overflow-hidden flex flex-col font-sans">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Anybody:wght@900&family=Plus+Jakarta+Sans:wght@400;500;600&family=Sora:wght@600&display=swap');
        
        .font-anybody { font-family: 'Anybody', sans-serif; }
        .font-sora { font-family: 'Sora', sans-serif; }
        .font-jakarta { font-family: 'Plus Jakarta Sans', sans-serif; }

        .glass-surface {
          background: rgba(255, 255, 255, 0.05);
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          border: 1px solid rgba(255, 255, 255, 0.15);
        }

        .neon-shadow-purple { box-shadow: 0 0 20px rgba(183, 109, 255, 0.5); }
        .neon-shadow-cyan { box-shadow: 0 0 20px rgba(0, 196, 253, 0.5); }
        .neon-shadow-pink { box-shadow: 0 0 20px rgba(255, 81, 103, 0.5); }
        .neon-shadow-gold { box-shadow: 0 0 30px rgba(255, 215, 0, 0.6); }

        .text-glow-purple { text-shadow: 0 0 10px rgba(221, 183, 255, 0.8); }
        .text-glow-cyan { text-shadow: 0 0 10px rgba(146, 219, 255, 0.8); }
      `}</style>

      {/* Top Gradient */}
      <div className="absolute top-0 left-0 right-0 h-64 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-[#B76DFF]/30 via-[#0A0512]/0 to-transparent pointer-events-none" />

      {/* Header */}
      <div className="pt-12 pb-4 px-6 relative z-10 flex flex-col items-center">
        <div className="glass-surface px-3 py-1 rounded-full flex items-center gap-2 mb-3 border-[#B76DFF]/30 bg-[#B76DFF]/10">
          <Zap className="w-3.5 h-3.5 text-[#DDB7FF]" />
          <span className="font-sora text-xs text-[#DDB7FF] tracking-wider uppercase">Chaos Season 1</span>
        </div>
        <h1 className="font-anybody text-4xl text-white tracking-wide text-glow-purple uppercase italic">
          Your Crew
        </h1>
      </div>

      {/* Podium Section (~35% of screen height) */}
      <div className="relative flex-shrink-0 h-[220px] sm:h-[260px] flex items-end justify-center px-4 mt-2 mb-8 z-10">
        {/* Podium Base/Platform */}
        <div className="absolute bottom-0 left-[10%] right-[10%] h-8 glass-surface rounded-t-[50%] border-b-0 border-x-0 !border-t-[#DDB7FF]/20 opacity-50 blur-[2px]" />
        <div className="absolute bottom-0 left-[5%] right-[5%] h-[1px] bg-gradient-to-r from-transparent via-[#DDB7FF]/40 to-transparent" />
        <div className="absolute bottom-[-10px] left-[20%] right-[20%] h-[20px] bg-[#B76DFF]/20 blur-xl rounded-[100%]" />

        <div className="flex items-end justify-center gap-1 sm:gap-4 w-full max-w-sm relative pb-4">
          {/* 2nd Place (Left) */}
          <div className="flex flex-col items-center flex-1 pb-2">
            <div className="relative mb-2">
              <div className="w-14 h-14 rounded-full glass-surface flex items-center justify-center border-[#00C4FD] neon-shadow-cyan bg-[#0A0512]">
                <span className="font-anybody text-lg text-white">SK</span>
              </div>
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-5 h-5 rounded-full bg-[#00C4FD] text-[#0A0512] font-sora text-[10px] flex items-center justify-center border border-white/20">
                2
              </div>
            </div>
            <span className="font-sora text-xs text-white mb-0.5 truncate max-w-[80px]">Sam K.</span>
            <span className="font-jakarta text-[10px] text-[#92DBFF]">1,870 CP</span>
            <div className="w-16 h-[60px] mt-2 rounded-t-lg bg-gradient-to-b from-[#00C4FD]/20 to-transparent border-t border-[#00C4FD]/40 relative">
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#00C4FD] neon-shadow-cyan" />
            </div>
          </div>

          {/* 1st Place (Center) */}
          <div className="flex flex-col items-center flex-1 z-10 pb-6">
            <Crown className="w-6 h-6 text-[#FFD700] mb-1 drop-shadow-[0_0_8px_rgba(255,215,0,0.8)]" />
            <div className="relative mb-2">
              <div className="w-[72px] h-[72px] rounded-full glass-surface flex items-center justify-center border-[#FFD700] neon-shadow-gold bg-[#0A0512]">
                <span className="font-anybody text-2xl text-white">AJ</span>
              </div>
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-6 h-6 rounded-full bg-[#FFD700] text-[#0A0512] font-sora text-xs flex items-center justify-center border border-white/20">
                1
              </div>
            </div>
            <span className="font-sora text-sm text-white mb-0.5 mt-1">Alex J.</span>
            <span className="font-jakarta text-xs text-[#FFD700] font-bold">2,400 CP</span>
            <div className="w-[72px] h-[90px] mt-2 rounded-t-lg bg-gradient-to-b from-[#FFD700]/20 to-transparent border-t border-[#FFD700]/40 relative">
              <div className="absolute bottom-0 left-0 right-0 h-1.5 bg-[#FFD700] neon-shadow-gold" />
            </div>
          </div>

          {/* 3rd Place (Right) */}
          <div className="flex flex-col items-center flex-1">
            <div className="relative mb-2">
              <div className="w-12 h-12 rounded-full glass-surface flex items-center justify-center border-[#FF5167] neon-shadow-pink bg-[#0A0512]">
                <span className="font-anybody text-base text-white">R</span>
              </div>
              <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-4 h-4 rounded-full bg-[#FF5167] text-white font-sora text-[9px] flex items-center justify-center border border-white/20">
                3
              </div>
            </div>
            <span className="font-sora text-xs text-white mb-0.5 truncate max-w-[80px]">Riley</span>
            <span className="font-jakarta text-[10px] text-[#FF5167]">1,240 CP</span>
            <div className="w-14 h-[40px] mt-2 rounded-t-lg bg-gradient-to-b from-[#FF5167]/20 to-transparent border-t border-[#FF5167]/40 relative">
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#FF5167] neon-shadow-pink" />
            </div>
          </div>
        </div>
      </div>

      {/* Add Player Button */}
      <div className="px-6 flex justify-center z-10 shrink-0 mb-4">
        <button className="glass-surface px-6 py-3 rounded-full flex items-center justify-center gap-2 w-full max-w-xs active:scale-95 transition-transform bg-[#DDB7FF]/5 hover:bg-[#DDB7FF]/10">
          <Plus className="w-4 h-4 text-[#DDB7FF]" />
          <span className="font-sora text-sm text-[#DDB7FF] tracking-wider uppercase">Add Player</span>
        </button>
      </div>

      {/* Player List */}
      <div className="flex-1 overflow-y-auto px-6 pb-28 z-10 flex flex-col gap-3 no-scrollbar mask-image-b">
        <style>{`
          .no-scrollbar::-webkit-scrollbar { display: none; }
          .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
          .mask-image-b { -webkit-mask-image: linear-gradient(to bottom, black 80%, transparent 100%); mask-image: linear-gradient(to bottom, black 80%, transparent 100%); }
        `}</style>
        
        <div className="text-xs font-sora text-[#988D9F] uppercase tracking-widest mb-1 mt-2">
          All Challengers
        </div>

        {/* Player #4 */}
        <div className="glass-surface rounded-xl p-3 flex items-center gap-3">
          <div className="w-6 font-anybody text-[#988D9F] text-lg text-center">4</div>
          <div className="w-10 h-10 rounded-full bg-[#B76DFF]/20 border border-[#B76DFF]/40 flex items-center justify-center text-[#DDB7FF] font-anybody relative">
            J
            <div className="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-green-500 border border-[#0A0512]" />
          </div>
          <div className="flex-1">
            <div className="font-sora text-sm text-white">Jordan</div>
            <div className="font-jakarta text-xs text-[#DDB7FF]">950 CP</div>
          </div>
          <div className="glass-surface px-2 py-1 rounded bg-black/20">
            <span className="font-jakarta text-xs text-white">65% W</span>
          </div>
        </div>

        {/* Player #5 */}
        <div className="glass-surface rounded-xl p-3 flex items-center gap-3">
          <div className="w-6 font-anybody text-[#988D9F] text-lg text-center">5</div>
          <div className="w-10 h-10 rounded-full bg-[#00C4FD]/20 border border-[#00C4FD]/40 flex items-center justify-center text-[#92DBFF] font-anybody relative">
            C
            <div className="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-green-500 border border-[#0A0512]" />
          </div>
          <div className="flex-1">
            <div className="font-sora text-sm text-white">Casey</div>
            <div className="font-jakarta text-xs text-[#92DBFF]">820 CP</div>
          </div>
          <div className="glass-surface px-2 py-1 rounded bg-black/20">
            <span className="font-jakarta text-xs text-white">58% W</span>
          </div>
        </div>

        {/* Player #6 */}
        <div className="glass-surface rounded-xl p-3 flex items-center gap-3 opacity-60">
          <div className="w-6 font-anybody text-[#988D9F] text-lg text-center">6</div>
          <div className="w-10 h-10 rounded-full bg-[#FF5167]/20 border border-[#FF5167]/40 flex items-center justify-center text-[#FF5167] font-anybody relative">
            M
            <div className="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-gray-500 border border-[#0A0512]" />
          </div>
          <div className="flex-1">
            <div className="font-sora text-sm text-white">Morgan</div>
            <div className="font-jakarta text-xs text-[#988D9F]">410 CP</div>
          </div>
          <div className="glass-surface px-2 py-1 rounded bg-black/20">
            <span className="font-jakarta text-xs text-[#988D9F]">45% W</span>
          </div>
        </div>
      </div>

      {/* Bottom Nav */}
      <div className="absolute bottom-0 left-0 right-0 h-20 glass-surface border-x-0 border-b-0 bg-[#0A0512]/80 flex items-center justify-around px-2 pb-2 z-50">
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Gamepad2 className="w-6 h-6" />
          <span className="text-[10px] font-jakarta">Chaos</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#92DBFF] relative">
          <div className="absolute -top-3 left-1/2 -translate-x-1/2 w-10 h-10 bg-[#00C4FD]/20 blur-xl rounded-full pointer-events-none" />
          <ShieldAlert className="w-6 h-6 neon-shadow-cyan drop-shadow-[0_0_8px_rgba(0,196,253,0.8)]" />
          <span className="text-[10px] font-jakarta text-glow-cyan">Crew</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Trophy className="w-6 h-6" />
          <span className="text-[10px] font-jakarta">Vault</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Settings className="w-6 h-6" />
          <span className="text-[10px] font-jakarta">Settings</span>
        </button>
      </div>
    </div>
  );
}
