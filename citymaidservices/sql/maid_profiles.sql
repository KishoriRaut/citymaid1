-- First, drop existing objects if they exist
DO $$ 
BEGIN
    -- Drop the table if it exists
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'maid_profiles') THEN
        DROP TABLE maid_profiles CASCADE;
    END IF;

    -- Drop the function if it exists
    IF EXISTS (SELECT FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        DROP FUNCTION update_updated_at_column() CASCADE;
    END IF;
END $$;

-- Create maid_profiles table
CREATE TABLE maid_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic Information
    full_name VARCHAR(50) NOT NULL,
    age_group VARCHAR(10) NOT NULL CHECK (age_group IN ('18-25', '25-35', '35-45', '45+')),
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Female', 'Male', 'Other')),
    marital_status VARCHAR(10) NOT NULL CHECK (marital_status IN ('Single', 'Married', 'Divorced', 'Widowed')),
    
    -- Contact Information
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(10) NOT NULL,
    
    -- Work Information
    experience INTEGER NOT NULL CHECK (experience >= 0),
    available_from VARCHAR(20) NOT NULL CHECK (available_from IN ('Immediate', 'Within a week', 'Within 2 weeks', 'Within a month', 'After a month')),
    preferred_time VARCHAR(20) NOT NULL,
    expected_salary INTEGER NOT NULL CHECK (expected_salary >= 0),
    major_city VARCHAR(50) NOT NULL,
    specific_areas TEXT[] DEFAULT '{}',
    willing_to_travel BOOLEAN DEFAULT false,
    travel_distance INTEGER,
    
    -- Background Information
    nationality VARCHAR(50) NOT NULL,
    religion VARCHAR(50),
    education VARCHAR(50) NOT NULL,
    documents VARCHAR(50) NOT NULL,
    languages TEXT[] DEFAULT '{}',
    
    -- Skills and About
    about TEXT NOT NULL,
    skills TEXT[] DEFAULT '{}',
    profile_photo TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_phone CHECK (phone ~ '^[0-9]{10}$'),
    CONSTRAINT valid_email CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);

-- Create index for faster lookups
CREATE INDEX idx_maid_profiles_user_id ON maid_profiles(user_id);
CREATE INDEX idx_maid_profiles_major_city ON maid_profiles(major_city);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_maid_profiles_updated_at
    BEFORE UPDATE ON maid_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create RLS policies
ALTER TABLE maid_profiles ENABLE ROW LEVEL SECURITY;

-- Policy for users to view their own profile
CREATE POLICY "Users can view own profile"
    ON maid_profiles FOR SELECT
    USING (auth.uid() = user_id);

-- Policy for users to insert their own profile
CREATE POLICY "Users can insert own profile"
    ON maid_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy for users to update their own profile
CREATE POLICY "Users can update own profile"
    ON maid_profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy for users to delete their own profile
CREATE POLICY "Users can delete own profile"
    ON maid_profiles FOR DELETE
    USING (auth.uid() = user_id);

-- Grant access to authenticated users
GRANT ALL ON maid_profiles TO authenticated; 