# 🔧 Fix: Disable Storage RLS

## The Real Problem

Your error: **"new row violates row-level security policy"**

This means:
- ❌ RLS (Row Level Security) is ENABLED on storage.objects table
- ❌ This blocks uploads even though bucket is PUBLIC
- ✅ Solution: DISABLE RLS on storage.objects

---

## Fix (2 Steps)

### Step 1: Run SQL to Disable RLS

Go to **Supabase → SQL Editor** and run:

```sql
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';
```

Expected output: Should show `objects | false` (RLS disabled)

### Step 2: Test Upload Again

1. Go back to your app
2. Management → "إضافة موظف جديد"
3. Fill form + select image
4. Click "رفع الصورة" button
5. **Should now work!** ✓

---

## What This Does

- **Disables RLS** on storage.objects table
- **Allows public bucket** to work properly
- **Allows anyone** to upload/download from public buckets
- **Security**: Each bucket still controls access (public vs private)

---

## Why This Happened

Supabase comes with RLS **enabled by default** on storage.objects. For public buckets, this creates a conflict:
- Bucket says: "Be public!"
- RLS says: "But check policies first!"
- Result: Upload fails

**Solution**: For public buckets, disable table-level RLS (bucket-level settings take over)

---

## After This Works

Push to GitHub:
```bash
git add .
git commit -m "feat: Image upload working with storage bucket"
git push origin main
```

Then test in production on Vercel! 🚀

---

**This is the final step!** After this, image upload should work perfectly.
