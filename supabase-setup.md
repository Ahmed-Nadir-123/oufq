# إعداد Supabase للنظام أُفُق

## الخطوة 1: إنشاء مشروع Supabase

1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. انقر على "New Project"
3. أدخل تفاصيل المشروع:
   - **Name**: oufq-business-system
   - **Database Password**: (اختر كلمة مرور قوية)
   - **Region**: Middle East (UAE) أو أقرب منطقة

## الخطوة 2: تنفيذ SQL Schema

انسخ والصق الكود التالي في **SQL Editor** في لوحة تحكم Supabase:

```sql
-- إنشاء جدول المستخدمين الموسع
CREATE TABLE users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('admin', 'company')),
  company_name TEXT,
  contact_person TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إنشاء جدول الخدمات
CREATE TABLE services (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إدخال الخدمات الأساسية
INSERT INTO services (name, description) VALUES
  ('labor', 'إدارة الموارد البشرية والموظفين'),
  ('inventory', 'إدارة المخزون والمنتجات'),
  ('sales', 'إدارة المبيعات والعملاء'),
  ('invoices', 'إدارة الفواتير والمدفوعات');

-- إنشاء جدول خدمات الشركات
CREATE TABLE company_services (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES users NOT NULL,
  service_id UUID REFERENCES services NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  activated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()),
  expires_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(company_id, service_id)
);

-- إنشاء جدول العمال (للموارد البشرية)
CREATE TABLE labor_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES users NOT NULL,
  name TEXT NOT NULL,
  position TEXT,
  nationality TEXT,
  id_number TEXT,
  salary DECIMAL(10,2),
  join_date DATE,
  contact TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إنشاء جدول المخزون
CREATE TABLE inventory_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES users NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT,
  quantity INTEGER DEFAULT 0,
  cost_price DECIMAL(10,2),
  selling_price DECIMAL(10,2),
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إنشاء جدول المبيعات
CREATE TABLE sales_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES users NOT NULL,
  customer_name TEXT NOT NULL,
  phone TEXT,
  sale_date DATE NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT DEFAULT 'cash',
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إنشاء جدول عناصر المبيعات
CREATE TABLE sale_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sale_id UUID REFERENCES sales_records NOT NULL,
  inventory_id UUID REFERENCES inventory_items NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- إنشاء جدول الفواتير
CREATE TABLE invoices (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  company_id UUID REFERENCES users NOT NULL,
  invoice_number TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  issue_date DATE NOT NULL,
  due_date DATE,
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- تفعيل Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE labor_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان للمدراء
CREATE POLICY admin_all_access ON users 
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سياسات الأمان للشركات
CREATE POLICY company_read_own ON users 
  FOR SELECT TO authenticated 
  USING (auth.uid() = id OR EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  ));

CREATE POLICY company_update_own ON users 
  FOR UPDATE TO authenticated 
  USING (auth.uid() = id);

-- سياسات خدمات الشركات
CREATE POLICY admin_company_services ON company_services 
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY company_view_services ON company_services 
  FOR SELECT TO authenticated 
  USING (
    company_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سياسات العمال
CREATE POLICY company_labor_access ON labor_records 
  FOR ALL TO authenticated 
  USING (
    company_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سياسات المخزون
CREATE POLICY company_inventory_access ON inventory_items 
  FOR ALL TO authenticated 
  USING (
    company_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سياسات المبيعات
CREATE POLICY company_sales_access ON sales_records 
  FOR ALL TO authenticated 
  USING (
    company_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY company_sale_items_access ON sale_items 
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM sales_records 
      WHERE id = sale_items.sale_id 
      AND (company_id = auth.uid() OR 
           EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'))
    )
  );

-- سياسات الفواتير
CREATE POLICY company_invoices_access ON invoices 
  FOR ALL TO authenticated 
  USING (
    company_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- سياسة مشاهدة الخدمات
CREATE POLICY services_read_all ON services 
  FOR SELECT TO authenticated 
  USING (true);

-- إنشاء دالة لتحديث التوقيت
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('UTC'::TEXT, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إضافة المحفزات لتحديث التوقيت
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_labor_updated_at BEFORE UPDATE ON labor_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## الخطوة 3: إعداد Authentication

في إعدادات **Authentication** في Supabase:

1. اذهب إلى **Authentication > Settings**
2. تأكد من أن **Enable email confirmations** غير مفعل للاختبار
3. في **URL Configuration**:
   - Site URL: `http://localhost:3000` (للتطوير) أو `https://your-domain.com`

## الخطوة 4: الحصول على مفاتيح API

من **Settings > API**:

- انسخ `Project URL`
- انسخ `anon public key`

هذه المفاتيح ستحتاجها في الخطوات التالية.

## الخطوة 5: إنشاء مستخدم مدير افتراضي

لإنشاء حساب مدير افتراضي، نفذ الكود التالي في **SQL Editor**:

```sql
-- إدخال مستخدم مدير افتراضي (قم بتغيير البيانات)
-- ملاحظة: يجب إنشاء المستخدم في Authentication أولاً
```

## ملاحظات مهمة:

1. **أمان البيانات**: Row Level Security مفعل لحماية بيانات كل شركة
2. **الأدوار**: 
   - `admin`: يمكنه الوصول لكل شيء
   - `company`: يمكنه فقط الوصول لبياناته
3. **الخدمات**: يمكن للمدير تفعيل/إلغاء تفعيل الخدمات لكل شركة

## الخطوات التالية:

1. إنشاء ملف التكوين لـ Supabase
2. إعادة كتابة صفحات HTML لتستخدم Supabase
3. إنشاء لوحة تحكم المدير
4. اختبار النظام
