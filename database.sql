-- Drop existing table and related objects
DROP TABLE IF EXISTS maid_profiles CASCADE;

-- Create maid_profiles table with all required columns
CREATE TABLE maid_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    age_group VARCHAR(20) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    marital_status VARCHAR(20) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    education VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    emergency_contact VARCHAR(20) NOT NULL,
    years_of_experience INTEGER NOT NULL,
    skills TEXT[] NOT NULL,
    languages TEXT[] NOT NULL,
    work_type VARCHAR(50) NOT NULL,
    preferred_time VARCHAR(20) NOT NULL,
    expected_salary DECIMAL(10,2) NOT NULL,
    work_location TEXT NOT NULL,
    additional_notes TEXT,
    profile_photo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_id UNIQUE (user_id)
);

-- Create trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger
CREATE TRIGGER update_maid_profiles_updated_at
    BEFORE UPDATE ON maid_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create RLS (Row Level Security) policies
ALTER TABLE maid_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile"
    ON maid_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON maid_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON maid_profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- Create indexes for better query performance
CREATE INDEX idx_maid_profiles_user_id ON maid_profiles(user_id);
CREATE INDEX idx_maid_profiles_work_type ON maid_profiles(work_type);
CREATE INDEX idx_maid_profiles_nationality ON maid_profiles(nationality);
CREATE INDEX idx_maid_profiles_education ON maid_profiles(education);
CREATE INDEX idx_maid_profiles_age_group ON maid_profiles(age_group);
CREATE INDEX idx_maid_profiles_work_location ON maid_profiles(work_location);

-- Create storage bucket for profile photos if not exists
INSERT INTO storage.buckets (id, name)
VALUES ('profile-photos', 'profile-photos')
ON CONFLICT (id) DO NOTHING;

-- Comments for table columns
COMMENT ON TABLE maid_profiles IS 'Stores maid profile information';
COMMENT ON COLUMN maid_profiles.id IS 'Unique identifier for the maid profile';
COMMENT ON COLUMN maid_profiles.user_id IS 'Reference to auth.users table';
COMMENT ON COLUMN maid_profiles.full_name IS 'Full name of the maid';
COMMENT ON COLUMN maid_profiles.age_group IS 'Age group (20+, 25+, 30+, 35+, 40+)';
COMMENT ON COLUMN maid_profiles.gender IS 'Gender of the maid';
COMMENT ON COLUMN maid_profiles.marital_status IS 'Marital status';
COMMENT ON COLUMN maid_profiles.nationality IS 'Nationality (Nepali, Indian, Chinese, Other)';
COMMENT ON COLUMN maid_profiles.education IS 'Education level';
COMMENT ON COLUMN maid_profiles.email IS 'Contact email address';
COMMENT ON COLUMN maid_profiles.phone IS 'Contact phone number';
COMMENT ON COLUMN maid_profiles.address IS 'Current residential address';
COMMENT ON COLUMN maid_profiles.emergency_contact IS 'Emergency contact number';
COMMENT ON COLUMN maid_profiles.years_of_experience IS 'Years of work experience';
COMMENT ON COLUMN maid_profiles.skills IS 'Array of skills';
COMMENT ON COLUMN maid_profiles.languages IS 'Array of languages spoken';
COMMENT ON COLUMN maid_profiles.work_type IS 'Type of work (Full Time, Part Time, Live In, Live Out)';
COMMENT ON COLUMN maid_profiles.preferred_time IS 'Preferred working time';
COMMENT ON COLUMN maid_profiles.expected_salary IS 'Expected monthly salary in NR';
COMMENT ON COLUMN maid_profiles.work_location IS 'Preferred work location';
COMMENT ON COLUMN maid_profiles.additional_notes IS 'Additional information (max 150 chars)';
COMMENT ON COLUMN maid_profiles.profile_photo IS 'Profile photo storage path';
COMMENT ON COLUMN maid_profiles.created_at IS 'Timestamp of profile creation';
COMMENT ON COLUMN maid_profiles.updated_at IS 'Timestamp of last profile update';
