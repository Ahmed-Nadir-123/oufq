# 🎯 Management Page - Complete Implementation Guide

## ✅ Features Implemented

### 1. **Service Toggle System**
- Service control panel at the top
- Toggle between Business Management and Labor Management services
- Real-time activation/deactivation with database sync

### 2. **Business Management Section**
- **Add New Business**: Click "إضافة بيانات جديدة" button
- **View Details**: See business description in modal popup
- **Edit**: Modify business name and description
- **Delete**: Remove business record
- **Fields**:
  - Business Name
  - Start Date
  - Status (Active/Inactive)
  - Description (viewed in modal)

### 3. **Labor Management Section**
- **Add New Labor**: Click "إضافة موظف جديد" button
- **Filter by Business**: Dropdown to filter employees by their assigned business
- **Edit**: Update employee name and salary
- **Delete**: Remove employee record
- **Fields**:
  - Employee Name
  - National ID (unique)
  - Salary
  - Assigned Business
  - ID Card Image

### 4. **Business-Labor Relationship**
- Each labor record is linked to exactly ONE business
- Filter employees by business using dropdown
- Foreign key constraint ensures data integrity

## 📋 Setup Instructions

### Step 1: Create Database Tables
Execute this SQL in **Supabase SQL Editor**:

```bash
-- Copy entire content of create-business-labor-tables.sql and run it
```

### Step 2: Deploy Latest Code
```powershell
git add .
git commit -m "feat: Add comprehensive business and labor management to HR module"
git push origin main
```

### Step 3: Test the Features
1. Go to management page
2. Toggle services on/off
3. Add a business
4. Add an employee for that business
5. Filter employees by business
6. Test edit/delete functions

## 🗄️ Database Schema

### business_records Table
```sql
- id (UUID) - Primary Key
- company_id (UUID) - FK to user_profiles
- name (TEXT) - Business/Project name
- description (TEXT) - Business details
- start_date (DATE) - Project start date
- status (TEXT) - 'active' or 'inactive'
- created_at, updated_at - Timestamps
```

### labor_records Table
```sql
- id (UUID) - Primary Key
- company_id (UUID) - FK to user_profiles
- business_id (UUID) - FK to business_records (ONE-TO-ONE relationship)
- name (TEXT) - Employee name
- national_id (TEXT) - Unique national ID
- salary (DECIMAL) - Employee salary in OMR
- id_image_url (TEXT) - URL to ID card image
- created_at, updated_at - Timestamps
```

## 🔄 Workflow Example

1. **Admin creates company**: "Acme Corp"
2. **Company login to management page**
3. **Add businesses**:
   - Business A: "Engineering Department"
   - Business B: "Sales Department"
4. **Add labor**:
   - Employee 1: Assigned to Business A
   - Employee 2: Assigned to Business B
   - Employee 3: Assigned to Business A
5. **Filter by Business A**: Shows Employees 1 & 3 only
6. **Edit/Delete** as needed

## 📊 Current Data Flow

```
Admin Dashboard
    ↓
Create Company
    ↓
Company Login → Management Page
    ↓
Toggle Services (Business/Labor)
    ↓
Manage Business Records
    ↓
Manage Labor Records (filtered by business)
```

## 🚀 Future Enhancements

- [ ] File upload for ID card images
- [ ] Bulk import from Excel
- [ ] Attendance tracking
- [ ] Salary calculation and transfer
- [ ] Reports generation
- [ ] Search functionality
- [ ] Pagination for large datasets
- [ ] Data validation on form submission
- [ ] Confirmation dialogs before delete
- [ ] Success notifications

## ⚠️ Important Notes

- Each labor record must have a unique national ID
- Each labor can only be assigned to ONE business
- Businesses can have multiple laborers
- All data is filtered by company_id for security
- Services are controlled by admin on admin dashboard