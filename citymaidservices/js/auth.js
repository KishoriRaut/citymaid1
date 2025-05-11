// Initialize Supabase client
const supabaseUrl = 'https://fdgqqxyyofjnkhswkwcq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkZ3FxeHl5b2Zqbmtoc3drd2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMjQyMTMsImV4cCI6MjA1OTYwMDIxM30.YyJLLu3r2a7Mh7ny0ie-YzzLfPh5PdrJJHnBFBxWqVE';
const { createClient } = supabase;
const supabaseClient = createClient(supabaseUrl, supabaseKey);

// Auth object to handle all authentication-related functions
const auth = {
    // Sign up a new user
    async signUp(email, password, metadata = {}) {
        try {
            console.log('Attempting to sign up user:', email, 'with role:', metadata.role);
            
            // Check if user exists in profiles table
            const { data: existingProfile, error: profileCheckError } = await supabaseClient
                .from('profiles')
                .select('email')
                .eq('email', email)
                .single();

            if (existingProfile) {
                console.log('User already exists in profiles:', email);
                return {
                    success: false,
                    error: 'An account with this email already exists'
                };
            }

            console.log('Creating new user account...');
            // Create user account with role in metadata
            const { data: authData, error: authError } = await supabaseClient.auth.signUp({
                email,
                password,
                options: {
                    data: {
                        role: metadata.role,
                        full_name: metadata.full_name,
                        phone: metadata.phone
                    }
                }
            });

            if (authError) {
                console.error('Auth error:', authError);
                throw authError;
            }

            if (!authData?.user) {
                console.error('No user data returned from signup');
                throw new Error('Failed to create user account');
            }

            console.log('Creating user profile...');
            // Create profile with role
            const { error: profileError } = await supabaseClient
                .from('profiles')
                .insert([
                    {
                        id: authData.user.id,
                        email: email,
                        role: metadata.role,
                        full_name: metadata.full_name,
                        phone: metadata.phone
                    }
                ]);

            if (profileError) {
                console.error('Profile creation error:', profileError);
                // If profile creation fails, we should clean up the auth user
                await supabaseClient.auth.admin.deleteUser(authData.user.id);
                throw profileError;
            }

            console.log('Sign up successful! User role:', metadata.role);
            return {
                success: true,
                user: authData.user
            };
        } catch (error) {
            console.error('Sign up error:', error);
            return {
                success: false,
                error: error.message || 'Failed to create account'
            };
        }
    },

    // Sign in a user
    async signIn(email, password) {
        try {
            console.log('Attempting to sign in user:', email);
            const { data, error } = await supabaseClient.auth.signInWithPassword({
                email,
                password
            });

            if (error) {
                console.error('Sign in error:', error);
                throw error;
            }

            // Get user profile to ensure we have the role
            const { data: profile, error: profileError } = await supabaseClient
                .from('profiles')
                .select('role')
                .eq('id', data.user.id)
                .single();

            if (profileError) {
                console.error('Error fetching profile:', profileError);
                throw profileError;
            }

            // Update user metadata with role from profile
            if (profile?.role) {
                data.user.user_metadata = {
                    ...data.user.user_metadata,
                    role: profile.role
                };
            }

            console.log('Sign in successful! User role:', data.user.user_metadata.role);
            return {
                success: true,
                user: data.user
            };
        } catch (error) {
            console.error('Sign in error:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Sign out the current user
    async signOut() {
        try {
            const { error } = await supabaseClient.auth.signOut();
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Sign out error:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Get the current user
    async getCurrentUser() {
        try {
            const { data: { user }, error } = await supabaseClient.auth.getUser();
            if (error) throw error;
            return user;
        } catch (error) {
            console.error('Get current user error:', error);
            return null;
        }
    },

    // Check if user is authenticated
    checkAuthStatus() {
        return supabaseClient.auth.getSession() !== null;
    },

    // Reset password
    async resetPassword(email) {
        try {
            const { error } = await supabaseClient.auth.resetPasswordForEmail(email);
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Reset password error:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Update password
    async updatePassword(newPassword) {
        try {
            const { error } = await supabaseClient.auth.updateUser({
                password: newPassword
            });
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Update password error:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Test Supabase connection
    async testConnection() {
        try {
            console.log('Testing Supabase connection...');
            const { data, error } = await supabaseClient.from('profiles').select('count').limit(1);
            
            if (error) {
                console.error('Supabase connection error:', error);
                return false;
            }
            
            console.log('Supabase connection successful!');
            return true;
        } catch (error) {
            console.error('Supabase connection test failed:', error);
            return false;
        }
    }
};

// Test connection on load
auth.testConnection().then(isConnected => {
    console.log('Supabase connection status:', isConnected);
});

// Export auth object
window.auth = auth; 