// Initialize Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// State management
let isLoading = true;
let hasError = false;
let profiles = [];

// DOM Elements
const loadingState = document.getElementById('loadingState');
const errorState = document.getElementById('errorState');
const emptyState = document.getElementById('emptyState');
const featuredProfiles = document.getElementById('featuredProfiles');

// Load featured profiles
async function loadFeaturedProfiles() {
    try {
        // Show loading state
        setLoadingState(true);
        
        // Fetch profiles from Supabase
        const { data, error } = await supabase
            .from('maid_profiles')
            .select('*')
            .eq('is_featured', true)
            .limit(6);
            
        if (error) throw error;
        
        // Update profiles
        profiles = data || [];
        
        // Update UI
        if (profiles.length === 0) {
            showEmptyState();
        } else {
            renderProfiles();
        }
    } catch (error) {
        console.error('Error loading profiles:', error);
        showErrorState();
    } finally {
        setLoadingState(false);
    }
}

// Render profiles to the grid
function renderProfiles() {
    // Clear existing content
    featuredProfiles.innerHTML = '';
    
    // Add profile cards
    profiles.forEach(profile => {
        const card = createProfileCard(profile);
        featuredProfiles.appendChild(card);
    });
}

// Create profile card element
function createProfileCard(profile) {
    const card = document.createElement('div');
    card.className = 'bg-white rounded-lg shadow-whatsapp hover:shadow-whatsapp-hover transition-all duration-200 overflow-hidden';
    
    card.innerHTML = `
        <div class="aspect-w-16 aspect-h-9 bg-whatsapp-light">
            <img src="${profile.photo_url || 'assets/default-profile.jpg'}" 
                 alt="${profile.full_name}"
                 class="object-cover w-full h-full">
        </div>
        <div class="p-6">
            <h3 class="text-lg font-semibold text-whatsapp-text-primary mb-2">${profile.full_name}</h3>
            <div class="flex items-center text-whatsapp-text-secondary mb-4">
                <i class="fas fa-map-marker-alt mr-2"></i>
                <span>${profile.location}</span>
            </div>
            <div class="flex flex-wrap gap-2 mb-4">
                ${profile.skills.map(skill => `
                    <span class="bg-whatsapp-light text-whatsapp-text-secondary px-3 py-1 rounded-full text-sm">
                        ${skill}
                    </span>
                `).join('')}
            </div>
            <button onclick="viewProfile('${profile.id}')" 
                    class="w-full bg-whatsapp-primary text-white py-2 rounded-lg hover:bg-whatsapp-secondary transition-colors">
                View Profile
            </button>
        </div>
    `;
    
    return card;
}

// State management functions
function setLoadingState(loading) {
    isLoading = loading;
    loadingState.classList.toggle('hidden', !loading);
    errorState.classList.add('hidden');
    emptyState.classList.add('hidden');
}

function showErrorState() {
    hasError = true;
    errorState.classList.remove('hidden');
    loadingState.classList.add('hidden');
    emptyState.classList.add('hidden');
}

function showEmptyState() {
    emptyState.classList.remove('hidden');
    loadingState.classList.add('hidden');
    errorState.classList.add('hidden');
}

// View profile handler
function viewProfile(profileId) {
    // Check if user is logged in
    const isLoggedIn = checkAuthStatus();
    
    if (!isLoggedIn) {
        // Show login prompt
        document.getElementById('loginPromptModal').classList.remove('hidden');
    } else {
        // Navigate to profile page
        window.location.href = `maid/profile.html?id=${profileId}`;
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadFeaturedProfiles();
}); 