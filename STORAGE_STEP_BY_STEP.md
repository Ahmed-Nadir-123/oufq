# 🎯 Storage Setup - Step by Step

## Error You Got
```
ERROR: 42501: must be owner of table objects
```

**This is expected.** Supabase doesn't allow SQL modifications to storage policies. We must use the Dashboard instead.

---

## What You Need to Do

### Step 1: Create the Bucket

**Choose ONE method:**

#### Method 1A: Dashboard Only (Easiest)
```
1. Login to Supabase
2. Click "Storage"
3. Click "+ New Bucket"
4. Enter name: id_images
5. Check ✓ "Make it public"
6. Click "Create bucket"
```

#### Method 1B: SQL + Dashboard
```
1. Go to SQL Editor
2. Paste and run:
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('id_images', 'id_images', true)
   ON CONFLICT (id) DO NOTHING;
   
   UPDATE storage.buckets SET public = true WHERE id = 'id_images';
   
   SELECT * FROM storage.buckets WHERE id = 'id_images';

3. Should see one row showing: id_images | id_images | true
```

### Step 2: Verify Bucket is Public

```
1. Go to Storage section
2. You should see "id_images" in the list
3. Click on it
4. You should see a toggle or "Public" indicator that is ON
5. If not, click the toggle to enable public access
```

### Step 3: Check Policies (Important!)

```
1. Go to Storage → Buckets → id_images
2. Click "Policies" tab
3. You should see at least 1 policy listed
4. If you see "Enable public access" button, click it
5. If empty, the policies might be auto-created
```

If no policies show up:
```
1. Click "+ New Policy"
2. Look for templates like "Enable public access"
3. Or manually add:
   - "Public Read" (SELECT)
   - "Authenticated Upload" (INSERT)
   - "Authenticated Delete" (DELETE)
```

### Step 4: Test Upload

```
1. Open your app and login
2. Go to Management page
3. Click "إضافة موظف جديد" (Add new employee)
4. Fill the form
5. Select an image file
6. Click "رفع الصورة" (Upload image button)
7. Wait for message: "✓ تم رفع الصورة بنجاح"
8. Click "حفظ" (Save)
9. Should work! ✓
```

---

## Troubleshooting

### Q: I don't see the bucket
**A:** Create it manually via Dashboard:
- Storage → + New Bucket → Name: id_images → Check "Make it public" → Create

### Q: Upload button doesn't work
**A:** Check:
1. Is bucket public? (Check toggle is ON)
2. Image file is < 5 MB
3. Image file is real image (JPG, PNG, etc)
4. Browser console (F12) shows what error

### Q: Upload shows error in red
**A:** Share the exact error message from:
1. Browser console (F12 → Console tab)
2. Or the red error text on the page

### Q: Bucket shows but upload still fails
**A:** Add policies:
1. Go to Buckets → id_images → Policies
2. Click "+ New Policy"
3. Select "Enable public access" template
4. Try upload again

---

## What Should Happen

After setup:
- ✅ Bucket "id_images" exists in Storage
- ✅ Bucket visibility is PUBLIC (not private)
- ✅ At least 1 policy shows in Policies tab
- ✅ You can add/edit labor records with images
- ✅ Images upload successfully
- ✅ Green "✓ تم رفع الصورة بنجاح" message appears

---

## Reference Screenshots Locations

See these files for detailed guides:
- `QUICK_SETUP.md` - 5 minute version
- `IMAGE_UPLOAD_FIX.md` - Detailed troubleshooting
- `STORAGE_SETUP_MANUAL.md` - Step-by-step with all options

---

**Expected time:** 5-10 minutes
**Difficulty:** Very Easy ⭐

Once done, your image upload will work! 🎉
