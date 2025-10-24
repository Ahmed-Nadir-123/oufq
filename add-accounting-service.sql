-- ======================================
-- Add Accounting Service to Services Table
-- ======================================
-- Run this in Supabase SQL Editor to add the accounting service
-- This allows admins to activate it for companies

-- Insert accounting service if it doesn't exist (WITH display_name)
INSERT INTO services (name, display_name, description)
VALUES ('accounting', 'المحاسبة', 'خدمة المحاسبة - إدارة المخزون، المبيعات، والفواتير')
ON CONFLICT (name) DO NOTHING;

-- To activate accounting service for a specific company, run:
-- (Replace 'COMPANY_USER_ID' with the actual company user ID)
-- 
-- INSERT INTO company_services (company_id, service_id, is_active)
-- SELECT 
--     'COMPANY_USER_ID'::uuid,
--     id,
--     true
-- FROM services
-- WHERE name = 'accounting'
-- ON CONFLICT (company_id, service_id) 
-- DO UPDATE SET is_active = true;

-- Verify the service was added
SELECT * FROM services WHERE name = 'accounting';
