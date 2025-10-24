# 📊 Accounting Module Implementation Plan

## Overview
Complete inventory, sales, and invoice management system integrated with the existing OFOQ platform.

---

## 🎯 Module Structure

### Service: المحاسبة (Accounting)
Admin enables/disables this service from the dashboard.

**3 Sub-Services:**
1. **إدارة المخزون** (Inventory/Warehouse Management)
2. **المبيعات** (Sales/POS System with QR Scanner)
3. **الفواتير** (Invoice Management)

---

## 📦 1. Inventory Management (إدارة المخزون)

### Features:
- ✅ Add/Edit/Delete products
- ✅ Search by product code
- ✅ Low stock alerts (red highlight + email notification)
- ✅ Refill/Restock functionality
- ✅ Automatic quantity tracking

### Table Columns:
| Column | Arabic | Type | Description |
|--------|--------|------|-------------|
| product_code | كود المنتج | TEXT | Unique product code/barcode |
| product_name | اسم المنتج | TEXT | Product name |
| purchase_price | سعر الشراء | DECIMAL | Cost price |
| selling_price | سعر البيع | DECIMAL | Retail price |
| total_quantity | العدد الإجمالي | INTEGER | Current stock quantity |
| min_quantity_alert | حد التنبيه | INTEGER | Alert threshold |

### Key Features:
1. **Low Stock Alert:**
   - When `total_quantity <= min_quantity_alert`
   - Row highlighted in RED
   - Sorted to top of table
   - Email notification sent (future)

2. **Refill Functionality:**
   - Button: "إعادة التعبئة" (Refill)
   - Opens modal to add quantity
   - Logs transaction in `inventory_transactions` table
   - Updates `total_quantity`

3. **Search:**
   - Real-time search by product code
   - Filters table as user types

---

## 🛒 2. Sales/POS System (المبيعات)

### Workflow:
```
1. User clicks "بيع جديد" (New Sale)
   ↓
2. Opens camera/QR scanner
   ↓
3. Scans products one by one
   ↓
4. Each scan adds product to cart
   ↓
5. User clicks "إنهاء المسح" (Finish Scanning)
   ↓
6. Shows review page with:
   - All scanned items
   - Quantities
   - Prices
   - Total amount
   - Options: Delete item, Add more items, Confirm sale
   ↓
7. User takes payment in real life
   ↓
8. User clicks "تأكيد البيع" (Confirm Sale)
   ↓
9. System:
   - Creates sale record
   - Decreases inventory quantities
   - Auto-creates invoice
   - Logs transactions
```

### Pages Needed:
1. **sales.html** - Sales list/history
2. **pos-scanner.html** - QR scanner interface
3. **sale-review.html** - Review before confirmation

### Key Features:
1. **QR Code Scanner:**
   - Uses device camera
   - Scans product codes
   - Looks up product in inventory
   - Adds to cart with quantity

2. **Cart Management:**
   - Add/remove items
   - Adjust quantities
   - Real-time total calculation

3. **Sale Confirmation:**
   - Validates inventory availability
   - Decreases stock automatically
   - Creates sale record
   - Auto-generates invoice
   - Logs all transactions

4. **Inventory Integration:**
   - Checks stock before adding to cart
   - Prevents overselling
   - Updates quantities on confirmation

---

## 🧾 3. Invoice Management (الفواتير)

### Features:
- ✅ View all invoices (sales + purchases)
- ✅ Filter by type (sale/purchase)
- ✅ Search by invoice number
- ✅ Add/Edit/Delete invoices
- ✅ Print invoice
- ✅ Auto-generation from sales

### Invoice Types:
1. **Sale Invoices:** Auto-created from POS sales
2. **Purchase Invoices:** Manually created when buying stock

### Table Columns:
| Column | Arabic | Type |
|--------|--------|------|
| invoice_number | رقم الفاتورة | TEXT |
| invoice_type | نوع الفاتورة | sale/purchase |
| total_amount | المبلغ الإجمالي | DECIMAL |
| payment_status | حالة الدفع | paid/pending/cancelled |
| invoice_date | تاريخ الفاتورة | DATE |

### Auto-Generation:
- When sale is confirmed in POS
- Invoice automatically created
- Invoice number: `INV-SALE-YYYYMMDD-XXXXX`
- Linked to sale record
- Contains all sale items

---

## 🗂️ Database Schema

