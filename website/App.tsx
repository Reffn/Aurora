import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Header } from './components/Header';
import { AuroraBackground } from './components/AuroraBackground';
import { Home } from './pages/Home';
import { Impressum } from './pages/Impressum';
import { Datenschutz } from './pages/Datenschutz';
import { Kontakt } from './pages/Kontakt';

// Hier stand ein `AnalyticsTracker`, der bei jedem Routenwechsel ein
// `page_view` an Google Analytics schickte. Er ist am 12.08.2026 entfernt
// worden, zusammen mit `firebase/analytics` und der ganzen Firebase-Einbindung
// dieser Seite. Aurora misst nicht — und diese Seite ist die, auf der das steht.
const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="min-h-screen w-full relative text-white font-sans selection:bg-[#FFAB91] selection:text-black">
        {/* Dynamic Background */}
        <AuroraBackground colors={['#2d1b1e', '#1a1a2e', '#0F1014', '#1f2937', '#000000']} />

        <Header />

        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/impressum" element={<Impressum />} />
          <Route path="/datenschutz" element={<Datenschutz />} />
          <Route path="/kontakt" element={<Kontakt />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
};

export default App;
