# 🚀 دليل التشغيل السريع - تفعيل نظام المحاسبة

## ⚡ المشكلة
لا يظهر زر "المحاسبة" في لوحة التحكم (dashboard.html)

## ✅ الحل
تفعيل خدمة المحاسبة في قاعدة البيانات

---

## 📋 الخطوات (5 دقائق)

### الخطوة 1️⃣: افتح Supabase

1. اذهب إلى: https://supabase.com/dashboard
2. سجّل الدخول
3. اختر مشروعك: **wlnukwaecpkhxomfgxni**

---

### الخطوة 2️⃣: افتح SQL Editor

1. من القائمة اليسرى، انقر **SQL Editor**
2. انقر **New Query** (زر + أخضر)

---

### الخطوة 3️⃣: انسخ والصق هذا الكود

```sql
-- ======================================
-- تفعيل خدمة المحاسبة
-- ======================================

-- 1. إضافة خدمة المحاسبة إلى جدول الخدمات
INSERT INTO services (name, display_name, description)
VALUES ('accounting', 'المحاسبة', 'خدمة المحاسبة - إدارة المخزون، المبيعات، والفواتير')
ON CONFLICT (name) DO NOTHING;

-- 2. تفعيل الخدمة لجميع الشركات
INSERT INTO company_services (company_id, service_id, is_active)
SELECT 
    up.id,
    s.id,
    true
FROM user_profiles up
CROSS JOIN services s
WHERE up.role = 'company' AND s.name = 'accounting'
ON CONFLICT (company_id, service_id) 
DO UPDATE SET is_active = true;

-- 3. التحقق من التفعيل
SELECT 
    up.company_name as 'اسم الشركة',
    s.display_name as 'الخدمة',
    cs.is_active as 'مفعلة؟'
FROM company_services cs
JOIN user_profiles up ON cs.company_id = up.id
JOIN services s ON cs.service_id = s.id
WHERE s.name = 'accounting';
```

---

### الخطوة 4️⃣: شغّل الكود

1. انقر زر **RUN** (أو اضغط Ctrl+Enter)
2. انتظر ثواني
3. سترى رسالة نجاح ✅

---

### الخطوة 5️⃣: حدّث لوحة التحكم

1. ارجع لمتصفحك
2. افتح `dashboard.html`
3. **حدّث الصفحة** (F5 أو Ctrl+R)
4. **يجب أن ترى بطاقة "المحاسبة" الآن!** 🎉

---

## 🎯 النتيجة المتوقعة

بعد تنفيذ الخطوات، ستظهر بطاقة جديدة في لوحة التحكم:

```
┌─────────────────────────────┐
│  📊 المحاسبة                │
│                             │
│  إدارة المخزون، المبيعات،  │
│  والفواتير                 │
│                             │
│     [دخول للخدمة]           │
└─────────────────────────────┘
```

عند النقر عليها → تذهب لـ `accounting.html` ✨

---

## 🔗 روابط مباشرة (بديلة)

إذا أردت الوصول المباشر بدون لوحة التحكم:

### 1. لوحة المحاسبة:
```
file:///c:/Users/ZoomStore/Desktop/oufq/accounting.html
```

### 2. إدارة المخزون:
```
file:///c:/Users/ZoomStore/Desktop/oufq/inventory.html
```
**← هنا تجد زر QR الأخضر 🟢**

### 3. نقطة البيع:
```
file:///c:/Users/ZoomStore/Desktop/oufq/pos-scanner.html
```

### 4. المبيعات:
```
file:///c:/Users/ZoomStore/Desktop/oufq/sales.html
```

### 5. الفواتير:
```
file:///c:/Users/ZoomStore/Desktop/oufq/invoices.html
```

---

## 🆘 حل المشاكل

### ❌ المشكلة: "البطاقة لا تظهر بعد تشغيل SQL"

**الحل:**
1. تأكد من نجاح الاستعلام (رسالة خضراء في Supabase)
2. حدّث الصفحة بقوة: **Ctrl + Shift + R**
3. امسح الكاش: **Ctrl + Shift + Delete**
4. افتح Console (F12) وشاهد الأخطاء

---

### ❌ المشكلة: "خطأ في SQL"

**الحل:**
تأكد من:
- ✅ جدول `services` موجود
- ✅ جدول `company_services` موجود
- ✅ جدول `user_profiles` موجود
- ✅ نفذت `create-accounting-tables.sql` مسبقاً

---

### ❌ المشكلة: "لا يوجد شركات"

**الحل:**
إذا لم تُنشئ حساب شركة بعد:

1. اذهب لـ `login.html`
2. سجّل حساب جديد
3. اختر نوع: **شركة**
4. أكمل البيانات
5. عد لـ dashboard

---

## 📊 التحقق من التفعيل

شغّل هذا الاستعلام للتأكد:

```sql
-- هل الخدمة موجودة؟
SELECT * FROM services WHERE name = 'accounting';

-- هل مفعّلة للشركات؟
SELECT 
    up.company_name,
    cs.is_active
FROM company_services cs
JOIN user_profiles up ON cs.company_id = up.id
JOIN services s ON cs.service_id = s.id
WHERE s.name = 'accounting';
```

---

## 🎯 الخلاصة

```
┌─────────────────────────────────────┐
│  1. شغّل SQL في Supabase ✅        │
│     ↓                               │
│  2. حدّث dashboard.html ✅          │
│     ↓                               │
│  3. بطاقة المحاسبة تظهر ✅          │
│     ↓                               │
│  4. انقر عليها → accounting.html   │
│     ↓                               │
│  5. استمتع بالنظام! 🎉             │
└─────────────────────────────────────┘
```

---

## 🔄 سير العمل الكامل

### بعد التفعيل:

```
dashboard.html (لوحة التحكم)
    ↓
    ↓ (انقر بطاقة المحاسبة)
    ↓
accounting.html (لوحة المحاسبة)
    ↓
    ├─→ inventory.html (المخزون) → زر QR 🟢
    ├─→ sales.html (المبيعات)
    ├─→ pos-scanner.html (نقطة البيع)
    └─→ invoices.html (الفواتير)
```

---

## ⏱️ الوقت المتوقع

- تشغيل SQL: **1 دقيقة**
- التحقق: **1 دقيقة**
- تحديث الصفحة: **10 ثواني**
- **المجموع: 2-3 دقائق**

---

## ✅ قائمة تحقق سريعة

- [ ] فتحت Supabase Dashboard
- [ ] ذهبت لـ SQL Editor
- [ ] نسخت ولصقت الكود
- [ ] شغّلت الاستعلام (RUN)
- [ ] رأيت رسالة نجاح
- [ ] حدثت dashboard.html
- [ ] رأيت بطاقة "المحاسبة"
- [ ] نقرت البطاقة
- [ ] فتح accounting.html
- [ ] جربت فتح inventory.html
- [ ] رأيت زر QR الأخضر 🟢

---

## 🎊 بعد التفعيل الناجح

يمكنك الآن:

✅ إدارة المخزون  
✅ إضافة منتجات  
✅ إنشاء رموز QR تلقائياً  
✅ البيع عبر نقطة البيع  
✅ إصدار الفواتير  
✅ متابعة المبيعات  

**كل شيء جاهز!** 🚀

---

**تم التحديث:** 24 أكتوبر 2025  
**الحالة:** ✅ دليل كامل وجاهز
