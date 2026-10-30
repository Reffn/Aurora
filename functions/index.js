// Meldet neues In-App-Feedback in einem privaten Discord-Kanal.
//
// Das Feedback lag still in Firestore: Sechs echte Rückmeldungen blieben
// vom 23.08. bis 06.10.2026 ungelesen, weil nichts davon Bescheid gab.
//
// Die Meldung sagt nur, *dass* etwas da ist — nie was. Feedback aus Aurora
// ist Gesundheitsinformation (CLAUDE.md, „Privacy First"); die Funktion
// liest das Dokument gar nicht erst, und auch ins Log kommt nichts davon.
// Gelesen wird wie bisher mit `python tool/aurora_status.py --texte`.
//
// Die Webhook-Adresse liegt im Secret Manager (DISCORD_WEBHOOK), nicht im
// Code: Wer sie kennt, kann in den Kanal schreiben, und dieses Repo ist
// öffentlich.

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

const DISCORD_WEBHOOK = defineSecret("DISCORD_WEBHOOK");

const NACHRICHT =
  "🔔 Aurora: eine neue Rückmeldung ist da.\n" +
  "Lesen mit `python tool/aurora_status.py --texte`";

exports.feedbackMelden = onDocumentCreated(
  {
    document: "feedback/{id}",
    // Muss beim Ort der Datenbank liegen.
    region: "europe-west3",
    secrets: [DISCORD_WEBHOOK],
    // Eine verlorene Meldung ist genau der Fehler, den diese Funktion
    // behebt: Scheitert Discord vorübergehend, versucht Eventarc es erneut.
    retry: true,
    maxInstances: 2,
  },
  async () => {
    let antwort;
    try {
      antwort = await fetch(DISCORD_WEBHOOK.value(), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        // Keine @everyone- oder Rollen-Erwähnungen.
        body: JSON.stringify({
          content: NACHRICHT,
          allowed_mentions: { parse: [] },
        }),
      });
    } catch (fehler) {
      logger.warn("Discord nicht erreichbar, neuer Versuch folgt", {
        fehler: String(fehler),
      });
      throw fehler;
    }

    if (antwort.ok) return;

    // Vorübergehend (Drosselung, Serverfehler): werfen, dann kommt ein
    // neuer Versuch. Dauerhaft (Webhook gelöscht, 4xx): nur melden —
    // ein Wiederholen über Tage brächte nichts außer Kosten.
    const vorruebergehend = antwort.status === 429 || antwort.status >= 500;
    logger.error("Discord lehnt die Meldung ab", {
      status: antwort.status,
      vorruebergehend,
    });
    if (vorruebergehend) {
      throw new Error(`Discord ${antwort.status}`);
    }
  },
);
