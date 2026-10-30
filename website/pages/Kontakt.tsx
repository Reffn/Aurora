import React, { useState, FormEvent } from 'react';
import { Link } from 'react-router-dom';
import { Send, Mail, User, MessageCircle } from 'lucide-react';

export const Kontakt: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });

  const subjects = [
    { value: 'support', label: 'Support / Hilfe' },
    { value: 'bug', label: 'Bug Report / Fehler melden' },
    { value: 'feature', label: 'Feature Request / Verbesserungsvorschlag' },
    { value: 'feedback', label: 'Allgemeines Feedback' },
    { value: 'other', label: 'Sonstiges' }
  ];

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    // Construct mailto link with form data
    const subjectText = formData.subject ? subjects.find(s => s.value === formData.subject)?.label || formData.subject : 'Kontaktanfrage';
    const bodyText = `Nachricht von: ${formData.name}\nE-Mail: ${formData.email}\n\n${formData.message}`;

    const mailtoLink = `mailto:info@3ofus.app?subject=${encodeURIComponent(subjectText)}&body=${encodeURIComponent(bodyText)}`;

    window.location.href = mailtoLink;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="min-h-screen bg-[#0F1014] text-white">
      <main className="max-w-3xl mx-auto px-6 py-32">
        <h1 className="text-4xl md:text-5xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-[#FFAB91] to-[#FF8A65]">
          Kontakt
        </h1>

        <p className="text-xl text-gray-400 mb-12 leading-relaxed">
          Hast du Fragen, Feedback oder Verbesserungsvorschläge? Wir freuen uns auf deine Nachricht!
        </p>

        {/* Info Banner */}
        <div className="mb-12 bg-[#1E1E24] rounded-3xl p-6 border border-[#FFAB91]/20">
          <div className="flex items-start gap-4">
            <Mail className="text-[#FFAB91] flex-shrink-0 mt-1" size={24} />
            <div>
              <h3 className="font-semibold mb-2">Privacy-First Kontaktformular</h3>
              <p className="text-gray-400 text-sm leading-relaxed">
                Beim Absenden wird dein Standard-E-Mail-Programm geöffnet. So bleiben deine Daten bei dir –
                keine Drittanbieter-Services, kein Tracking. Ganz im Sinne der Aurora-Philosophie. 🔒
              </p>
            </div>
          </div>
        </div>

        {/* Contact Form */}
        <form onSubmit={handleSubmit} className="bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          {/* Name Field */}
          <div className="mb-6">
            <label htmlFor="name" className="block text-sm font-semibold mb-2 text-gray-300 flex items-center gap-2">
              <User size={16} className="text-[#FFAB91]" />
              Name (optional)
            </label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder="Dein Name oder Pseudonym"
              className="w-full px-4 py-3 rounded-2xl bg-[#121215] border border-white/10 text-white placeholder-gray-500 focus:outline-none focus:border-[#FFAB91] transition-colors"
            />
          </div>

          {/* Email Field */}
          <div className="mb-6">
            <label htmlFor="email" className="block text-sm font-semibold mb-2 text-gray-300 flex items-center gap-2">
              <Mail size={16} className="text-[#FFAB91]" />
              E-Mail (optional, für Rückantwort)
            </label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="deine@email.de"
              className="w-full px-4 py-3 rounded-2xl bg-[#121215] border border-white/10 text-white placeholder-gray-500 focus:outline-none focus:border-[#FFAB91] transition-colors"
            />
          </div>

          {/* Subject Field */}
          <div className="mb-6">
            <label htmlFor="subject" className="block text-sm font-semibold mb-2 text-gray-300">
              Betreff
            </label>
            <select
              id="subject"
              name="subject"
              value={formData.subject}
              onChange={handleChange}
              required
              className="w-full px-4 py-3 rounded-2xl bg-[#121215] border border-white/10 text-white focus:outline-none focus:border-[#FFAB91] transition-colors cursor-pointer"
            >
              <option value="" className="bg-[#121215]">Bitte wählen...</option>
              {subjects.map((subject) => (
                <option key={subject.value} value={subject.value} className="bg-[#121215]">
                  {subject.label}
                </option>
              ))}
            </select>
          </div>

          {/* Message Field */}
          <div className="mb-8">
            <label htmlFor="message" className="block text-sm font-semibold mb-2 text-gray-300 flex items-center gap-2">
              <MessageCircle size={16} className="text-[#FFAB91]" />
              Nachricht
            </label>
            <textarea
              id="message"
              name="message"
              value={formData.message}
              onChange={handleChange}
              required
              rows={8}
              placeholder="Deine Nachricht an uns..."
              className="w-full px-4 py-3 rounded-2xl bg-[#121215] border border-white/10 text-white placeholder-gray-500 focus:outline-none focus:border-[#FFAB91] transition-colors resize-none"
            />
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={!formData.subject || !formData.message}
            className="w-full px-8 py-4 rounded-2xl bg-[#FFAB91] text-[#0F1014] font-bold text-lg hover:bg-[#FFCCBC] hover:scale-105 transition-all duration-300 shadow-lg shadow-orange-900/20 flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
          >
            <Send size={20} />
            E-Mail-Programm öffnen
          </button>

          <p className="text-xs text-gray-500 mt-4 text-center">
            Beim Klicken öffnet sich dein Standard-E-Mail-Programm mit vorausgefülltem Text.
          </p>
        </form>

        {/* Alternative Contact Info */}
        <div className="mt-12 text-center">
          <p className="text-gray-400 mb-2">Oder schreibe uns direkt an:</p>
          <a
            href="mailto:info@3ofus.app"
            className="text-[#FFAB91] hover:text-[#FFCCBC] transition-colors text-lg font-semibold underline"
          >
            info@3ofus.app
          </a>
        </div>

        {/* Back to Home */}
        <div className="text-center mt-12">
          <Link
            to="/"
            className="inline-block px-6 py-3 rounded-full bg-[#1E1E24] border border-white/10 hover:bg-[#FFAB91] hover:text-[#0F1014] hover:border-[#FFAB91] transition-all duration-300 font-semibold text-sm"
          >
            Zurück zur Startseite
          </Link>
        </div>
      </main>
    </div>
  );
};