### Tables Created:
1. **inventory** - Product catalog with quantities
2. **sales** - Sale transactions
3. **sale_items** - Products in each sale
4. **invoices** - All invoices (sales + purchases)
5. **invoice_items** - Line items in invoices
6. **inventory_transactions** - Audit log of quantity changes

### Relationships:
```
inventory ← (product_code) → sale_items
sales → sale_items (one-to-many)
sales → invoices (one-to-one for sales)
invoices → invoice_items (one-to-many)
```

### Auto-Triggers:
1. **On Sale Insert:** Auto-create invoice
2. **On Sale Item Insert:** Copy to invoice items
3. **On Sale Confirm:** Decrease inventory quantities

---

## 📱 Pages to Create

### 1. Inventory Page (inventory.html)
- Product list table
- Add/Edit/Delete buttons
- Search by product code
- Refill button for each product
- Low stock items highlighted in RED at top

### 2. Sales Page (sales.html)
- Sales history table
- "New Sale" button → opens POS scanner
- View sale details
- Search by sale number

### 3. POS Scanner Page (pos-scanner.html)
- Camera view for QR scanning
- Current cart display
- "Finish Scanning" button
- "Clear Cart" button

### 4. Sale Review Page (sale-review.html)
- List of scanned items
- Edit quantities
- Remove items
- "Add More" button → back to scanner
- Total amount display
- "Confirm Sale" button

### 5. Invoices Page (invoices.html)
- Invoice list table
- Filter by type (sale/purchase)
- Add/Edit/Delete
- Print invoice
- Search by invoice number

### 6. Invoice Form (invoice-form.html)
- Create/edit purchase invoices manually
- Add invoice items
- Calculate totals

### 7. Accounting Dashboard (accounting.html)
- Access to all 3 sub-services
- Quick stats (total inventory value, today's sales, pending invoices)

---

## 🔧 Technical Implementation

### QR Scanner Library:
**Use:** `html5-qrcode` library
```html
<script src="https://unpkg.com/html5-qrcode"></script>
```

### Features:
- Access device camera
- Scan QR codes/barcodes
- Real-time scanning
- Multi-format support

### Stock Decrease Logic:
```javascript
// On sale confirmation:
1. Start transaction
2. For each sale item:
   - Check if quantity available
   - Decrease inventory.total_quantity
   - Log in inventory_transactions
3. Create sale record
4. Create sale_items records
5. Auto-trigger creates invoice
6. Commit transaction
```

### Low Stock Alert:
```javascript
// Check after every inventory change:
if (product.total_quantity <= product.min_quantity_alert) {
    - Mark as low stock
    - Send email notification (future feature)
    - Highlight row in red
    - Sort to top
}
```

---

## 📋 Implementation Steps

### Phase 1: Database Setup
1. Run `create-accounting-tables.sql` in Supabase
2. Verify all tables created
3. Test RLS policies

### Phase 2: Inventory Management
1. Create `inventory.html` page
2. Implement CRUD operations
3. Add search functionality
4. Implement refill feature
5. Add low stock highlighting

### Phase 3: POS/Sales System
1. Create `pos-scanner.html` with QR scanner
2. Implement cart management
3. Create `sale-review.html` for confirmation
4. Integrate with inventory (quantity decrease)
5. Test complete flow

### Phase 4: Invoice Management
1. Test auto-invoice generation
2. Create `invoices.html` page
3. Add manual invoice creation
4. Implement invoice printing
5. Add filters and search

### Phase 5: Integration
1. Update dashboard to show accounting service
2. Add accounting module to navigation
3. Test all flows end-to-end
4. Add email notifications

---

## 🎨 UI/UX Considerations

### Colors:
- **Low Stock:** Red highlight (#dc3545)
- **Sale:** Green button (#28a745)
- **Purchase:** Blue button (#007bff)
- **Warning:** Orange (#D97706)

### Icons:
- Inventory: 📦 `fa-boxes`
- Sales: 🛒 `fa-shopping-cart`
- Invoice: 🧾 `fa-file-invoice`
- Scanner: 📷 `fa-camera`
- Refill: ♻️ `fa-sync-alt`

---

## 🔐 Security

- All tables have RLS enabled
- Company isolation via `company_id`
- Transactions logged for audit trail
- Prevent negative inventory
- Validate quantities before sale

---

**Next Step:** Create the pages one by one, starting with inventory management!
