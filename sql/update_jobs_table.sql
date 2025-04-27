-- SQL to update the 'jobs' table with new features for job expiration, status, and renewal

-- 1. Add new columns to the 'jobs' table if they don't exist
ALTER TABLE jobs 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active',
ADD COLUMN IF NOT EXISTS posted_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS expiration_date TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '15 days');

-- 2. Create an index on the status column for faster filtering
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);

-- 3. Create an index on the expiration_date column for faster filtering
CREATE INDEX IF NOT EXISTS idx_jobs_expiration_date ON jobs(expiration_date);

-- 4. Create a function to automatically update job status based on expiration date
CREATE OR REPLACE FUNCTION update_expired_jobs()
RETURNS void AS $$
BEGIN
  UPDATE jobs
  SET status = 'expired'
  WHERE status = 'active' AND expiration_date < NOW();
END;
$$ LANGUAGE plpgsql;

-- 5. Create a function to renew a job
CREATE OR REPLACE FUNCTION renew_job(job_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE jobs
  SET 
    status = 'active',
    expiration_date = NOW() + INTERVAL '15 days'
  WHERE id = job_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Create a function to hide a job
CREATE OR REPLACE FUNCTION hide_job(job_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE jobs
  SET status = 'hidden'
  WHERE id = job_id;
END;
$$ LANGUAGE plpgsql;

-- 7. Create a table for tracking unlocked contacts
CREATE TABLE IF NOT EXISTS unlocked_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  job_id UUID NOT NULL REFERENCES jobs(id),
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, job_id)
);

-- 8. Create a table for tracking payments
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  job_id UUID NOT NULL REFERENCES jobs(id),
  amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  payment_id VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Create a table for notifications
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  job_id UUID NOT NULL REFERENCES jobs(id),
  type VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Create a function to send expiration notifications
CREATE OR REPLACE FUNCTION send_expiration_notifications()
RETURNS void AS $$
DECLARE
  job_record RECORD;
BEGIN
  FOR job_record IN 
    SELECT id, employer_id, title, expiration_date 
    FROM jobs 
    WHERE status = 'active' AND expiration_date < NOW() + INTERVAL '3 days'
  LOOP
    INSERT INTO notifications (user_id, job_id, type, message)
    VALUES (
      job_record.employer_id,
      job_record.id,
      'expiration_warning',
      'Your job posting "' || job_record.title || '" will expire in ' || 
      EXTRACT(DAY FROM (job_record.expiration_date - NOW())) || ' days.'
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 11. Create a trigger to automatically update job status when expiration date is reached
CREATE OR REPLACE FUNCTION check_job_expiration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.expiration_date < NOW() AND NEW.status = 'active' THEN
    NEW.status := 'expired';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER job_expiration_trigger
BEFORE INSERT OR UPDATE ON jobs
FOR EACH ROW
EXECUTE FUNCTION check_job_expiration();

-- 12. Create a scheduled job to run the update_expired_jobs function daily
-- Note: This requires pg_cron extension which may not be available in all Supabase instances
-- You may need to implement this as a separate cron job or use Supabase Edge Functions

-- Example of how to use the functions:
-- SELECT renew_job('job-uuid-here');
-- SELECT hide_job('job-uuid-here');
-- SELECT update_expired_jobs();
-- SELECT send_expiration_notifications(); 