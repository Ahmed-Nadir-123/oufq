# 🔧 Troubleshooting: RLS Permission Error

## Your Error
```
ERROR: 42501: must be owner of table objects
```

**This means:** You can't modify the storage.objects table directly via SQL. Supabase protects this.

---

## Solution: Use Dashboard Instead

### Method 1: Recreate Bucket (Easiest)

1. **Go to Storage → Buckets**
2. **Find "id_images" bucket**
3. **Click it → Settings/Delete**
4. **Delete the bucket**
5. **Create new bucket:**
   - Click "+ New Bucket"
   - Name: `id_images`
   - Check ✓ "Make it public"
   - Click "Create bucket"
6. **The new bucket should work!** ✓

### Method 2: Check Bucket Settings

If you want to keep the bucket:

1. **Storage → id_images bucket**
2. **Look for a toggle or setting that says:**
   - "Row Level Security"
   - "Enable/Disable RLS"
   - "Security settings"
3. **Try to DISABLE it if you find it**
4. **Save changes**

### Method 3: Try New Upload Function

The code has been updated with:
- ✅ Better file type handling
- ✅ Detailed console logs
- ✅ ContentType header
- ✅ Better error messages

**Test now:**
1. Go to Management → "إضافة موظف جديد"
2. Select image file
3. Click "رفع الصورة"
4. Open browser console (F12 → Console)
5. Share what you see in console

---

## Debugging Steps

### Step 1: Check Console Logs
When you click upload button, open browser console (F12) and look for:
- `Uploading file: labor_...`
- `File size: ...`
- `File type: image/...`

### Step 2: Share Console Error
Tell me exactly what appears in console when upload fails. Look for:
- `Upload error details: ...`
- `Error code: ...`

### Step 3: Verify Bucket

```
Go to Storage → Buckets
Look for "id_images"
Click on it
Check "Visibility" - should say "Public"
```

---

## If Delete + Recreate Bucket

The simplest solution might be:

1. **Delete** current "id_images" bucket
2. **Create fresh** bucket:
   - Name: `id_images`
   - Public: ✓ checked
   - Click "Create"
3. **This resets everything**
4. **Upload should work**

---

## Why This Approach?

- ❌ SQL can't modify storage.objects table (permission denied)
- ✅ Dashboard CAN create/manage buckets
- ✅ New bucket has fresh settings
- ✅ Simpler than troubleshooting RLS

---

## Next Test

After fixing bucket:

1. **Management → "إضافة موظف جديد"**
2. **Fill form**
3. **Select image**
4. **Click "رفع الصورة"**
5. **Should see:**
   - Image preview
   - Green "✓ تم رفع الصورة بنجاح"
6. **Click "حفظ"**
7. **Should save successfully** ✓

---

## Console Logs Help

Once you try upload, open console and copy-paste the logs. This will help me understand exactly what's happening.

**Try the updated code first**, then let me know what console shows! 🚀
