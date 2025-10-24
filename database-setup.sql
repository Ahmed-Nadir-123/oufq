-- OFOQ System Database Setup
-- Execute this SQL in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles table (extends auth.users)
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('admin', 'company')),
  company_name TEXT,
  contact_person TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- Services table
CREATE TABLE services (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- Company Services table
CREATE TABLE company_services (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES user_profiles(id) NOT NULL,
  service_id UUID REFERENCES services(id) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  activated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()),
  expires_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(company_id, service_id)
);

-- Insert default services
INSERT INTO services (name, display_name, description) VALUES
('hr', 'الموارد البشرية', 'إدارة شؤون الموظفين والرواتب'),
('inventory', 'إدارة المخزون', 'تتبع المخزون والمنتجات'),
('sales', 'إدارة المبيعات', 'تسجيل وإدارة المبيعات'),
('invoices', 'إدارة الفواتير', 'إنشاء وإدارة الفواتير');

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_services ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Admin can view all profiles" ON user_profiles 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Users can view own profile" ON user_profiles 
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON user_profiles 
  FOR UPDATE USING (id = auth.uid());

-- RLS Policies for services
CREATE POLICY "Everyone can view services" ON services 
  FOR SELECT USING (true);

CREATE POLICY "Admin can manage services" ON services 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies for company_services
CREATE POLICY "Admin can manage company services" ON company_services 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Companies can view own services" ON company_services 
  FOR SELECT USING (company_id = auth.uid());

-- Create your admin user (replace email with your actual admin email)
-- First, create the user in Auth panel, then run this:
-- INSERT INTO user_profiles (id, role, company_name, contact_person)
-- SELECT id, 'admin', 'OFOQ Admin', 'System Administrator'
-- FROM auth.users 
-- WHERE email = 'YOUR_ADMIN_EMAIL@example.com';
