/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./citymaidservices/**/*.{html,js}",
    "./src/**/*.{html,js}"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Helvetica Neue', 'Segoe UI', 'Inter', 'sans-serif'],
      },
      colors: {
        whatsapp: {
          primary: '#25D366',    // WhatsApp Green
          secondary: '#128C7E',  // WhatsApp Teal
          dark: '#075E54',       // WhatsApp Dark Green
          light: '#F0F2F5',      // WhatsApp Background
          text: {
            primary: '#111B21',   // WhatsApp Dark Text
            secondary: '#667781', // WhatsApp Secondary Text
            light: '#FFFFFF',     // White text
          }
        }
      },
      boxShadow: {
        'whatsapp': '0 1px 3px rgba(0, 0, 0, 0.1)',
        'whatsapp-hover': '0 2px 4px rgba(0, 0, 0, 0.15)',
      },
      borderRadius: {
        'whatsapp': '8px',
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
} 