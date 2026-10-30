import React, { useEffect, useState } from 'react';

interface AuroraBackgroundProps {
  colors: string[];
}

const DEFAULT_COLORS = ['#2d1b1e', '#1a1a2e', '#1f2937', '#2d1b1e', '#000000'];

export const AuroraBackground: React.FC<AuroraBackgroundProps> = ({ colors }) => {
  const [activeColors, setActiveColors] = useState<string[]>(DEFAULT_COLORS);

  useEffect(() => {
    if (colors && colors.length >= 3) {
      setActiveColors(colors);
    }
  }, [colors]);

  return (
    <div className="fixed inset-0 -z-10 overflow-hidden bg-[#0F1014] transition-colors duration-[2000ms]">
      {/* Main Gradient Blobs - darkened for the specific app aesthetic */}
      <div 
        className="absolute top-[-10%] left-[-10%] w-[80vw] h-[80vw] rounded-full blur-[120px] opacity-20 animate-float transition-colors duration-[3000ms]"
        style={{ backgroundColor: activeColors[0] }}
      />
      <div 
        className="absolute top-[20%] right-[-10%] w-[60vw] h-[60vw] rounded-full blur-[150px] opacity-15 animate-pulse-slow transition-colors duration-[3000ms]"
        style={{ backgroundColor: activeColors[1], animationDelay: '1s' }}
      />
      <div 
        className="absolute bottom-[-20%] left-[10%] w-[90vw] h-[90vw] rounded-full blur-[150px] opacity-10 animate-float transition-colors duration-[3000ms]"
        style={{ backgroundColor: activeColors[2], animationDelay: '2s' }}
      />
      
      {/* Vignette to ensure the center stays readable */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#0F1014]/50 via-transparent to-[#0F1014]/90 pointer-events-none" />
    </div>
  );
};