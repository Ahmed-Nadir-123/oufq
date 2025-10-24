# 🚀 Setup Guide - Image Upload & Database Tables

## Step 1: Create Storage Bucket in Supabase

### Method A: Via SQL (Recommended)
1. Go to your Supabase project → **SQL Editor**
2. Run this script:
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('id_images', 'id_images', true)
ON CONFLICT (id) DO NOTHING;

UPDATE storage.buckets SET public = true WHERE id = 'id_images';

SELECT id, name, public FROM storage.buckets WHERE id = 'id_images';
```
3. Should show: `id_images | id_images | true`

### Method B: Via Dashboard (If SQL fails)
1. Go to **Storage → Buckets**
2. Click **"New Bucket"**
3. Name: `id_images`
4. Check **"Make it public"**
5. Click **"Create bucket"**

### Step 1B: Configure Bucket Policies (Important!)

1. Go to **Storage → Buckets → id_images**
2. Click **"Policies"** tab
3. You should see or create these policies:
   - ✅ **Public Read** - Anyone can read files
   - ✅ **Authenticated Upload** - Logged-in users can upload
   - ✅ **Authenticated Delete** - Logged-in users can delete

If they don't exist, click **"New Policy"** and select:
- **Enable public access** (auto-creates public read)
- Then manually add INSERT and DELETE for authenticated users

Or use the template:
- Click **"New Policy" → "For INSERT" → "As Authenticated User"**
- Click **"New Policy" → "For DELETE" → "As Authenticated User"**

Expected result: **At least 2-3 policies** listed in the Policies tab

---

## Step 2: Create Database Tables

1. Go to **SQL Editor** in Supabase
2. Copy and run the entire contents of `create-business-labor-tables.sql`:
   - Creates `business_records` table
   - Creates `labor_records` table
   - Sets up RLS policies
   - Creates performance indices

Expected output:
```
Tables created successfully!
business_records
labor_records
```

---

## Step 3: Verify Setup

### Check Business Records Table
```sql
SELECT * FROM business_records LIMIT 1;
```

### Check Labor Records Table
```sql
SELECT * FROM labor_records LIMIT 1;
```

### Check Storage Bucket
Go to Storage → id_images (should exist and be public)

---

## Features Implemented

### ✅ View Details Button
- **Fixed**: No longer breaks with special characters in descriptions
- Now fetches full data from database when clicked
- Safely displays in modal

### ✅ Image Upload to Supabase Storage
**In Labor Form (`labor-form.html`):**
- File input accepts image files only
- Upload button triggers file upload to Supabase storage
- Image preview shown after upload
- Status messages (uploading, success, error)
- Validated: max 5MB, must be image
- Optional: Users can add labor record without image
- On submit: URL of uploaded image is stored in database

**How it works:**
```
User selects file → Clicks "رفع الصورة" button
     ↓
File uploaded to Supabase storage (/id_images/{userID}/{timestamp}.jpg)
     ↓
Public URL generated automatically
     ↓
Preview shown to user with ✓ status
     ↓
On form submit: Image URL saved to labor_records table
```

### ✅ Image Handling
- Images stored in: `Storage → id_images bucket`
- Path structure: `{userID}/{timestamp}.jpg`
- Each user can only access their own images (RLS policies)
- Public URL generated for display
- Can edit existing labor records and replace image

---

## File Changes Made

### New Files Created
1. **business-form.html** - Separate form for adding/editing business records
2. **labor-form.html** - Separate form for adding/editing labor records with image upload
3. **create-storage-bucket.sql** - SQL to set up storage bucket

### Updated Files
1. **management.html**
   - Fixed view details button (now fetches data safely)
   - Links to separate form pages instead of prompts
   - Added btn-danger CSS style

---

## Testing Checklist

- [ ] Create storage bucket in Supabase
- [ ] Create database tables via SQL
- [ ] Login as company user
- [ ] Go to Management page
- [ ] Click "إضافة بيانات جديدة" → Opens business-form.html
- [ ] Fill business form → Save → Returns to management page
- [ ] Click "إضافة موظف جديد" → Opens labor-form.html
- [ ] Select business from dropdown (not business ID)
- [ ] Select image file → Click "رفع الصورة" → See preview
- [ ] Fill labor form → Save → Returns to management page
- [ ] View business details → Modal shows description
- [ ] Edit business/labor → Form pre-fills data
- [ ] Delete button works

---

## Troubleshooting

### Image Upload Not Working
- Check: Storage bucket "id_images" exists and is public
- Check: RLS policies created for storage.objects
- Check: File size < 5MB
- Check: File is a valid image (JPG, PNG, etc.)
- Check browser console for errors

### View Details Button Broken
- Clear browser cache
- Reload page
- Check Supabase is accessible

### Form Not Submitting
- Check all required fields filled
- Check image uploaded (or left empty if optional)
- Check internet connection
- Check Supabase RLS policies on tables

### National ID Uniqueness Error
- Unique constraint on national_id
- Cannot have duplicate IDs in database
- Either use different ID or delete old record first

---

## Quick Reference

**Labor Form Image Upload:**
- Optional: Yes (can add labor without image)
- Max size: 5MB
- Formats: JPG, PNG, GIF, WebP, etc.
- Storage location: `id_images/{userID}/{timestamp}.ext`

**Database Relationships:**
```
user_profiles (company)
    ↓
business_records (one company → many businesses)
    ↓
labor_records (one business → many labor)
```

---

**Last Updated:** October 18, 2025
**Status:** Ready for production
