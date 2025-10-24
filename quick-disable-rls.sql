-- Quick test: Disable RLS temporarily for user_profiles
-- Execute this in Supabase SQL Editor for immediate testing

ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Ensure admin profile exists
INSERT INTO user_profiles (id, role, company_name, contact_person)
SELECT id, 'admin', 'OFOQ Admin', 'System Administrator'
FROM auth.users 
WHERE email = 'admin@ofoq.com'
AND id NOT IN (SELECT id FROM user_profiles);

-- Verify admin exists
SELECT u.id, u.email, up.role, up.company_name 
FROM auth.users u
JOIN user_profiles up ON u.id = up.id
WHERE u.email = 'admin@ofoq.com';
