-- ======================================
-- Accounting Module Tables
-- ======================================
-- This creates tables for inventory, sales, and invoices
-- Run this in Supabase SQL Editor

-- ======================================
-- 1. INVENTORY/WAREHOUSE TABLE (إدارة المخزون)
-- ======================================
CREATE TABLE IF NOT EXISTS inventory (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    product_code TEXT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    purchase_price DECIMAL(10, 3) NOT NULL,
    selling_price DECIMAL(10, 3) NOT NULL,
    total_quantity INTEGER NOT NULL DEFAULT 0,
    min_quantity_alert INTEGER NOT NULL DEFAULT 10,
    is_low_stock BOOLEAN GENERATED ALWAYS AS (total_quantity <= min_quantity_alert) STORED,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- 2. SALES TRANSACTIONS TABLE (المبيعات)
-- ======================================
CREATE TABLE IF NOT EXISTS sales (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    sale_number TEXT NOT NULL UNIQUE,
    total_amount DECIMAL(10, 3) NOT NULL,
    payment_status TEXT CHECK (payment_status IN ('paid', 'pending')) DEFAULT 'paid',
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- 3. SALE ITEMS TABLE (تفاصيل المبيعات)
-- ======================================
CREATE TABLE IF NOT EXISTS sale_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE NOT NULL,
    product_code TEXT NOT NULL,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 3) NOT NULL,
    subtotal DECIMAL(10, 3) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- 4. INVOICES TABLE (الفواتير)
-- ======================================
CREATE TABLE IF NOT EXISTS invoices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    invoice_number TEXT NOT NULL UNIQUE,
    invoice_type TEXT CHECK (invoice_type IN ('sale', 'purchase')) NOT NULL,
    total_amount DECIMAL(10, 3) NOT NULL,
    payment_status TEXT CHECK (payment_status IN ('paid', 'pending', 'cancelled')) DEFAULT 'pending',
    sale_id UUID REFERENCES sales(id) ON DELETE SET NULL,
    invoice_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- 5. INVOICE ITEMS TABLE (تفاصيل الفواتير)
-- ======================================
CREATE TABLE IF NOT EXISTS invoice_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE NOT NULL,
    product_code TEXT NOT NULL,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 3) NOT NULL,
    subtotal DECIMAL(10, 3) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- 6. INVENTORY TRANSACTIONS LOG (سجل حركة المخزون)
-- ======================================
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    product_code TEXT NOT NULL,
    transaction_type TEXT CHECK (transaction_type IN ('purchase', 'sale', 'adjustment', 'refill')) NOT NULL,
    quantity INTEGER NOT NULL,
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- ======================================
-- INDICES FOR PERFORMANCE
-- ======================================
CREATE INDEX idx_inventory_company_id ON inventory(company_id);
CREATE INDEX idx_inventory_product_code ON inventory(product_code);
CREATE INDEX idx_inventory_low_stock ON inventory(is_low_stock) WHERE is_low_stock = true;

CREATE INDEX idx_sales_company_id ON sales(company_id);
CREATE INDEX idx_sales_sale_number ON sales(sale_number);
CREATE INDEX idx_sales_date ON sales(sale_date);

CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product_code ON sale_items(product_code);

CREATE INDEX idx_invoices_company_id ON invoices(company_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_type ON invoices(invoice_type);
CREATE INDEX idx_invoices_sale_id ON invoices(sale_id);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);

CREATE INDEX idx_inventory_transactions_company_id ON inventory_transactions(company_id);
CREATE INDEX idx_inventory_transactions_product_code ON inventory_transactions(product_code);

-- ======================================
-- RLS POLICIES - INVENTORY
-- ======================================
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own inventory" ON inventory
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own inventory" ON inventory
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY "Companies can update own inventory" ON inventory
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY "Companies can delete own inventory" ON inventory
    FOR DELETE USING (company_id = auth.uid());

-- ======================================
-- RLS POLICIES - SALES
-- ======================================
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own sales" ON sales
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own sales" ON sales
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY "Companies can update own sales" ON sales
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY "Companies can delete own sales" ON sales
    FOR DELETE USING (company_id = auth.uid());

