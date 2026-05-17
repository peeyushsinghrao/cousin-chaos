import React, { useState } from "react";
import {
  Volume2,
  Vibrate,
  Layers,
  History,
  AlertTriangle,
  Trash2,
  ChevronRight,
  Gamepad2,
  Users,
  Briefcase,
  Settings,
} from "lucide-react";
import { Switch } from "../../ui/switch";
import { Button } from "../../ui/button";

export function SettingsScreen() {
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [hapticEnabled, setHapticEnabled] = useState(true);

  return (
    <div
      className="min-h-screen w-full relative overflow-hidden flex flex-col font-sans pb-24"
      style={{
        backgroundColor: "#0A0512",
        color: "#EADEF3",
        fontFamily: "'Plus Jakarta Sans', sans-serif",
      }}
    >
      {/* Background Gradient */}
      <div
        className="absolute top-0 left-0 w-full h-[400px] pointer-events-none opacity-40 mix-blend-screen"
        style={{
          background: "radial-gradient(circle at 50% -20%, #B76DFF 0%, transparent 70%)",
        }}
      />

      {/* Header */}
      <header className="px-6 pt-14 pb-6 flex items-baseline gap-3 relative z-10">
        <h1
          className="text-4xl tracking-tight"
          style={{ fontFamily: "'Anybody', sans-serif", fontWeight: 900 }}
        >
          SETTINGS
        </h1>
        <span
          className="text-xs px-2 py-0.5 rounded-full"
          style={{
            backgroundColor: "rgba(255,255,255,0.1)",
            color: "#988D9F",
            fontFamily: "'Sora', sans-serif",
            fontWeight: 600,
          }}
        >
          v1.0.0
        </span>
      </header>

      <main className="flex-1 px-6 flex flex-col gap-8 relative z-10 overflow-y-auto">
        {/* Profile Card */}
        <section>
          <div
            className="p-5 rounded-2xl flex flex-col gap-5 border"
            style={{
              backgroundColor: "rgba(255,255,255,0.05)",
              borderColor: "#DDB7FF",
              boxShadow: "0 0 20px rgba(183,109,255,0.1)",
              backdropFilter: "blur(10px)",
            }}
          >
            <div className="flex items-center gap-4">
              <div
                className="w-16 h-16 rounded-full flex items-center justify-center text-2xl font-black shrink-0"
                style={{
                  background: "linear-gradient(135deg, #00C4FD 0%, #B76DFF 100%)",
                  fontFamily: "'Anybody', sans-serif",
                  color: "#0A0512",
                }}
              >
                CC
              </div>
              <div className="flex-1 min-w-0">
                <h2
                  className="text-lg truncate"
                  style={{ fontFamily: "'Sora', sans-serif", fontWeight: 600 }}
                >
                  Cousin Chaos Player
                </h2>
                <p className="text-sm" style={{ color: "#988D9F" }}>
                  Level 14 Instigator
                </p>
              </div>
            </div>

            <div className="flex items-center justify-between pt-4 border-t" style={{ borderColor: "rgba(255,255,255,0.1)" }}>
              <div className="text-center">
                <div className="text-lg font-bold" style={{ color: "#00C4FD" }}>6</div>
                <div className="text-xs" style={{ color: "#988D9F" }}>Games</div>
              </div>
              <div className="text-center">
                <div className="text-lg font-bold" style={{ color: "#DDB7FF" }}>12</div>
                <div className="text-xs" style={{ color: "#988D9F" }}>Players</div>
              </div>
              <div className="text-center">
                <div className="text-lg font-bold" style={{ color: "#FFD700" }}>1,240</div>
                <div className="text-xs" style={{ color: "#988D9F" }}>CP</div>
              </div>
            </div>
          </div>
        </section>

        {/* Gameplay Feel */}
        <section className="flex flex-col gap-3">
          <h3
            className="text-sm tracking-widest uppercase pl-1"
            style={{ color: "#988D9F", fontFamily: "'Sora', sans-serif", fontWeight: 600 }}
          >
            Gameplay Feel
          </h3>
          
          <div
            className="rounded-2xl border overflow-hidden"
            style={{
              backgroundColor: "rgba(255,255,255,0.03)",
              borderColor: "rgba(255,255,255,0.1)",
              backdropFilter: "blur(10px)",
            }}
          >
            {/* Sound Effects */}
            <div className="p-4 flex items-center gap-4 border-b border-white/5">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: "rgba(0,196,253,0.1)", color: "#00C4FD" }}
              >
                <Volume2 className="w-5 h-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-semibold" style={{ fontFamily: "'Sora', sans-serif" }}>
                  Sound Effects
                </div>
                <div className="text-xs line-clamp-1" style={{ color: "#988D9F" }}>
                  Immersive audio & stings
                </div>
              </div>
              <Switch
                checked={soundEnabled}
                onCheckedChange={setSoundEnabled}
                className={soundEnabled ? "bg-[#00C4FD]" : "bg-white/20"}
                style={soundEnabled ? { boxShadow: "0 0 10px #00C4FD" } : {}}
              />
            </div>

            {/* Haptic Feedback */}
            <div className="p-4 flex items-center gap-4">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: "rgba(183,109,255,0.1)", color: "#DDB7FF" }}
              >
                <Vibrate className="w-5 h-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-semibold" style={{ fontFamily: "'Sora', sans-serif" }}>
                  Haptic Feedback
                </div>
                <div className="text-xs line-clamp-1" style={{ color: "#988D9F" }}>
                  Device vibrations
                </div>
              </div>
              <Switch
                checked={hapticEnabled}
                onCheckedChange={setHapticEnabled}
                className={hapticEnabled ? "bg-[#DDB7FF]" : "bg-white/20"}
                style={hapticEnabled ? { boxShadow: "0 0 10px #DDB7FF" } : {}}
              />
            </div>
          </div>
        </section>

        {/* Content Section */}
        <section className="flex flex-col gap-3">
          <h3
            className="text-sm tracking-widest uppercase pl-1"
            style={{ color: "#988D9F", fontFamily: "'Sora', sans-serif", fontWeight: 600 }}
          >
            Content
          </h3>
          
          <div
            className="rounded-2xl border overflow-hidden"
            style={{
              backgroundColor: "rgba(255,255,255,0.03)",
              borderColor: "rgba(255,255,255,0.1)",
              backdropFilter: "blur(10px)",
            }}
          >
            {/* Custom Packs */}
            <button className="w-full p-4 flex items-center gap-4 border-b border-white/5 text-left hover:bg-white/5 active:bg-white/10 transition-colors">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: "rgba(255,215,0,0.1)", color: "#FFD700" }}
              >
                <Layers className="w-5 h-5" />
              </div>
              <div className="flex-1 font-semibold" style={{ fontFamily: "'Sora', sans-serif" }}>
                Custom Packs
              </div>
              <ChevronRight className="w-5 h-5 opacity-50" />
            </button>

            {/* Game History */}
            <button className="w-full p-4 flex items-center gap-4 text-left hover:bg-white/5 active:bg-white/10 transition-colors">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ backgroundColor: "rgba(255,255,255,0.1)", color: "#EADEF3" }}
              >
                <History className="w-5 h-5" />
              </div>
              <div className="flex-1 font-semibold" style={{ fontFamily: "'Sora', sans-serif" }}>
                Game History
              </div>
              <ChevronRight className="w-5 h-5 opacity-50" />
            </button>
          </div>
        </section>

        {/* Danger Zone */}
        <section className="flex flex-col gap-3">
          <div className="flex items-center gap-2 pl-1">
            <AlertTriangle className="w-4 h-4" style={{ color: "#FF5167" }} />
            <h3
              className="text-sm tracking-widest uppercase"
              style={{ color: "#FF5167", fontFamily: "'Sora', sans-serif", fontWeight: 600 }}
            >
              Danger Zone
            </h3>
          </div>
          
          <div
            className="rounded-2xl border p-4 flex items-center gap-4"
            style={{
              backgroundColor: "rgba(255,81,103,0.05)",
              borderColor: "rgba(255,81,103,0.3)",
            }}
          >
            <div className="flex-1 min-w-0">
              <div className="font-semibold text-[#FF5167]" style={{ fontFamily: "'Sora', sans-serif" }}>
                Clear All Data
              </div>
              <div className="text-xs mt-1" style={{ color: "#988D9F" }}>
                This will remove all players, scores, and history.
              </div>
            </div>
            <button
              className="px-4 py-2 rounded-lg font-bold text-xs shrink-0 flex items-center gap-2 active:scale-95 transition-transform"
              style={{
                backgroundColor: "rgba(255,81,103,0.15)",
                color: "#FF5167",
                border: "1px solid rgba(255,81,103,0.5)",
              }}
            >
              <Trash2 className="w-4 h-4" />
              DELETE
            </button>
          </div>
        </section>

        {/* Footer */}
        <div className="text-center py-6">
          <p className="text-xs" style={{ color: "#988D9F" }}>
            Made with <span className="opacity-100">🔥</span> for chaotic families
          </p>
        </div>
      </main>

      {/* Bottom Nav */}
      <nav
        className="absolute bottom-0 left-0 w-full h-20 border-t flex items-center justify-around px-2 z-20"
        style={{
          backgroundColor: "rgba(10,5,18,0.9)",
          backdropFilter: "blur(20px)",
          borderColor: "rgba(255,255,255,0.1)",
        }}
      >
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Gamepad2 className="w-6 h-6" />
          <span className="text-[10px] font-bold">Chaos</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Users className="w-6 h-6" />
          <span className="text-[10px] font-bold">Crew</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#988D9F]">
          <Briefcase className="w-6 h-6" />
          <span className="text-[10px] font-bold">Vault</span>
        </button>
        <button className="flex flex-col items-center gap-1 p-2 text-[#DDB7FF] relative">
          <div className="absolute inset-0 bg-[#DDB7FF]/20 blur-xl rounded-full mix-blend-screen" />
          <Settings className="w-6 h-6 drop-shadow-[0_0_8px_rgba(221,183,255,0.8)]" />
          <span className="text-[10px] font-bold drop-shadow-[0_0_8px_rgba(221,183,255,0.8)]">
            Settings
          </span>
        </button>
      </nav>

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Anybody:wght@900&family=Plus+Jakarta+Sans:wght@400;500&family=Sora:wght@600;700&display=swap');
      `}</style>
    </div>
  );
}

export default SettingsScreen;
