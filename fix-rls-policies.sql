-- Fix RLS Policies - Execute this in Supabase SQL Editor
-- This fixes the infinite recursion issue

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Admin can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admin can manage services" ON services;
DROP POLICY IF EXISTS "Admin can manage company services" ON company_services;

-- Create fixed policies for user_profiles
CREATE POLICY "Enable read for users based on user_id" ON user_profiles 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Enable update for users based on user_id" ON user_profiles 
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only" ON user_profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Enable delete for users based on user_id" ON user_profiles 
  FOR DELETE USING (auth.uid() = id);

-- Create simplified admin policies
CREATE POLICY "Admins can do everything on user_profiles" ON user_profiles 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'admin'
    )
  );

-- Fixed services policies
CREATE POLICY "Everyone can view services" ON services 
  FOR SELECT USING (true);

CREATE POLICY "Admins can manage services" ON services 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'admin'
    )
  );

-- Fixed company_services policies
CREATE POLICY "Admins can manage company services" ON company_services 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = auth.uid() AND up.role = 'admin'
    )
  );

CREATE POLICY "Companies can view own services" ON company_services 
  FOR SELECT USING (company_id = auth.uid());

-- Check if admin user exists and has proper role
SELECT u.email, up.role, up.company_name 
FROM auth.users u
LEFT JOIN user_profiles up ON u.id = up.id
WHERE u.email = 'admin@ofoq.com';
