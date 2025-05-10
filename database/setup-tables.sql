-- Create maid_profiles table
CREATE TABLE IF NOT EXISTS maid_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    age_group TEXT,
    gender TEXT,
    marital_status TEXT,
    email TEXT,
    phone TEXT,
    experience TEXT,
    available_from TEXT,
    preferred_time TEXT,
    expected_salary INTEGER,
    major_city TEXT,
    specific_areas TEXT[],
    willing_to_travel BOOLEAN DEFAULT false,
    travel_distance INTEGER,
    nationality TEXT,
    religion TEXT,
    education TEXT,
    documents TEXT,
    languages TEXT[],
    about TEXT,
    skills TEXT[],
    profile_photo TEXT,
    is_active BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create profile_views table
CREATE TABLE IF NOT EXISTS profile_views (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    maid_id UUID REFERENCES maid_profiles(id) ON DELETE CASCADE,
    viewer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create contact_unlocks table
CREATE TABLE IF NOT EXISTS contact_unlocks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    maid_id UUID REFERENCES maid_profiles(id) ON DELETE CASCADE,
    employer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create RLS policies
ALTER TABLE maid_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_unlocks ENABLE ROW LEVEL SECURITY;

-- Maid profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
    ON maid_profiles FOR SELECT
    USING (is_active = true);

CREATE POLICY "Users can view their own profile"
    ON maid_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
    ON maid_profiles FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile"
    ON maid_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Profile views policies
CREATE POLICY "Anyone can view profile view counts"
    ON profile_views FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can create profile views"
    ON profile_views FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Contact unlocks policies
CREATE POLICY "Anyone can view contact unlock counts"
    ON contact_unlocks FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can create contact unlocks"
    ON contact_unlocks FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_maid_profiles_user_id ON maid_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profile_views_maid_id ON profile_views(maid_id);
CREATE INDEX IF NOT EXISTS idx_contact_unlocks_maid_id ON contact_unlocks(maid_id); 