// Initialize Supabase client
const supabaseClient = supabase.createClient(BRAND_CONFIG.SUPABASE_URL, BRAND_CONFIG.SUPABASE_ANON_KEY);

// Image loading and error handling
async function getProfilePhotoUrl(photoPath) {
    try {
        if (!photoPath) return '/assets/images/default-profile.png';
        const { data, error } = await supabaseClient.storage
            .from('profile_photos')
            .getPublicUrl(photoPath);
        
        if (error) throw error;
        return data.publicUrl;
    } catch (error) {
        console.error('Error loading profile photo:', error);
        return '/assets/images/default-profile.png';
    }
}

// Render maid card with loading states
async function renderMaidCard(maid) {
    const card = document.createElement('div');
    card.className = 'maid-card bg-white rounded-lg shadow-md overflow-hidden';
    
    // Add loading state
    card.innerHTML = `
        <div class="image-container image-loading">
            <img src="/assets/images/placeholder.png" alt="Loading..." class="w-full h-48 object-cover">
        </div>
        <div class="p-4">
            <h3 class="text-lg font-semibold mb-2">${maid.name}</h3>
            <div class="flex flex-wrap gap-2 mb-3">
                ${maid.skills.map(skill => `
                    <span class="skill-tag bg-gray-100 px-2 py-1 rounded-full text-sm">
                        ${skill}
                    </span>
                `).join('')}
            </div>
            <button class="contact-button w-full bg-whatsapp-primary text-white py-2 rounded-lg hover:bg-whatsapp-secondary transition-colors">
                Unlock Contact (NR ${BRAND_CONFIG.CONTACT_UNLOCK_FEE})
            </button>
        </div>
    `;

    // Load profile photo
    try {
        const photoUrl = await getProfilePhotoUrl(maid.photo_path);
        const img = card.querySelector('img');
        img.src = photoUrl;
        img.onerror = () => {
            img.src = '/assets/images/default-profile.png';
        };
        img.onload = () => {
            card.querySelector('.image-loading').classList.remove('image-loading');
        };
    } catch (error) {
        console.error('Error loading maid photo:', error);
    }

    // Add contact unlock functionality
    const unlockButton = card.querySelector('.contact-button');
    unlockButton.addEventListener('click', () => unlockContact(maid.id));

    return card;
}

// Contact unlocking with Khalti payment
async function unlockContact(maidId) {
    try {
        // Show loading state
        const button = event.target;
        const originalText = button.innerHTML;
        button.innerHTML = '<div class="loading-spinner mx-auto"></div>';
        button.disabled = true;

        // Initialize Khalti payment
        const config = {
            publicKey: BRAND_CONFIG.KHALTI_PUBLIC_KEY,
            productIdentity: `maid-${maidId}`,
            productName: "Maid Contact Unlock",
            productUrl: window.location.href,
            amount: BRAND_CONFIG.CONTACT_UNLOCK_FEE * 100, // Convert to paisa
            eventHandler: {
                onSuccess: async (payload) => {
                    try {
                        // Verify payment with backend
                        const { data, error } = await supabaseClient
                            .from('unlocked_contacts')
                            .insert([
                                {
                                    maid_id: maidId,
                                    user_id: getCurrentUserId(),
                                    payment_id: payload.idx,
                                    amount: BRAND_CONFIG.CONTACT_UNLOCK_FEE
                                }
                            ]);

                        if (error) throw error;

                        // Show success and display contact info
                        showContactInfo(maidId);
                    } catch (error) {
                        console.error('Payment verification failed:', error);
                        showError('Payment verification failed. Please contact support.');
                    }
                },
                onError: (error) => {
                    console.error('Payment failed:', error);
                    showError('Payment failed. Please try again.');
                },
                onClose: () => {
                    button.innerHTML = originalText;
                    button.disabled = false;
                }
            }
        };

        const checkout = new KhaltiCheckout(config);
        checkout.show({ amount: config.amount });
    } catch (error) {
        console.error('Error initiating payment:', error);
        showError('Failed to initiate payment. Please try again.');
    }
}

// Show contact information after successful payment
async function showContactInfo(maidId) {
    try {
        const { data, error } = await supabaseClient
            .from('maid_profiles')
            .select('phone, email, address')
            .eq('id', maidId)
            .single();

        if (error) throw error;

        // Show contact info in modal
        const modal = document.createElement('div');
        modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center modal-enter';
        modal.innerHTML = `
            <div class="bg-white p-6 rounded-lg max-w-md w-full">
                <h3 class="text-xl font-semibold mb-4">Contact Information</h3>
                <div class="space-y-3">
                    <p><strong>Phone:</strong> ${data.phone}</p>
                    <p><strong>Email:</strong> ${data.email}</p>
                    <p><strong>Address:</strong> ${data.address}</p>
                </div>
                <button class="mt-6 w-full bg-whatsapp-primary text-white py-2 rounded-lg hover:bg-whatsapp-secondary transition-colors">
                    Close
                </button>
            </div>
        `;

        document.body.appendChild(modal);
        modal.querySelector('button').addEventListener('click', () => {
            modal.remove();
        });
    } catch (error) {
        console.error('Error fetching contact info:', error);
        showError('Failed to load contact information. Please try again.');
    }
}

// Error handling
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg error-state';
    errorDiv.textContent = message;
    document.body.appendChild(errorDiv);
    setTimeout(() => errorDiv.remove(), 5000);
}

// Initialize maid cards on page load
document.addEventListener('DOMContentLoaded', async () => {
    try {
        const { data: maids, error } = await supabaseClient
            .from('maid_profiles')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        const container = document.querySelector('#maid-cards-container');
        if (!container) return;

        for (const maid of maids) {
            const card = await renderMaidCard(maid);
            container.appendChild(card);
        }
    } catch (error) {
        console.error('Error loading maid profiles:', error);
        showError('Failed to load maid profiles. Please refresh the page.');
    }
}); 