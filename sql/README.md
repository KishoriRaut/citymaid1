# SQL for Job Management Features

This directory contains SQL statements to add job management features to your Supabase database.

## How to Use These SQL Statements

### Option 1: Using the Supabase Dashboard

1. Log in to your Supabase dashboard
2. Navigate to the "SQL Editor" section
3. Create a new query
4. Copy and paste the contents of `update_jobs_table.sql` into the editor
5. Run the query

### Option 2: Using the Supabase CLI

If you have the Supabase CLI installed:

```bash
supabase db push -f update_jobs_table.sql
```

## Features Added

The SQL script adds the following features to your database:

1. **Job Status Management**
   - Added `status` column to track job status (active, expired, hidden)
   - Added `posted_date` and `expiration_date` columns
   - Created indexes for faster filtering

2. **Job Renewal and Hiding**
   - Created functions to renew jobs (extends expiration by 15 days)
   - Created function to hide jobs (changes status to 'hidden')

3. **Contact Unlocking System**
   - Created `unlocked_contacts` table to track which users have unlocked which jobs
   - Created `payments` table to track payment history

4. **Notification System**
   - Created `notifications` table for storing user notifications
   - Added function to send expiration warnings

5. **Automatic Status Updates**
   - Created trigger to automatically update job status when expiration date is reached
   - Added function to update all expired jobs

## Important Notes

- The script uses `IF NOT EXISTS` clauses to prevent errors if tables or columns already exist
- Some features like scheduled jobs may require additional setup depending on your Supabase plan
- You may need to adjust the SQL based on your specific database schema

## Testing the Features

After running the SQL, you can test the features with these commands:

```sql
-- Renew a job
SELECT renew_job('job-uuid-here');

-- Hide a job
SELECT hide_job('job-uuid-here');

-- Update all expired jobs
SELECT update_expired_jobs();

-- Send expiration notifications
SELECT send_expiration_notifications();
```

Replace 'job-uuid-here' with an actual job ID from your database. 