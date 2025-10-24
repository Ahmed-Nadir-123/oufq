-- Auto-confirm all company users
-- Execute this in Supabase SQL Editor

-- Confirm the specific test user
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email = 'test@gmail.com' 
AND email_confirmed_at IS NULL;

-- Optional: Auto-confirm all company users created by admin
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE id IN (
    SELECT id FROM user_profiles WHERE role = 'company'
) 
AND email_confirmed_at IS NULL;

-- Verify the fix
SELECT email, email_confirmed_at, created_at 
FROM auth.users 
WHERE email = 'test@gmail.com';
