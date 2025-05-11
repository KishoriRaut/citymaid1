-- Check RLS status with clear labels
SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN 'ENABLED'
        ELSE 'DISABLED'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
    'maid_profiles',
    'user_roles',
    'reviews',
    'payments',
    'notifications'
)
ORDER BY tablename;

-- Check existing policies with clear descriptions
SELECT 
    tablename,
    policyname,
    CASE 
        WHEN permissive THEN 'PERMISSIVE'
        ELSE 'RESTRICTIVE'
    END as policy_type,
    cmd as operation,
    CASE 
        WHEN cmd = 'SELECT' THEN 'READ'
        WHEN cmd = 'INSERT' THEN 'CREATE'
        WHEN cmd = 'UPDATE' THEN 'MODIFY'
        WHEN cmd = 'DELETE' THEN 'REMOVE'
        ELSE cmd
    END as operation_description,
    qual as access_condition
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname; 