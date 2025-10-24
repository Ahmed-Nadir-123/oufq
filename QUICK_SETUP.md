# ⚡ Quick Setup - Storage Bucket (5 minutes)

## The Problem
You got error: `ERROR: 42501: must be owner of table objects`

**This is NORMAL.** Supabase storage policies must be set via Dashboard, not SQL.

---

## Quick Fix (Choose ONE)

### 🟢 Option A: Manual Dashboard Setup (5 min, Easiest)

1. Go to Supabase → **Storage → Buckets**
2. Click **"+ New Bucket"**
3. Name: `id_images`
4. Check ✅ **"Make it public"**
5. Click **"Create bucket"**
6. Done! ✓

### 🟠 Option B: SQL + Manual Policies (5 min)

1. Go to **SQL Editor**
2. Run this:
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('id_images', 'id_images', true)
ON CONFLICT (id) DO NOTHING;

UPDATE storage.buckets SET public = true WHERE id = 'id_images';

SELECT * FROM storage.buckets WHERE id = 'id_images';
```

3. You should see one row: `id_images | id_images | true`
4. Then go to **Storage → Buckets → id_images → Policies**
5. Click **"Enable public access"** if you see that option
6. Done! ✓

---

## Verify Setup

### ✅ Check 1: Bucket Exists
- Go to **Storage → Buckets**
- You should see **"id_images"** in the list

### ✅ Check 2: Is Public
- Click **"id_images"** bucket
- Check that **visibility toggle is ON** (blue)
- Or look for a **"Public"** label

### ✅ Check 3: Has Policies
- Click **"id_images" → "Policies" tab**
- Should see at least **1 policy** listed
- (Usually auto-created when you enable public access)

### ✅ Check 4: File Size OK
- Bucket settings should allow **at least 5 MB**
- (Default is 100 MB, so should be fine)

---

## Test It Works

1. Open your app
2. Login as company user
3. Go to Management → **"إضافة موظف جديد"**
4. Fill form:
   - Business: select from dropdown
   - Name: any name
   - ID: any number
   - Salary: any number
5. **Select an image file**
6. Click **"رفع الصورة"** button
7. **You should see:**
   - Image preview appears
   - Message: **"✓ تم رفع الصورة بنجاح"**
   - (Green text, check mark)
8. Click **"حفظ"** button
9. Should redirect to management page ✓

---

## Common Issues

### Issue: "Still can't upload"
- Check: Browser console (F12 → Console tab)
- Look for error messages
- Share the exact error text

### Issue: "Bucket not showing"
- Go to **Storage**
- Do you see **"id_images"** bucket?
- If not, create it manually

### Issue: "Upload starts but stops"
- Check file size: must be **< 5 MB**
- Check file type: must be **image** (JPG, PNG, etc)
- Check internet connection

### Issue: "Get 413 or 400 error"
- File might be corrupted
- Try different image file
- Check file is actual image (not renamed text file)

---

## Files Involved

- **labor-form.html** - Image upload interface
- **create-storage-bucket.sql** - SQL to create bucket (RLS done via Dashboard)
- **STORAGE_SETUP_MANUAL.md** - Detailed setup guide

---

## Next Steps After Setup

1. ✅ Create bucket (this document)
2. ✅ Push code to GitHub (run: `git add . && git push`)
3. ✅ Test image upload in app
4. ✅ Deploy to Vercel (auto-deploys on GitHub push)

---

**Time to complete:** ~5 minutes
**Difficulty:** ⭐ Easy
**Status:** Ready to go! 🚀

