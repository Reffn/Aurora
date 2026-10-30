import React, { useState, useEffect, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { Phone3D } from '../components/Phone3D';
import { Shield, Lock, Calendar, Users, MessageCircle, Clock, Heart, Stethoscope, Download, Sparkles } from 'lucide-react';

export const Home: React.FC = () => {
  // Screenshot Carousel State - ABSOLUTE PATHS
  const screenshots = [
    '/assets/screenshots/app-01-calendar.png',
    '/assets/screenshots/app-02-onboarding.png',
    '/assets/screenshots/app-03-chat.png',
    '/assets/screenshots/app-04-timeline.png',
    '/assets/screenshots/app-05-emergency.png',
  ];

  const [currentScreenshot, setCurrentScreenshot] = useState(0);
  const [isFlipping, setIsFlipping] = useState(false);

  // Auto-rotate screenshots every 4 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setIsFlipping(true);

      setTimeout(() => {
        setCurrentScreenshot((prev) => (prev + 1) % screenshots.length);

        setTimeout(() => {
          setIsFlipping(false);
        }, 600);
      }, 300);
    }, 4000);

    return () => clearInterval(interval);
  }, [screenshots.length]);

  const features = [
    {
      icon: <Calendar size={24} className="text-[#FFAB91]" />,
      title: "Gemeinsamer Kalender",
      desc: "Geteilte Terminplanung verhindert Konflikte. Jede Persönlichkeit sieht, was ansteht.",
      image: "/assets/screenshots/app-01-calendar.png"
    },
    {
      icon: <Users size={24} className="text-blue-400" />,
      title: "Multi-Profil System",
      desc: "Individuelle Profile mit eigenen Avataren und Farben. Du bist nicht allein.",
      image: "/assets/screenshots/app-02-onboarding.png"
    },
    {
      icon: <MessageCircle size={24} className="text-green-400" />,
      title: "Interner Chat",
      desc: "Sichere Kommunikation zwischen Persönlichkeiten. Text, Sprache & Doodles.",
      image: "/assets/screenshots/app-03-chat.png"
    },
    {
      icon: <Clock size={24} className="text-purple-400" />,
      title: "Zeitachse",
      desc: "Verfolge Profilwechsel und fülle Gedächtnislücken mit GPS-Tracking.",
      image: "/assets/screenshots/app-04-timeline.png"
    }
  ];

  return (
    <main className="pt-28 pb-20">
      {/* Hero Section */}
      <section className="max-w-6xl mx-auto px-6 mb-24">
        <div className="flex flex-col md:flex-row items-center gap-12">
          <div className="flex-1 space-y-8 z-10">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FFAB91]/10 border border-[#FFAB91]/20 text-[#FFAB91] text-xs font-bold uppercase tracking-wider">
              <Sparkles size={12} />
              <span>Open Beta 3.0</span>
            </div>

            <h1 className="text-5xl md:text-7xl font-extrabold leading-tight tracking-tight">
              Deine sichere <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FFAB91] to-[#FF8A65]">Begleitung</span> im Alltag.
            </h1>

            <p className="text-xl text-gray-400 leading-relaxed max-w-lg">
              Die App für Menschen mit Dissoziativer Identitätsstörung.
              Maximal privat. Komplett offline. Nur für dich.
            </p>

            <div className="flex flex-wrap items-center gap-4">
              <a
                href="https://play.google.com/store/apps/details?id=com.disapp.dis_app"
                target="_blank"
                rel="noopener noreferrer"
                className="px-8 py-4 rounded-2xl bg-[#FFAB91] text-[#0F1014] font-bold text-lg hover:bg-[#FFCCBC] hover:scale-105 transition-all duration-300 shadow-lg shadow-orange-900/20 flex items-center gap-2"
              >
                <Download size={20} />
                App laden
              </a>
              <a href="#features" className="px-8 py-4 rounded-2xl bg-[#1E1E24] text-white border border-white/10 font-medium text-lg hover:bg-[#2A2A35] transition-colors">
                Mehr erfahren
              </a>
            </div>
          </div>

          {/* Interactive 3D Phone Preview */}
          <div className="flex-1 relative w-full max-w-md md:max-w-full flex flex-col items-center">
            <Suspense fallback={
              <div className="w-64 h-[500px] flex items-center justify-center bg-[#1E1E24] rounded-3xl">
                <div className="text-white/50">3D wird geladen...</div>
              </div>
            }>
              <Phone3D screenshots={screenshots} />
            </Suspense>

            {/* Decorative Elements */}
            <div className="absolute -z-10 top-1/4 right-10 w-64 h-64 bg-[#FFAB91] rounded-full blur-[120px] opacity-20"></div>
            <div className="absolute -z-10 bottom-0 left-10 w-48 h-48 bg-blue-500 rounded-full blur-[100px] opacity-20"></div>
          </div>
        </div>
      </section>

      {/* Privacy Banner */}
      <section id="privacy" className="w-full bg-[#1E1E24]/50 border-y border-white/5 py-16 backdrop-blur-sm mb-24">
        <div className="max-w-4xl mx-auto px-6 text-center space-y-6">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-500/10 text-green-400 mb-4">
            <Shield size={32} />
          </div>
          <h2 className="text-3xl md:text-4xl font-bold">Privacy-First. Deine Daten gehören dir.</h2>
          <div className="grid md:grid-cols-3 gap-8 pt-8">
            <div className="flex flex-col items-center gap-3 p-4">
              <Lock className="text-gray-400" size={24} />
              <p className="text-gray-300 text-sm">Daten bleiben lokal auf deinem Gerät. Keine Cloud.</p>
            </div>
            <div className="flex flex-col items-center gap-3 p-4">
              <div className="w-6 h-6 rounded border-2 border-gray-400 flex items-center justify-center text-gray-400 text-xs font-bold">Ads</div>
              <p className="text-gray-300 text-sm">Kein Tracking, keine Analytics, absolut keine Werbung.</p>
            </div>
            <div className="flex flex-col items-center gap-3 p-4">
              <Download className="text-gray-400" size={24} />
              <p className="text-gray-300 text-sm">Vollständig offline nutzbar. Überall sicher.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section id="features" className="max-w-6xl mx-auto px-6 mb-32">
        <div className="mb-16">
          <h2 className="text-3xl font-bold mb-4">Was Aurora kann</h2>
          <p className="text-gray-400 max-w-xl">Funktionen, die speziell für Systeme entwickelt wurden. Jeder Bereich ist darauf ausgelegt, den Alltag zu erleichtern.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((feature, index) => (
            <div key={index} className="group bg-[#1E1E24] rounded-3xl p-5 border border-white/5 hover:border-[#FFAB91]/30 transition-all duration-300 hover:-translate-y-1">
              <div className="mb-6 rainbow-glow-container rounded-2xl overflow-hidden border border-white/5 bg-[#0F1014] aspect-[9/18] relative group-hover:shadow-lg transition-all">
                <img
                  src={feature.image}
                  alt={feature.title}
                  className="w-full h-full object-cover opacity-90 group-hover:opacity-100 transition-opacity duration-500"
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.opacity = '0.2';
                  }}
                />
              </div>
              <div className="flex items-center gap-3 mb-3">
                <div className="p-2 rounded-lg bg-[#121215] border border-white/5 group-hover:border-[#FFAB91]/20 transition-colors">
                  {feature.icon}
                </div>
                <h3 className="font-bold text-lg">{feature.title}</h3>
              </div>
              <p className="text-sm text-gray-400 leading-relaxed">
                {feature.desc}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Target Audience */}
      <section className="max-w-4xl mx-auto px-6 mb-32">
        <div className="bg-gradient-to-br from-[#1E1E24] to-[#121215] rounded-[2rem] p-8 md:p-12 border border-white/5 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-blue-500/10 rounded-full blur-[80px]"></div>

          <h2 className="text-2xl font-bold mb-8 relative z-10">Für wen ist Aurora?</h2>

          <div className="grid md:grid-cols-3 gap-8 relative z-10">
            <div className="space-y-3">
              <div className="w-12 h-12 rounded-2xl bg-[#0F1014] flex items-center justify-center text-[#FFAB91] border border-white/5">
                <Users size={24} />
              </div>
              <h3 className="font-bold">Menschen mit DIS</h3>
              <p className="text-sm text-gray-400">Die Hauptzielgruppe. Aurora ist für euch und euer System gemacht.</p>
            </div>
            <div className="space-y-3">
              <div className="w-12 h-12 rounded-2xl bg-[#0F1014] flex items-center justify-center text-blue-400 border border-white/5">
                <Stethoscope size={24} />
              </div>
              <h3 className="font-bold">Therapeuten</h3>
              <p className="text-sm text-gray-400">Ein wertvolles Tool zur Unterstützung der Therapiearbeit.</p>
            </div>
            <div className="space-y-3">
              <div className="w-12 h-12 rounded-2xl bg-[#0F1014] flex items-center justify-center text-green-400 border border-white/5">
                <Heart size={24} />
              </div>
              <h3 className="font-bold">Angehörige</h3>
              <p className="text-sm text-gray-400">Für bessere Koordination und Verständnis im Alltag.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Download CTA */}
      <section id="download" className="max-w-2xl mx-auto px-6 text-center mb-20">
        <h2 className="text-3xl font-bold mb-6">Bereit für Aurora?</h2>
        <p className="text-gray-400 mb-8">
          Wir sind in der Open Beta und entwickeln aktiv weiter. Dein Feedback hilft uns, Aurora besser zu machen.
        </p>

        <a
          href="https://play.google.com/store/apps/details?id=com.disapp.dis_app"
          target="_blank"
          rel="noopener noreferrer"
          className="w-full md:w-auto px-8 py-4 bg-[#FFAB91] hover:bg-[#FFCCBC] text-[#0F1014] font-bold rounded-2xl flex items-center justify-center gap-3 transition-all mx-auto shadow-lg shadow-orange-900/20 group"
        >
          <Download className="group-hover:animate-bounce" size={20} />
          <span>Kostenlos herunterladen</span>
          <span className="text-xs bg-black/10 px-2 py-1 rounded ml-2">v3.0.6</span>
        </a>

        <div className="mt-8 flex justify-center gap-6 text-sm text-gray-500">
          <Link to="/impressum" className="hover:text-gray-300">Impressum</Link>
          <Link to="/datenschutz" className="hover:text-gray-300">Datenschutz</Link>
          <Link to="/kontakt" className="hover:text-gray-300">Kontakt</Link>
        </div>
      </section>

      <footer className="text-center text-xs text-gray-600 py-8">
        <p>&copy; 2025 3ofus. Entwickelt mit Respekt für Vielfalt.</p>
      </footer>
    </main>
  );
};
