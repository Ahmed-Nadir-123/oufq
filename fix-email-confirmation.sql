-- Fix existing test company email confirmation
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email = 'test@gmail.com';

-- Also create a SQL function to auto-confirm emails (for future use)
CREATE OR REPLACE FUNCTION confirm_user_email(user_id UUID)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = user_id;
$$;

-- Verify the test user is now confirmed
SELECT email, email_confirmed_at, confirmed_at 
FROM auth.users 
WHERE email = 'test@gmail.com';
