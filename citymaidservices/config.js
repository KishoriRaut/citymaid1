// Brand Configuration
const BRAND_CONFIG = {
    // Main brand name settings
    FULL_NAME: "City Maid Services",
    SHORT_NAME: "City Maid",
    
    // Supabase connection settings
    SUPABASE_URL: 'https://fdgqqxyyofjnkhswkwcq.supabase.co',
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkZ3FxeHl5b2Zqbmtoc3drd2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMjQyMTMsImV4cCI6MjA1OTYwMDIxM30.YyJLLu3r2a7Mh7ny0ie-YzzLfPh5PdrJJHnBFBxWqVE',
    
    // Payment settings
    PAYMENT_GATEWAY: 'Khalti',
    CONTACT_UNLOCK_FEE: 500, // in NR
    
    // Site settings
    DEFAULT_CURRENCY: 'NR',
    DEFAULT_LANGUAGE: 'en',
    
    // Feature flags
    ENABLE_REGISTRATION: true,
    ENABLE_PAYMENTS: true,
    ENABLE_CONTACT_UNLOCK: true
};

// Initialize Supabase client if Supabase JS is loaded
if (typeof supabase !== 'undefined' && typeof supabase.createClient === 'function') {
    const supabaseClient = supabase.createClient(BRAND_CONFIG.SUPABASE_URL, BRAND_CONFIG.SUPABASE_ANON_KEY);
} 