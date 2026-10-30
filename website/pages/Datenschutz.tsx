import React from 'react';
import { Link } from 'react-router-dom';
import { Shield, Lock, Download, CheckCircle } from 'lucide-react';

export const Datenschutz: React.FC = () => {
  return (
    <div className="min-h-screen bg-[#0F1014] text-white">
      <main className="max-w-4xl mx-auto px-6 py-32">
        <h1 className="text-4xl md:text-5xl font-bold mb-12 text-transparent bg-clip-text bg-gradient-to-r from-[#FFAB91] to-[#FF8A65]">
          Datenschutzerklärung
        </h1>

        {/* Datenschutz auf einen Blick */}
        <section className="mb-12 bg-gradient-to-br from-green-900/20 to-[#1E1E24] rounded-3xl p-8 border border-green-500/20">
          <div className="flex items-center gap-3 mb-6">
            <Shield className="text-green-400" size={32} />
            <h2 className="text-2xl font-bold">Datenschutz auf einen Blick</h2>
          </div>
          <p className="text-gray-300 leading-relaxed mb-4">
            <strong className="text-white">Aurora ist eine vollständig offline funktionierende App.</strong> Alle deine
            Daten bleiben ausschließlich auf deinem Gerät gespeichert und werden <strong className="text-white">niemals</strong>{' '}
            an Server oder Dritte übertragen.
          </p>
          <p className="text-gray-300 leading-relaxed">
            Diese Datenschutzerklärung klärt über die Art, den Umfang und Zweck der Verarbeitung von personenbezogenen
            Daten innerhalb der App auf.
          </p>
        </section>

        {/* 1. Welche Daten werden gespeichert? */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">1. Welche Daten werden gespeichert?</h2>
          <p className="text-gray-300 mb-4">
            Die App speichert folgende Daten <strong className="text-white">lokal auf deinem Gerät</strong>:
          </p>
          <ul className="list-disc list-inside space-y-2 text-gray-300 mb-4">
            <li>Profile und Einstellungen (Name, Avatar, Farbe, Berechtigungen)</li>
            <li>Chat-Nachrichten zwischen Profilen (Text, Sprache, Bilder, Videos, Zeichnungen)</li>
            <li>Kalender-Termine mit Titel, Beschreibung, Datum und Uhrzeit</li>
            <li>Medikamenten-Pläne und Einnahmeprotokolle</li>
            <li>Tagebuch-Einträge mit Text und Metadaten</li>
            <li>Kontakte mit Bewertungen und Notizen</li>
            <li>Finder-Einträge (Orte & Gegenstände mit optionalen GPS-Koordinaten)</li>
            <li>Timeline-Einträge (Profilwechsel-Historie mit optionalen GPS-Daten)</li>
            <li>Bilder, Videos und Sprachnachrichten (Attachments)</li>
          </ul>
          <p className="text-gray-300 leading-relaxed">
            <strong className="text-white">Wichtig:</strong> Alle diese Daten werden ausschließlich in der lokalen
            Datenbank (Hive) auf deinem Gerät gespeichert. Es findet{' '}
            <strong className="text-white">keine Synchronisation</strong> mit Cloud-Diensten oder Servern statt.
          </p>
        </section>

        {/* 2. Datenübertragung */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">2. Datenübertragung</h2>

          <h3 className="text-xl font-semibold mb-4 text-white">KEINE Datenübertragung an uns</h3>
          <p className="text-gray-300 mb-4">
            Aurora überträgt <strong className="text-white">KEINE</strong> Daten an Server, Cloud-Dienste oder Dritte.
            Die App funktioniert vollständig offline. Es gibt:
          </p>
          <ul className="space-y-2 text-gray-300 mb-8">
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Internetverbindung für App-Funktionen erforderlich</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Nutzerkonten oder Login</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Tracking-Tools oder Analytics (kein Firebase, Google Analytics, etc.)</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Werbung oder Werbe-SDKs</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Weitergabe an Dritte</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Telemetrie oder Crash-Reporting</span>
            </li>
          </ul>

          <h3 className="text-xl font-semibold mb-4 text-white">Externe Dienste (nur bei aktiver Nutzung)</h3>
          <p className="text-gray-300 mb-6">
            Aurora nutzt folgende externe Dienste <strong className="text-white">nur wenn du sie aktiv verwendest</strong>:
          </p>

          {/* OpenStreetMap */}
          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5 mb-4">
            <h4 className="text-lg font-semibold mb-3 text-[#FFAB91]">OpenStreetMap (Karten-Tiles)</h4>
            <ul className="space-y-2 text-gray-300 text-sm">
              <li><strong className="text-white">Zweck:</strong> Anzeige von Karten im Finder-Modul</li>
              <li><strong className="text-white">Anbieter:</strong> OpenStreetMap Foundation</li>
              <li><strong className="text-white">Datenübertragung:</strong> Deine IP-Adresse wird zum Laden der Kartenkacheln übertragen</li>
              <li><strong className="text-white">User-Agent:</strong> "com.aurora.dis_app"</li>
              <li>
                <strong className="text-white">Datenschutz:</strong>{' '}
                <a
                  href="https://osmfoundation.org/wiki/Privacy_Policy"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#FFAB91] hover:text-[#FFCCBC] underline"
                >
                  OSM Privacy Policy
                </a>
              </li>
              <li><strong className="text-white">Vermeidung:</strong> Nutze das Finder-Modul nicht, um keine Kartendaten zu laden</li>
            </ul>
          </div>

          {/* Nominatim */}
          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5 mb-4">
            <h4 className="text-lg font-semibold mb-3 text-[#FFAB91]">Nominatim (Geocoding)</h4>
            <ul className="space-y-2 text-gray-300 text-sm">
              <li><strong className="text-white">Zweck:</strong> Umwandlung von Adressen in GPS-Koordinaten (Finder-Modul)</li>
              <li><strong className="text-white">Anbieter:</strong> OpenStreetMap Foundation</li>
              <li><strong className="text-white">Datenübertragung:</strong> Suchanfragen und IP-Adresse</li>
              <li><strong className="text-white">Rate Limit:</strong> 1 Anfrage pro Sekunde</li>
              <li>
                <strong className="text-white">Datenschutz:</strong>{' '}
                <a
                  href="https://operations.osmfoundation.org/policies/nominatim/"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#FFAB91] hover:text-[#FFCCBC] underline"
                >
                  Nominatim Usage Policy
                </a>
              </li>
            </ul>
          </div>

          {/* URL Launcher */}
          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
            <h4 className="text-lg font-semibold mb-3 text-[#FFAB91]">URL Launcher (Externe Links)</h4>
            <ul className="space-y-2 text-gray-300 text-sm">
              <li><strong className="text-white">Zweck:</strong> Öffnen externer Links (z.B. Notfall-Hotlines, Websites)</li>
              <li><strong className="text-white">Funktionsweise:</strong> Links werden in deinem Standard-Browser geöffnet</li>
              <li><strong className="text-white">Datenübertragung:</strong> Abhängig vom aufgerufenen Dienst (außerhalb unserer Kontrolle)</li>
            </ul>
          </div>
        </section>

        {/* 3. Berechtigungen */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">3. Berechtigungen</h2>
          <p className="text-gray-300 mb-6">
            Die App benötigt folgende Geräte-Berechtigungen für ihre Funktionalität:
          </p>

          <div className="space-y-6">
            {/* Kamera */}
            <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
              <h3 className="text-lg font-semibold mb-3 text-white">Kamera</h3>
              <p className="text-gray-300 text-sm leading-relaxed">
                <strong className="text-white">Zweck:</strong> Aufnehmen von Fotos für Profilbilder und Chat-Nachrichten<br />
                <strong className="text-white">Datenspeicherung:</strong> Lokal auf deinem Gerät<br />
                <strong className="text-white">Übertragung:</strong> Keine
              </p>
            </div>

            {/* Mikrofon */}
            <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
              <h3 className="text-lg font-semibold mb-3 text-white">Mikrofon</h3>
              <p className="text-gray-300 text-sm leading-relaxed">
                <strong className="text-white">Zweck:</strong> Aufnehmen von Sprachnachrichten im Chat<br />
                <strong className="text-white">Datenspeicherung:</strong> Lokal auf deinem Gerät<br />
                <strong className="text-white">Übertragung:</strong> Keine
              </p>
            </div>

            {/* Speicher */}
            <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
              <h3 className="text-lg font-semibold mb-3 text-white">Speicher</h3>
              <p className="text-gray-300 text-sm leading-relaxed">
                <strong className="text-white">Zweck:</strong> Laden von Bildern/Videos aus der Galerie für Chat und Profile<br />
                <strong className="text-white">Datenspeicherung:</strong> Kopien werden lokal in der App gespeichert<br />
                <strong className="text-white">Übertragung:</strong> Keine
              </p>
            </div>

            {/* Standort */}
            <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
              <h3 className="text-lg font-semibold mb-3 text-white">Standort (optional)</h3>
              <p className="text-gray-300 text-sm leading-relaxed">
                <strong className="text-white">Zweck:</strong> Finder-Funktion (Orte speichern) und Timeline (GPS-Tracking bei Profilwechseln)<br />
                <strong className="text-white">Datenspeicherung:</strong> Lokal auf deinem Gerät<br />
                <strong className="text-white">Übertragung:</strong> Nur für Kartendarstellung (OpenStreetMap)<br />
                <strong className="text-white">Opt-Out:</strong> Berechtigung kann jederzeit widerrufen werden
              </p>
            </div>

            {/* Benachrichtigungen */}
            <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
              <h3 className="text-lg font-semibold mb-3 text-white">Benachrichtigungen</h3>
              <p className="text-gray-300 text-sm leading-relaxed">
                <strong className="text-white">Zweck:</strong> Lokale Erinnerungen für Medikamenteneinnahme<br />
                <strong className="text-white">Datenübertragung:</strong> Keine (rein lokal)<br />
                <strong className="text-white">Opt-Out:</strong> Berechtigung kann in den Systemeinstellungen deaktiviert werden
              </p>
            </div>
          </div>

          <p className="text-gray-300 mt-6 leading-relaxed">
            <strong className="text-white">Wichtig:</strong> Alle Berechtigungen dienen ausschließlich der App-Funktionalität.
            Es werden <strong className="text-white">keine Daten</strong> über diese Berechtigungen hinaus erhoben oder
            übertragen.
          </p>
        </section>

        {/* 4. Datensicherheit */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">4. Datensicherheit</h2>
          <p className="text-gray-300 mb-4">Deine Daten sind durch folgende Maßnahmen geschützt:</p>
          <ul className="list-disc list-inside space-y-2 text-gray-300 mb-6">
            <li><strong className="text-white">Lokale Speicherung:</strong> Alle Daten bleiben auf deinem Gerät</li>
            <li><strong className="text-white">Keine Cloud-Synchronisation:</strong> Daten verlassen niemals dein Gerät</li>
            <li><strong className="text-white">Passwortschutz:</strong> Profile können mit Passwort geschützt werden (inkl. Sicherheitsfragen)</li>
            <li><strong className="text-white">Gerätesicherheit:</strong> Nutze die Sicherheitsfunktionen deines Geräts (PIN, Fingerabdruck, etc.)</li>
          </ul>

          <h3 className="text-xl font-semibold mb-4 text-white">Wichtige Hinweise</h3>
          <div className="bg-yellow-900/20 border border-yellow-700/30 rounded-2xl p-6">
            <p className="text-gray-300 mb-4">
              <strong className="text-yellow-400">⚠️ Backups:</strong> Du bist selbst verantwortlich für Backups deiner Daten.
              Bei Verlust oder Beschädigung des Geräts können die Daten nicht wiederhergestellt werden, da sie
              ausschließlich lokal gespeichert sind.
            </p>
            <p className="text-gray-300">
              <strong className="text-green-400">💡 Empfehlung:</strong> Nutze die Backup-Funktion deines Geräts (Android
              Backup) oder exportiere wichtige Daten regelmäßig (geplante Funktion).
            </p>
          </div>
        </section>

        {/* 5. Datenlöschung */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">5. Datenlöschung</h2>
          <p className="text-gray-300 mb-4">
            Du hast jederzeit <strong className="text-white">volle Kontrolle</strong> über deine Daten:
          </p>
          <ul className="list-disc list-inside space-y-2 text-gray-300 mb-4">
            <li>Einzelne Chat-Nachrichten können gelöscht werden</li>
            <li>Kalender-Termine können gelöscht werden</li>
            <li>Tagebuch-Einträge können gelöscht werden</li>
            <li>Profile können deaktiviert werden</li>
            <li>In den Einstellungen gibt es eine Funktion <strong className="text-white">"Alle Daten löschen"</strong></li>
            <li>Bei Deinstallation der App werden <strong className="text-white">alle Daten automatisch gelöscht</strong></li>
          </ul>
          <p className="text-gray-300 leading-relaxed">
            <strong className="text-white">Wichtig:</strong> Gelöschte Daten können{' '}
            <strong className="text-white">nicht wiederhergestellt</strong> werden, da keine Backups auf Servern existieren.
          </p>
        </section>

        {/* 6. Deine Rechte (DSGVO) */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">6. Deine Rechte (DSGVO)</h2>
          <p className="text-gray-300 mb-6">Du hast folgende Rechte bezüglich deiner personenbezogenen Daten:</p>

          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-2 text-white">Auskunftsrecht (Art. 15 DSGVO)</h3>
              <p className="text-gray-300 text-sm">
                Da alle Daten ausschließlich lokal auf deinem Gerät gespeichert sind, hast du{' '}
                <strong className="text-white">jederzeit vollständige Einsicht</strong> in alle gespeicherten Daten
                direkt in der App.
              </p>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-2 text-white">Recht auf Berichtigung (Art. 16 DSGVO)</h3>
              <p className="text-gray-300 text-sm">
                Du kannst alle Daten jederzeit selbst bearbeiten (Profile, Einträge, Einstellungen).
              </p>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-2 text-white">Recht auf Löschung (Art. 17 DSGVO)</h3>
              <p className="text-gray-300 text-sm">
                Du kannst alle Daten jederzeit selbst löschen oder die App deinstallieren, wodurch alle Daten
                automatisch gelöscht werden.
              </p>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-2 text-white">Recht auf Datenübertragbarkeit (Art. 20 DSGVO)</h3>
              <p className="text-gray-300 text-sm">Eine Export-Funktion ist für zukünftige Versionen geplant.</p>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-2 text-white">Widerspruchsrecht (Art. 21 DSGVO)</h3>
              <p className="text-gray-300 text-sm">
                Da wir keine Daten erheben oder verarbeiten, ist ein Widerspruch nicht erforderlich. Du hast volle
                Kontrolle über deine lokal gespeicherten Daten.
              </p>
            </div>
          </div>
        </section>

        {/* 7. Minderjährigenschutz */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">7. Minderjährigenschutz</h2>
          <p className="text-gray-300 mb-4">
            Die App kann von Minderjährigen genutzt werden. Bei Dissoziativer Identitätsstörung können einige
            Persönlichkeiten minderjährig sein, während andere erwachsen sind.
          </p>
          <ul className="list-disc list-inside space-y-2 text-gray-300">
            <li>
              Es werden <strong className="text-white">keine besonderen Kategorien</strong> personenbezogener Daten über
              Minderjährige erhoben
            </li>
            <li>Alle Daten bleiben lokal und werden nicht übertragen</li>
            <li>
              <strong className="text-white">Empfehlung:</strong> Bei Nutzung durch Minderjährige sollten
              Erziehungsberechtigte die Nutzung begleiten
            </li>
            <li>Altersgerechte Berechtigungen können pro Profil eingestellt werden</li>
          </ul>
        </section>

        {/* 8. Änderungen der Datenschutzerklärung */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">8. Änderungen der Datenschutzerklärung</h2>
          <p className="text-gray-300 mb-4">
            Diese Datenschutzerklärung kann bei Updates der App angepasst werden, um neue Funktionen oder rechtliche
            Anforderungen zu berücksichtigen.
          </p>
          <p className="text-gray-300">
            Die aktuelle Version ist immer in der App und auf dieser Website einsehbar. Wesentliche Änderungen werden in
            den Update-Notizen der App kommuniziert.
          </p>
        </section>

        {/* 9. Verantwortlicher & Kontakt */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">9. Verantwortlicher & Kontakt</h2>
          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5 mb-6">
            <p className="text-gray-300 mb-3">
              <strong className="text-white">Verantwortlich für die Datenverarbeitung:</strong>
            </p>
            <p className="text-gray-300 leading-relaxed mb-4">
              3ofus<br />
              Nico Wojtera<br />
              Kirchstraße 3<br />
              01640 Coswig<br />
              Deutschland
            </p>
            <p className="text-gray-300">
              <strong className="text-white">E-Mail:</strong>{' '}
              <a href="mailto:info@3ofus.app" className="text-[#FFAB91] hover:text-[#FFCCBC] underline">
                info@3ofus.app
              </a>
            </p>
          </div>
          <p className="text-gray-300">
            Bei Fragen zum Datenschutz oder zur Ausübung deiner Rechte kannst du uns jederzeit unter der oben genannten
            E-Mail-Adresse kontaktieren.
          </p>
        </section>

        {/* 10. Website-Analytics (Firebase) */}
        <section className="mb-12 bg-[#1E1E24] rounded-3xl p-8 border border-white/5">
          <h2 className="text-2xl font-bold mb-6 text-[#FFAB91]">10. Website-Analytics (nur Website, nicht App!)</h2>
          <p className="text-gray-300 mb-4">
            Für unsere <strong className="text-white">Website</strong> (nicht die App!) nutzen wir Firebase Analytics von Google, um zu verstehen, wie Besucher die Website nutzen und sie zu verbessern.
          </p>

          <h3 className="text-lg font-semibold mb-3 text-white">Erfasste Daten</h3>
          <ul className="list-disc list-inside space-y-2 text-gray-300 mb-6">
            <li>Besuchte Seiten (z.B. /dis-check, /was-ist-dis)</li>
            <li>Klicks auf Buttons (z.B. "App laden")</li>
            <li>Gerätetype (Desktop, Mobile, Tablet)</li>
            <li>Land (nur grob: Deutschland, Österreich, Schweiz)</li>
            <li>Traffic-Quelle (z.B. Google, direkt, Social Media)</li>
            <li>Verweildauer auf Seiten</li>
          </ul>

          <h3 className="text-lg font-semibold mb-3 text-white">NICHT erfasst</h3>
          <ul className="space-y-2 text-gray-300 mb-6">
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine IP-Adressen (automatisch anonymisiert)</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine personenbezogenen Daten</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Keine Cookies (cookieless Analytics)</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-red-400 font-bold">❌</span>
              <span>Kein Cross-Site Tracking</span>
            </li>
          </ul>

          <div className="bg-[#121215] rounded-2xl p-6 border border-white/5">
            <h3 className="text-lg font-semibold mb-3 text-white">Rechtsgrundlage & Datenverarbeitung</h3>
            <ul className="space-y-2 text-gray-300 text-sm">
              <li><strong className="text-white">Anbieter:</strong> Google LLC, Gordon House, Barrow Street, Dublin 4, Irland</li>
              <li><strong className="text-white">Datenverarbeitung:</strong> Anonymisiert, EU-Server (wenn möglich)</li>
              <li><strong className="text-white">Rechtsgrundlage:</strong> Berechtigtes Interesse (Art. 6 Abs. 1 f DSGVO) zur Verbesserung der Website</li>
              <li><strong className="text-white">Speicherdauer:</strong> 14 Monate (automatische Löschung)</li>
              <li>
                <strong className="text-white">Opt-Out:</strong> Du kannst Analytics blockieren durch:
                <ul className="list-disc list-inside ml-4 mt-2">
                  <li>Browser Do-Not-Track Einstellung</li>
                  <li>Browser Add-On: <a href="https://tools.google.com/dlpage/gaoptout" target="_blank" rel="noopener noreferrer" className="text-[#FFAB91] hover:text-[#FFCCBC] underline">Google Analytics Opt-out</a></li>
                </ul>
              </li>
            </ul>
          </div>

          <p className="text-gray-400 text-sm mt-6">
            <strong>Wichtig:</strong> Diese Analytics betrifft NUR die Website (aurora.3ofus.app). Die Aurora-App bleibt komplett offline und trackt NICHTS!
          </p>
        </section>

        {/* 11. Zusammenfassung */}
        <section className="mb-12 bg-gradient-to-br from-green-900/20 to-[#1E1E24] rounded-3xl p-8 border border-green-500/20">
          <h2 className="text-2xl font-bold mb-6 text-green-400 flex items-center gap-2">
            <Lock size={28} />
            11. Zusammenfassung - Aurora: Deine Daten gehören dir
          </h2>
          <ul className="space-y-3">
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>Alle Daten bleiben ausschließlich auf deinem Gerät</span>
            </li>
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>Keine Cloud-Synchronisation oder Server</span>
            </li>
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>Keine Benutzerkonten oder Login</span>
            </li>
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>App: Kein Tracking, keine Analytics, keine Werbung (Website nutzt anonymes Analytics)</span>
            </li>
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>Volle Kontrolle über deine Daten (Löschen jederzeit möglich)</span>
            </li>
            <li className="flex items-start gap-3 text-gray-300">
              <CheckCircle className="text-green-400 flex-shrink-0 mt-0.5" size={20} />
              <span>DSGVO-konform durch Privacy-by-Design</span>
            </li>
          </ul>
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
