-- IMPORTANT: Configure Storage Policies in Supabase Dashboard
-- This file documents what needs to be done through the UI

/*
Since we cannot modify storage.objects policies via SQL directly,
we need to configure the bucket policies through the Supabase Dashboard.

FOLLOW THESE STEPS IN SUPABASE:

1. Go to Storage → Buckets
2. Click on the "id_images" bucket
3. Click "Policies" tab
4. Make sure these policies exist:

   Policy 1 - Allow Public READ:
   - Name: "Public read"
   - Operation: SELECT (Read)
   - For: Authenticated and Anonymous users
   - Condition: None (or bucket_id = 'id_images')

   Policy 2 - Allow Authenticated UPLOAD:
   - Name: "Authenticated can upload"
   - Operation: INSERT (Create)
   - For: Authenticated users only
   - Condition: bucket_id = 'id_images'

   Policy 3 - Allow Authenticated DELETE:
   - Name: "Authenticated can delete"
   - Operation: DELETE (Delete)
   - For: Authenticated users only
   - Condition: bucket_id = 'id_images'

5. If these policies don't exist, create them
6. If they do exist, keep them as is

VERIFICATION:
- Bucket should appear in Storage section
- Visibility should be "Public"
- All files should be downloadable with public URLs
*/

-- This SQL just ensures the bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('id_images', 'id_images', true)
ON CONFLICT (id) DO NOTHING;

-- Make sure bucket is set to public
UPDATE storage.buckets SET public = true WHERE id = 'id_images';

-- Verify
SELECT id, name, public FROM storage.buckets WHERE id = 'id_images';
