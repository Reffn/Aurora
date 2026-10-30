import path from 'path';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Kein `define` für Schlüssel mehr. Hier wurde `GEMINI_API_KEY` aus der
// Umgebung in das Bündel geschrieben — ein Geheimnis, das jeder Besucher
// hätte auslesen können. Der Dienst, der ihn benutzt hätte
// (`services/geminiService.ts`), war von nirgendwo importiert und ist
// zusammen mit der Abhängigkeit entfernt.
export default defineConfig(() => {
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [react()],
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      }
    };
});
