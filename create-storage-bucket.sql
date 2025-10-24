-- Create Storage Bucket for ID Images
-- Run this in Supabase SQL Editor

-- First, check if bucket exists and create if not
INSERT INTO storage.buckets (id, name, public)
VALUES ('id_images', 'id_images', true)
ON CONFLICT (id) DO NOTHING;

-- Update bucket to ensure it's public
UPDATE storage.buckets SET public = true WHERE id = 'id_images';

-- Verify bucket exists and is public
SELECT id, name, public FROM storage.buckets WHERE id = 'id_images';
