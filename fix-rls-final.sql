-- Complete RLS Fix - Execute this in Supabase SQL Editor
-- This completely removes the problematic policies and creates simple ones

-- Step 1: Drop ALL policies and disable RLS temporarily
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Admin can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable read for users based on user_id" ON user_profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON user_profiles;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON user_profiles;
DROP POLICY IF EXISTS "Admins can do everything on user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow authenticated users to read their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow authenticated users to update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow authenticated users to insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow admins to read all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow admins to manage all profiles" ON user_profiles;

-- Step 2: Make sure admin user exists with proper profile
DELETE FROM user_profiles WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@ofoq.com'
);

INSERT INTO user_profiles (id, role, company_name, contact_person)
SELECT id, 'admin', 'OFOQ Admin', 'System Administrator'
FROM auth.users 
WHERE email = 'admin@ofoq.com';

-- Step 3: Create very simple policies (no recursion)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "users_select_own" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "users_update_own" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "users_insert_own" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Special policy: Allow reading any profile if the current user is admin
-- This uses a direct auth.uid() check instead of querying user_profiles
CREATE POLICY "admin_select_all" ON user_profiles
    FOR SELECT USING (
        auth.uid() = 'a06323bc-bd54-4134-bc7d-c280d58507e4'::uuid  -- Your admin user ID
        OR auth.uid() = id
    );

-- Allow admin to do everything (using direct user ID to avoid recursion)
CREATE POLICY "admin_all_operations" ON user_profiles
    FOR ALL USING (
        auth.uid() = 'a06323bc-bd54-4134-bc7d-c280d58507e4'::uuid  -- Your admin user ID
    );

-- Step 4: Verify the setup
SELECT 'Admin user profile:' as info;
SELECT u.id, u.email, up.role, up.company_name 
FROM auth.users u
JOIN user_profiles up ON u.id = up.id
WHERE u.email = 'admin@ofoq.com';

SELECT 'All policies on user_profiles:' as info;
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'user_profiles';
