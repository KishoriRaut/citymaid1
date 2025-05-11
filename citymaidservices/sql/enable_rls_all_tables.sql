-- Enable RLS for all tables
ALTER TABLE maid_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Policies for maid_profiles table
CREATE POLICY "Maids can view own profile"
ON maid_profiles
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Maids can update own profile"
ON maid_profiles
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Maids can insert own profile"
ON maid_profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public can view active profiles"
ON maid_profiles
FOR SELECT
USING (status = 'active');

CREATE POLICY "Admins can manage all profiles"
ON maid_profiles
USING (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role = 'admin'
  )
);

-- Policies for user_roles table
CREATE POLICY "Users can view own role"
ON user_roles
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all roles"
ON user_roles
USING (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role = 'admin'
  )
);

-- Policies for reviews table
CREATE POLICY "Users can view all reviews"
ON reviews
FOR SELECT
USING (true);

CREATE POLICY "Users can create reviews"
ON reviews
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
ON reviews
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all reviews"
ON reviews
USING (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role = 'admin'
  )
);

-- Policies for payments table
CREATE POLICY "Users can view own payments"
ON payments
FOR SELECT
USING (
  auth.uid() = user_id OR 
  auth.uid() IN (
    SELECT user_id FROM maid_profiles 
    WHERE id = maid_id
  )
);

CREATE POLICY "Users can create payments"
ON payments
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can manage all payments"
ON payments
USING (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role = 'admin'
  )
);

-- Policies for notifications table
CREATE POLICY "Users can view own notifications"
ON notifications
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON notifications
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "System can create notifications"
ON notifications
FOR INSERT
WITH CHECK (
  auth.uid() IN (
    SELECT user_id FROM user_roles 
    WHERE role IN ('admin', 'system')
  )
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_maid_profiles_user_id ON maid_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_maid_profiles_status ON maid_profiles(status);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_maid_id ON payments(maid_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);

-- Create storage policies for profile photos
CREATE POLICY "Users can upload own profile photos"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' AND
  auth.uid() = (storage.foldername(name))[1]::uuid
);

CREATE POLICY "Users can view all profile photos"
ON storage.objects
FOR SELECT
USING (bucket_id = 'profile-photos');

CREATE POLICY "Users can update own profile photos"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'profile-photos' AND
  auth.uid() = (storage.foldername(name))[1]::uuid
);

CREATE POLICY "Users can delete own profile photos"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'profile-photos' AND
  auth.uid() = (storage.foldername(name))[1]::uuid
); 