-- ======================================
-- RLS POLICIES - SALE ITEMS
-- ======================================
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own sale items" ON sale_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM sales 
            WHERE sales.id = sale_items.sale_id 
            AND sales.company_id = auth.uid()
        )
    );

CREATE POLICY "Companies can insert own sale items" ON sale_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM sales 
            WHERE sales.id = sale_items.sale_id 
            AND sales.company_id = auth.uid()
        )
    );

CREATE POLICY "Companies can delete own sale items" ON sale_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM sales 
            WHERE sales.id = sale_items.sale_id 
            AND sales.company_id = auth.uid()
        )
    );

-- ======================================
-- RLS POLICIES - INVOICES
-- ======================================
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own invoices" ON invoices
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own invoices" ON invoices
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY "Companies can update own invoices" ON invoices
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY "Companies can delete own invoices" ON invoices
    FOR DELETE USING (company_id = auth.uid());

-- ======================================
-- RLS POLICIES - INVOICE ITEMS
-- ======================================
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own invoice items" ON invoice_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.company_id = auth.uid()
        )
    );

CREATE POLICY "Companies can insert own invoice items" ON invoice_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.company_id = auth.uid()
        )
    );

CREATE POLICY "Companies can delete own invoice items" ON invoice_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM invoices 
            WHERE invoices.id = invoice_items.invoice_id 
            AND invoices.company_id = auth.uid()
        )
    );

-- ======================================
-- RLS POLICIES - INVENTORY TRANSACTIONS
-- ======================================
ALTER TABLE inventory_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own inventory transactions" ON inventory_transactions
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own inventory transactions" ON inventory_transactions
    FOR INSERT WITH CHECK (company_id = auth.uid());

-- ======================================
-- FUNCTIONS - Auto-generate invoice on sale
-- ======================================
CREATE OR REPLACE FUNCTION create_invoice_from_sale()
RETURNS TRIGGER AS $$
DECLARE
    v_invoice_number TEXT;
BEGIN
    -- Generate invoice number
    v_invoice_number := 'INV-SALE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || SUBSTRING(NEW.id::TEXT, 1, 8);
    
    -- Create invoice
    INSERT INTO invoices (
        company_id,
        invoice_number,
        invoice_type,
        total_amount,
        payment_status,
        sale_id,
        invoice_date
    ) VALUES (
        NEW.company_id,
        v_invoice_number,
        'sale',
        NEW.total_amount,
        NEW.payment_status,
        NEW.id,
        NEW.sale_date
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-create invoice on sale
DROP TRIGGER IF EXISTS trigger_create_invoice_from_sale ON sales;
CREATE TRIGGER trigger_create_invoice_from_sale
    AFTER INSERT ON sales
    FOR EACH ROW
    EXECUTE FUNCTION create_invoice_from_sale();

-- ======================================
-- FUNCTIONS - Copy sale items to invoice items
-- ======================================
CREATE OR REPLACE FUNCTION copy_sale_items_to_invoice()
RETURNS TRIGGER AS $$
DECLARE
    v_invoice_id UUID;
BEGIN
    -- Get the invoice ID for this sale
    SELECT id INTO v_invoice_id
    FROM invoices
    WHERE sale_id = NEW.sale_id
    LIMIT 1;
    
    -- Copy sale item to invoice items
    IF v_invoice_id IS NOT NULL THEN
        INSERT INTO invoice_items (
            invoice_id,
            product_code,
            product_name,
            quantity,
            unit_price,
            subtotal
        ) VALUES (
            v_invoice_id,
            NEW.product_code,
            NEW.product_name,
            NEW.quantity,
            NEW.unit_price,
            NEW.subtotal
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to copy sale items to invoice items
DROP TRIGGER IF EXISTS trigger_copy_sale_items_to_invoice ON sale_items;
CREATE TRIGGER trigger_copy_sale_items_to_invoice
    AFTER INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION copy_sale_items_to_invoice();

-- ======================================
-- VERIFY TABLES CREATED
-- ======================================
SELECT 'Tables created successfully!' as status;
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('inventory', 'sales', 'sale_items', 'invoices', 'invoice_items', 'inventory_transactions')
ORDER BY tablename;
