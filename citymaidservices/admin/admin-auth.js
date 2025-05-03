// Initialize Supabase client
const SUPABASE_URL = 'https://fdgqqxyyofjnkhswkwcq.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkZ3FxeHl5b2Zqbmtoc3drd2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMjQyMTMsImV4cCI6MjA1OTYwMDIxM30.YyJLLu3r2a7Mh7ny0ie-YzzLfPh5PdrJJHnBFBxWqVE';

// Create supabase client if not already defined
let supabaseClient;
if (typeof supabase !== 'undefined') {
    supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
} else {
    console.error("Supabase library not loaded!");
}

/**
 * Check if the current user has admin privileges
 * @returns {Promise<{isAdmin: boolean, user: Object|null, error: string|null}>}
 */
async function checkAdminAuth() {
    try {
        const { data: { session }, error } = await supabaseClient.auth.getSession();
        
        if (error || !session) {
            return { isAdmin: false, user: null, error: "Not authenticated" };
        }
        
        // Check if the user has admin role
        const { data: profile, error: profileError } = await supabaseClient
            .from('profiles')
            .select('role, first_name, last_name')
            .eq('id', session.user.id)
            .single();
        
        if (profileError || !profile) {
            return { isAdmin: false, user: session.user, error: "Profile not found" };
        }
        
        if (profile.role !== 'admin') {
            return { isAdmin: false, user: session.user, error: "Access denied. Admin privileges required." };
        }
        
        return { 
            isAdmin: true, 
            user: {
                ...session.user,
                first_name: profile.first_name,
                last_name: profile.last_name,
                display_name: `${profile.first_name || ''} ${profile.last_name || ''}`.trim() || session.user.email.split('@')[0]
            }, 
            error: null 
        };
    } catch (error) {
        console.error("Authentication error:", error);
        return { isAdmin: false, user: null, error: error.message || "Authentication error" };
    }
}

/**
 * Protects an admin page - redirects to access denied if not admin
 * @param {Function} successCallback - Called if user is authenticated admin
 */
async function protectAdminPage(successCallback) {
    const { isAdmin, user, error } = await checkAdminAuth();
    
    if (!isAdmin) {
        if (user) {
            // User is logged in but not admin, sign them out
            await supabaseClient.auth.signOut();
        }
        window.location.href = 'access-denied.html?error=' + encodeURIComponent(error || 'Access denied. Admin privileges required.');
        return;
    }
    
    // Update admin name in UI if element exists
    const adminNameEl = document.getElementById('adminName');
    if (adminNameEl && user) {
        adminNameEl.textContent = user.display_name;
    }
    
    // Run success callback
    if (typeof successCallback === 'function') {
        successCallback(user);
    }
}

/**
 * Logs admin out and redirects to login page
 */
async function adminLogout() {
    try {
        await supabaseClient.auth.signOut();
        window.location.href = '../auth/admin-login.html';
    } catch (error) {
        console.error("Error logging out:", error);
        alert("Error logging out: " + error.message);
    }
}

// Add event listener to logout button if it exists
document.addEventListener('DOMContentLoaded', () => {
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            adminLogout();
        });
    }
}); 