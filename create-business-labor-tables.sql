-- Create Business Records Table
CREATE TABLE IF NOT EXISTS business_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- Create Labor Records Table
CREATE TABLE IF NOT EXISTS labor_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company_id UUID REFERENCES user_profiles(id) NOT NULL,
    business_id UUID REFERENCES business_records(id) NOT NULL,
    name TEXT NOT NULL,
    national_id TEXT NOT NULL UNIQUE,
    salary DECIMAL(10, 3) NOT NULL,
    id_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('UTC'::TEXT, NOW()) NOT NULL
);

-- Create indices for better query performance
CREATE INDEX idx_business_records_company_id ON business_records(company_id);
CREATE INDEX idx_labor_records_company_id ON labor_records(company_id);
CREATE INDEX idx_labor_records_business_id ON labor_records(business_id);

-- Add RLS Policies for business_records
ALTER TABLE business_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own business records" ON business_records
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own business records" ON business_records
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY "Companies can update own business records" ON business_records
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY "Companies can delete own business records" ON business_records
    FOR DELETE USING (company_id = auth.uid());

-- Add RLS Policies for labor_records
ALTER TABLE labor_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can view own labor records" ON labor_records
    FOR SELECT USING (company_id = auth.uid());

CREATE POLICY "Companies can insert own labor records" ON labor_records
    FOR INSERT WITH CHECK (company_id = auth.uid());

CREATE POLICY "Companies can update own labor records" ON labor_records
    FOR UPDATE USING (company_id = auth.uid());

CREATE POLICY "Companies can delete own labor records" ON labor_records
    FOR DELETE USING (company_id = auth.uid());

-- Verify tables were created
SELECT 'Tables created successfully!' as status;
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('business_records', 'labor_records');