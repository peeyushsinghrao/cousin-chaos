import React from "react";
import { ArrowLeft, ChevronRight } from "lucide-react";

export function GameModeScreen() {
  return (
    <div className="relative w-full max-w-md mx-auto min-h-[100dvh] bg-[#0A0512] text-[#EADEF3] overflow-hidden flex flex-col font-jakarta">
      <style dangerouslySetInnerHTML={{__html: `
        @import url('https://fonts.googleapis.com/css2?family=Anybody:wght@900&family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Sora:wght@600&display=swap');
        .font-anybody { font-family: 'Anybody', sans-serif; }
        .font-sora { font-family: 'Sora', sans-serif; }
        .font-jakarta { font-family: 'Plus Jakarta Sans', sans-serif; }
        
        .glow-cyan { text-shadow: 0 0 10px rgba(146, 219, 255, 0.5), 0 0 20px rgba(146, 219, 255, 0.3); }
        .glow-border-cyan { box-shadow: 0 0 15px rgba(0, 196, 253, 0.4), inset 0 0 10px rgba(0, 196, 253, 0.2); border-color: rgba(0, 196, 253, 0.8) !important; }
        .glow-btn-purple { box-shadow: 0 0 20px rgba(183, 109, 255, 0.4); }
        .glow-btn-pink { box-shadow: 0 0 20px rgba(255, 81, 103, 0.4); }
        .glow-purple { text-shadow: 0 0 15px rgba(221, 183, 255, 0.6); }
        
        .shimmer {
          position: relative;
          overflow: hidden;
        }
        .shimmer::after {
          content: '';
          position: absolute;
          top: 0; left: -150%;
          width: 50%; height: 100%;
          background: linear-gradient(to right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.1) 50%, rgba(255,255,255,0) 100%);
          transform: skewX(-25deg);
          animation: shimmer 4s infinite;
        }
        @keyframes shimmer {
          0% { left: -150%; }
          100% { left: 250%; }
        }
        
        .float-arrow {
          animation: bounce-right 1.5s infinite;
        }
        @keyframes bounce-right {
          0%, 100% { transform: translateX(0); }
          50% { transform: translateX(5px); }
        }
        
        .bg-dots {
          background-image: radial-gradient(rgba(255,255,255,0.1) 1px, transparent 1px);
          background-size: 16px 16px;
        }
        
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .hide-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}} />

      {/* Radial gradient top background */}
      <div className="absolute top-0 left-0 right-0 h-[400px] bg-[radial-gradient(ellipse_at_top,_rgba(0,196,253,0.15)_0%,_transparent_70%)] pointer-events-none" />

      {/* Header */}
      <header className="relative z-10 px-6 pt-12 pb-4 flex flex-col items-center">
        <button className="absolute left-6 top-12 p-2.5 rounded-full bg-[rgba(255,255,255,0.05)] border border-[rgba(255,255,255,0.15)] text-white hover:bg-[rgba(255,255,255,0.1)] transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="font-anybody text-3xl tracking-widest text-center mt-2 glow-cyan text-[#92DBFF] uppercase">
          Truth or Dare
        </h1>
        <p className="text-[#988D9F] text-sm font-medium mt-1">Pack: Spicy Edition</p>
      </header>

      {/* Pack Selector */}
      <div className="relative z-10 w-full overflow-x-auto hide-scrollbar px-6 py-3">
        <div className="flex space-x-3 w-max">
          <button className="px-5 py-2.5 rounded-full border bg-[rgba(0,196,253,0.1)] glow-border-cyan text-[#EADEF3] font-sora text-sm whitespace-nowrap flex items-center shadow-lg transition-transform active:scale-95">
            Spicy 🌶️
          </button>
          <button className="px-5 py-2.5 rounded-full border border-[rgba(255,255,255,0.15)] bg-[rgba(255,255,255,0.05)] text-[#988D9F] font-sora text-sm whitespace-nowrap hover:bg-[rgba(255,255,255,0.1)] transition-colors">
            Classic
          </button>
          <button className="px-5 py-2.5 rounded-full border border-[rgba(255,255,255,0.15)] bg-[rgba(255,255,255,0.05)] text-[#988D9F] font-sora text-sm whitespace-nowrap hover:bg-[rgba(255,255,255,0.1)] transition-colors">
            Custom
          </button>
          <button className="px-5 py-2.5 rounded-full border border-[rgba(255,255,255,0.15)] bg-transparent text-[#988D9F] font-sora text-sm whitespace-nowrap border-dashed hover:bg-[rgba(255,255,255,0.05)] transition-colors">
            + Add
          </button>
        </div>
      </div>

      {/* Card Area */}
      <div className="relative z-10 flex-1 px-6 py-6 flex flex-col justify-center min-h-[45vh]">
        <div className="shimmer relative w-full h-full max-h-[420px] bg-[rgba(255,255,255,0.05)] border border-[rgba(255,255,255,0.15)] rounded-3xl p-7 flex flex-col shadow-2xl backdrop-blur-md overflow-hidden">
          <div className="absolute inset-0 bg-dots opacity-40 pointer-events-none" />
          
          {/* Card Header */}
          <div className="relative flex justify-between items-center mb-auto">
            <h2 className="font-anybody text-3xl tracking-wider text-[#DDB7FF] glow-purple">TRUTH</h2>
            <div className="px-3 py-1.5 bg-[rgba(221,183,255,0.1)] border border-[rgba(221,183,255,0.4)] rounded-full text-xs font-bold text-[#DDB7FF] tracking-wide">
              EMBARRASSING
            </div>
          </div>
          
          {/* Card Body */}
          <div className="relative text-center my-auto pt-4">
            <p className="font-sora text-3xl leading-snug text-white drop-shadow-md">
              "What's the most embarrassing thing you've done at a party?"
            </p>
          </div>
          
          {/* Card Footer */}
          <div className="relative mt-auto pt-6 border-t border-[rgba(255,255,255,0.1)] flex justify-between items-center text-sm font-medium text-[#988D9F]">
            <span className="flex items-center gap-1">Intensity: <span className="text-[#FF5167]">🔥🔥</span></span>
            <span className="bg-[rgba(255,255,255,0.05)] px-2 py-1 rounded">Spicy Edition</span>
          </div>
        </div>
      </div>

      {/* Player Row */}
      <div className="relative z-10 px-6 py-4 flex flex-col items-center">
        <div className="flex items-center text-[#FFD700] font-sora text-sm font-bold tracking-wide mb-3">
          <span>IT'S YOUR TURN</span>
          <ChevronRight className="w-4 h-4 ml-1 float-arrow text-[#FFD700]" />
        </div>
        
        <div className="flex items-center justify-center space-x-[-12px]">
          {/* Active Player */}
          <div className="w-14 h-14 rounded-full bg-[#1A1A2E] border-[3px] border-[#FFD700] flex items-center justify-center z-50 shadow-[0_0_15px_rgba(255,215,0,0.4)] relative">
            <span className="font-anybody text-lg text-white">YOU</span>
            {/* Pulsing effect behind active player */}
            <div className="absolute inset-0 rounded-full border border-[#FFD700] animate-ping opacity-20"></div>
          </div>
          
          {/* Other players */}
          <div className="w-12 h-12 rounded-full bg-[#1A1A2E] border-2 border-[#DDB7FF] flex items-center justify-center z-40 opacity-80 transition-transform hover:-translate-y-1">
            <span className="font-anybody text-sm text-[#DDB7FF]">AJ</span>
          </div>
          <div className="w-12 h-12 rounded-full bg-[#1A1A2E] border-2 border-[#92DBFF] flex items-center justify-center z-30 opacity-70 transition-transform hover:-translate-y-1">
            <span className="font-anybody text-sm text-[#92DBFF]">MK</span>
          </div>
          <div className="w-12 h-12 rounded-full bg-[#1A1A2E] border-2 border-[#FF5167] flex items-center justify-center z-20 opacity-60 transition-transform hover:-translate-y-1">
            <span className="font-anybody text-sm text-[#FF5167]">DJ</span>
          </div>
          <div className="w-12 h-12 rounded-full bg-[#1A1A2E] border-2 border-[#00C4FD] flex items-center justify-center z-10 opacity-50 transition-transform hover:-translate-y-1">
            <span className="font-anybody text-sm text-[#00C4FD]">SJ</span>
          </div>
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="relative z-10 px-6 pt-4 pb-12 mt-auto">
        <div className="flex space-x-4 mb-6">
          <button className="flex-1 h-16 rounded-full bg-gradient-to-r from-[#B76DFF] to-[#DDB7FF] text-[#0A0512] font-anybody text-xl tracking-wider glow-btn-purple transition-transform hover:scale-[1.02] active:scale-95 shadow-xl">
            TRUTH
          </button>
          <button className="flex-1 h-16 rounded-full bg-gradient-to-r from-[#FF5167] to-[#FF8A98] text-[#0A0512] font-anybody text-xl tracking-wider glow-btn-pink transition-transform hover:scale-[1.02] active:scale-95 shadow-xl">
            DARE
          </button>
        </div>
        
        <div className="flex justify-center">
          <button className="text-[#988D9F] text-sm font-jakarta font-medium hover:text-white transition-colors flex items-center gap-1 group">
            Skip challenge 
            <span className="transition-transform group-hover:translate-x-1">→</span>
          </button>
        </div>
      </div>
    </div>
  );
}
