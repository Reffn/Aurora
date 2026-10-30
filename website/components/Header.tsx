import React from 'react';
import { Link } from 'react-router-dom';
import { Menu } from 'lucide-react';

export const Header: React.FC = () => {
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-[#0F1014]/80 backdrop-blur-md border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 h-20 flex items-center justify-between">
        {/* Logo Section */}
        <Link to="/" className="flex items-center gap-3">
          <img
            src="/assets/logo-rainbow.png"
            alt="Aurora Logo"
            className="w-10 h-10 md:w-12 md:h-12 rounded-xl shadow-lg"
          />
          <span className="text-xl font-bold tracking-tight text-white">Aurora</span>
        </Link>

        {/* Desktop Navigation */}
        <div className="hidden md:flex items-center gap-8 text-sm font-medium text-gray-300">
          <button
            onClick={() => scrollToSection('features')}
            className="hover:text-[#FFAB91] transition-colors cursor-pointer"
          >
            Features
          </button>
          <button
            onClick={() => scrollToSection('privacy')}
            className="hover:text-[#FFAB91] transition-colors cursor-pointer"
          >
            Datenschutz
          </button>
          <button
            onClick={() => scrollToSection('download')}
            className="hover:text-[#FFAB91] transition-colors cursor-pointer"
          >
            Download
          </button>
        </div>

        {/* CTA Button */}
        <div className="hidden md:block">
          <button
            onClick={() => scrollToSection('download')}
            className="px-6 py-2.5 rounded-full bg-[#1E1E24] border border-white/10 hover:bg-[#FFAB91] hover:text-[#0F1014] hover:border-[#FFAB91] transition-all duration-300 font-semibold text-sm"
          >
            Beta Testen
          </button>
        </div>

        {/* Mobile Menu Icon */}
        <button className="md:hidden p-2 text-gray-300 hover:text-white">
          <Menu size={24} />
        </button>
      </div>
    </nav>
  );
};
