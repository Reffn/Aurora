import React from 'react';
import { Link } from 'react-router-dom';

export const Impressum: React.FC = () => {
  return (
    <div className="min-h-screen bg-[#0F1014] text-white">
      <main className="max-w-4xl mx-auto px-6 py-32">
        <h1 className="text-4xl md:text-5xl font-bold mb-12 text-transparent bg-clip-text bg-gradient-to-r from-[#FFAB91] to-[#FF8A65]">
          Impressum
        </h1>

        {/* Angaben gemäß § 5 TMG */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Angaben gemäß § 5 TMG</h2>
          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
            <p className="font-bold text-lg mb-3">3ofus</p>
            <p className="text-gray-300 leading-relaxed">
              Kirchstraße 3<br />
              01640 Coswig<br />
              Deutschland
            </p>
          </div>
        </section>

        {/* Kontakt */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Kontakt</h2>
          <p className="text-gray-300">
            <strong className="text-white">E-Mail:</strong>{' '}
            <a href="mailto:info@3ofus.app" className="text-[#FFAB91] hover:text-[#FFCCBC] transition-colors underline">
              info@3ofus.app
            </a>
          </p>
        </section>

        {/* Vertreten durch */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Vertreten durch</h2>
          <p className="text-gray-300">Nico Wojtera</p>
        </section>

        {/* Verantwortlich für den Inhalt */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Verantwortlich für den Inhalt</h2>
          <p className="text-gray-300 leading-relaxed">
            Nico Wojtera<br />
            Kirchstraße 3<br />
            01640 Coswig
          </p>
        </section>

        {/* EU-Streitschlichtung */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">EU-Streitschlichtung</h2>
          <p className="text-gray-300 mb-4">
            Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit:{' '}
            <a
              href="https://ec.europa.eu/consumers/odr/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[#FFAB91] hover:text-[#FFCCBC] transition-colors underline"
            >
              https://ec.europa.eu/consumers/odr/
            </a>
          </p>
          <p className="text-gray-300">Unsere E-Mail-Adresse finden Sie oben im Impressum.</p>
        </section>

        {/* Verbraucherstreitbeilegung */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Verbraucherstreitbeilegung / Universalschlichtungsstelle</h2>
          <p className="text-gray-300">
            Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle
            teilzunehmen.
          </p>
        </section>

        {/* Haftungsausschluss */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-8 text-[#FFAB91]">Haftungsausschluss</h2>

          <h3 className="text-xl font-semibold mb-4 text-white">Haftung für Inhalte</h3>
          <div className="space-y-4 mb-8">
            <p className="text-gray-300 leading-relaxed">
              Die Inhalte unserer App und Website wurden mit größter Sorgfalt erstellt. Für die Richtigkeit,
              Vollständigkeit und Aktualität der Inhalte können wir jedoch keine Gewähr übernehmen.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte in dieser App nach den allgemeinen
              Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet,
              übermittelte oder gespeicherte fremde Informationen zu überwachen oder nach Umständen zu forschen, die auf
              eine rechtswidrige Tätigkeit hinweisen.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Verpflichtungen zur Entfernung oder Sperrung der Nutzung von Informationen nach den allgemeinen Gesetzen
              bleiben hiervon unberührt. Eine diesbezügliche Haftung ist jedoch erst ab dem Zeitpunkt der Kenntnis einer
              konkreten Rechtsverletzung möglich. Bei Bekanntwerden von entsprechenden Rechtsverletzungen werden wir diese
              Inhalte umgehend entfernen.
            </p>
          </div>

          <h3 className="text-xl font-semibold mb-4 text-white">Haftung für Links</h3>
          <div className="space-y-4 mb-8">
            <p className="text-gray-300 leading-relaxed">
              Die App enthält Links zu externen Websites (z.B. Notfall-Hotlines, OpenStreetMap). Auf den Inhalt dieser
              externen Seiten haben wir keinen Einfluss. Deshalb können wir für diese fremden Inhalte auch keine Gewähr
              übernehmen.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Für die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten
              verantwortlich. Die verlinkten Seiten wurden zum Zeitpunkt der Verlinkung auf mögliche Rechtsverstöße
              überprüft. Rechtswidrige Inhalte waren zum Zeitpunkt der Verlinkung nicht erkennbar.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Eine permanente inhaltliche Kontrolle der verlinkten Seiten ist jedoch ohne konkrete Anhaltspunkte einer
              Rechtsverletzung nicht zumutbar. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Links umgehend
              entfernen.
            </p>
          </div>

          <h3 className="text-xl font-semibold mb-4 text-white">Urheberrecht</h3>
          <div className="space-y-4">
            <p className="text-gray-300 leading-relaxed">
              Die durch die Betreiber der App erstellten Inhalte und Werke in dieser App und auf dieser Website unterliegen
              dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung
              außerhalb der Grenzen des Urheberrechtes bedürfen der schriftlichen Zustimmung des jeweiligen Autors bzw.
              Erstellers.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Downloads und Kopien dieser App sind nur für den privaten, nicht kommerziellen Gebrauch gestattet. Soweit die
              Inhalte in dieser App nicht vom Betreiber erstellt wurden, werden die Urheberrechte Dritter beachtet.
              Insbesondere werden Inhalte Dritter als solche gekennzeichnet.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Sollten Sie trotzdem auf eine Urheberrechtsverletzung aufmerksam werden, bitten wir um einen entsprechenden
              Hinweis. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Inhalte umgehend entfernen.
            </p>
          </div>
        </section>

        {/* Hinweis zur App */}
        <section className="mb-12 bg-gradient-to-br from-[#1E1E24] to-[#121215] rounded-3xl p-8 border border-[#FFAB91]/20">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Hinweis zur App</h2>
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-white">Über Aurora</h3>
            <p className="text-gray-300 leading-relaxed">
              Aurora ist eine kostenlose App zur Unterstützung von Menschen mit Dissoziativer Identitätsstörung (DIS). Die
              App legt höchsten Wert auf <strong className="text-white">Datenschutz und Privatsphäre</strong> - alle Daten
              bleiben ausschließlich auf dem Gerät der Nutzer.
            </p>
            <p className="text-gray-300 leading-relaxed">
              Es handelt sich um ein <strong className="text-white">Open Beta</strong> Projekt, das aktiv weiterentwickelt
              wird. Feedback und Verbesserungsvorschläge sind jederzeit willkommen unter:{' '}
              <a href="mailto:info@3ofus.app" className="text-[#FFAB91] hover:text-[#FFCCBC] transition-colors underline">
                info@3ofus.app
              </a>
            </p>
          </div>
        </section>

        {/* Haftungsausschluss für medizinische Inhalte */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-red-900/20">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">Haftungsausschluss für medizinische Inhalte</h2>
          <p className="text-gray-300 leading-relaxed mb-4">
            <strong className="text-white">Wichtiger Hinweis:</strong> Aurora ist eine Unterstützungs-App und{' '}
            <strong className="text-white">kein Ersatz für professionelle medizinische Behandlung</strong>.
          </p>
          <ul className="list-disc list-inside space-y-3 text-gray-300 mb-4">
            <li>Die App bietet Informationen und Organisationshilfen, stellt aber keine medizinische Beratung oder Therapie dar</li>
            <li>Bei akuten Krisen wenden Sie sich bitte an die Notfall-Hotlines (z.B. Telefonseelsorge: 0800 111 0 111)</li>
            <li>Die App ersetzt keine therapeutische Begleitung durch qualifizierte Fachkräfte</li>
            <li>Für medizinische Diagnosen und Behandlungen konsultieren Sie bitte einen Arzt oder Psychotherapeuten</li>
          </ul>
          <p className="text-gray-300 leading-relaxed">
            Wir übernehmen keine Haftung für Entscheidungen, die auf Basis der in der App bereitgestellten Informationen
            getroffen werden.
          </p>
        </section>

        {/* Last Updated */}
        <div className="text-center text-gray-500 text-sm mt-16">
          <p><strong>Stand:</strong> Januar 2025</p>
          <p className="mt-2">Version 3.0.6</p>
        </div>

        {/* Back to Home */}
        <div className="text-center mt-8">
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
