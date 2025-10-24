-- Fix company_services table for proper upsert
-- Execute this in Supabase SQL Editor

-- First, let's see what's in the table
SELECT * FROM company_services;

-- Drop the existing unique constraint if it exists
ALTER TABLE company_services DROP CONSTRAINT IF EXISTS company_services_company_id_service_id_key;

-- Recreate it properly
ALTER TABLE company_services 
ADD CONSTRAINT company_services_company_id_service_id_key 
UNIQUE (company_id, service_id);

-- Verify the constraint
SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'company_services'::regclass;