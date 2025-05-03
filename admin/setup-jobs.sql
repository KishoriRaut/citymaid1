-- Create jobs table if it doesn't exist
CREATE TABLE IF NOT EXISTS jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employer_id UUID REFERENCES auth.users ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    job_type TEXT NOT NULL CHECK (job_type IN ('regular', 'one-time', 'weekly', 'monthly', 'full-time', 'live-in')),
    hourly_rate INTEGER NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'filled', 'closed', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Jobs are viewable by everyone" ON jobs;
DROP POLICY IF EXISTS "Employers can insert their own jobs" ON jobs;
DROP POLICY IF EXISTS "Employers can update their own jobs" ON jobs;
DROP POLICY IF EXISTS "Employers can delete their own jobs" ON jobs;
DROP POLICY IF EXISTS "Admins can manage all jobs" ON jobs;

-- Create policies
CREATE POLICY "Jobs are viewable by everyone"
    ON jobs FOR SELECT
    USING (true);

CREATE POLICY "Employers can insert their own jobs"
    ON jobs FOR INSERT
    WITH CHECK (
        auth.uid() = employer_id AND
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'employer'
        )
    );

CREATE POLICY "Employers can update their own jobs"
    ON jobs FOR UPDATE
    USING (
        auth.uid() = employer_id AND
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'employer'
        )
    );

CREATE POLICY "Employers can delete their own jobs"
    ON jobs FOR DELETE
    USING (
        auth.uid() = employer_id AND
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'employer'
        )
    );

CREATE POLICY "Admins can manage all jobs"
    ON jobs FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create function to handle job creation
CREATE OR REPLACE FUNCTION public.create_job(
    p_title TEXT,
    p_description TEXT,
    p_location TEXT,
    p_job_type TEXT,
    p_hourly_rate INTEGER
)
RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    -- Check if user is an employer
    IF NOT EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND role = 'employer'
    ) THEN
        RAISE EXCEPTION 'Only employers can create jobs';
    END IF;

    -- Insert new job
    INSERT INTO jobs (
        employer_id,
        title,
        description,
        location,
        job_type,
        hourly_rate
    ) VALUES (
        auth.uid(),
        p_title,
        p_description,
        p_location,
        p_job_type,
        p_hourly_rate
    ) RETURNING id INTO v_job_id;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update job
CREATE OR REPLACE FUNCTION public.update_job(
    p_job_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_location TEXT,
    p_job_type TEXT,
    p_hourly_rate INTEGER,
    p_status TEXT
)
RETURNS void AS $$
BEGIN
    -- Check if user is the employer or admin
    IF NOT EXISTS (
        SELECT 1 FROM jobs j
        LEFT JOIN profiles p ON p.id = auth.uid()
        WHERE j.id = p_job_id
        AND (j.employer_id = auth.uid() OR p.role = 'admin')
    ) THEN
        RAISE EXCEPTION 'You do not have permission to update this job';
    END IF;

    -- Update job
    UPDATE jobs
    SET
        title = COALESCE(p_title, title),
        description = COALESCE(p_description, description),
        location = COALESCE(p_location, location),
        job_type = COALESCE(p_job_type, job_type),
        hourly_rate = COALESCE(p_hourly_rate, hourly_rate),
        status = COALESCE(p_status, status),
        updated_at = TIMEZONE('utc'::text, NOW())
    WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to delete job
CREATE OR REPLACE FUNCTION public.delete_job(p_job_id UUID)
RETURNS void AS $$
BEGIN
    -- Check if user is the employer or admin
    IF NOT EXISTS (
        SELECT 1 FROM jobs j
        LEFT JOIN profiles p ON p.id = auth.uid()
        WHERE j.id = p_job_id
        AND (j.employer_id = auth.uid() OR p.role = 'admin')
    ) THEN
        RAISE EXCEPTION 'You do not have permission to delete this job';
    END IF;

    -- Delete job
    DELETE FROM jobs WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get job details
CREATE OR REPLACE FUNCTION public.get_job_details(p_job_id UUID)
RETURNS TABLE (
    id UUID,
    employer_id UUID,
    title TEXT,
    description TEXT,
    location TEXT,
    job_type TEXT,
    hourly_rate INTEGER,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    employer_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        j.id,
        j.employer_id,
        j.title,
        j.description,
        j.location,
        j.job_type,
        j.hourly_rate,
        j.status,
        j.created_at,
        j.updated_at,
        CONCAT(p.first_name, ' ', p.last_name) as employer_name
    FROM jobs j
    LEFT JOIN profiles p ON p.id = j.employer_id
    WHERE j.id = p_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 