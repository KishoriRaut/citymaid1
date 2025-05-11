-- Enable Row Level Security
ALTER TABLE maid_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for maid_profiles table

-- Policy for maids to view their own profile
CREATE POLICY "Maids can view own profile"
ON maid_profiles
FOR SELECT
USING (auth.uid() = user_id);

-- Policy for maids to update their own profile
CREATE POLICY "Maids can update own profile"
ON maid_profiles
FOR UPDATE
USING (auth.uid() = user_id);

-- Policy for maids to insert their own profile
CREATE POLICY "Maids can insert own profile"
ON maid_profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy for public to view active profiles
CREATE POLICY "Public can view active profiles"
ON maid_profiles
FOR SELECT
USING (status = 'active');

-- Policy for admins to manage all profiles
CREATE POLICY "Admins can manage all profiles"
ON maid_profiles
USING (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role = 'admin'
  )
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_maid_profiles_user_id ON maid_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_maid_profiles_status ON maid_profiles(status); 