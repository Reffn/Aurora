/** @type {import('tailwindcss').Config} */
// Wortgleich die Konfiguration, die vorher als `tailwind.config = {...}` im
// Kopf der index.html stand und vom CDN-Skript gelesen wurde. Sie wandert
// hierher, weil das CDN weg ist: Tailwind wird jetzt beim Bauen aufgelöst und
// als fertige CSS-Datei ausgeliefert, statt im Browser jedes Besuchers.
export default {
  content: ['./index.html', './index.tsx', './App.tsx', './pages/**/*.tsx', './components/**/*.tsx'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Outfit', 'sans-serif'],
      },
      animation: {
        float: 'float 10s ease-in-out infinite',
        'float-delayed': 'float 10s ease-in-out 5s infinite',
        'pulse-slow': 'pulse 6s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0) scale(1)' },
          '50%': { transform: 'translateY(-20px) scale(1.05)' },
        },
      },
    },
  },
  plugins: [],
};
