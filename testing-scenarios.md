# OFOQ System - AI Testing Scenarios with TestSprite

## 🎯 Test Coverage Areas

### 1. **Authentication & Authorization**
- [ ] Admin login with correct credentials
- [ ] Company login with correct credentials  
- [ ] Invalid login attempts
- [ ] Role-based redirections
- [ ] Session management
- [ ] Logout functionality

### 2. **Admin Dashboard Functions**
- [ ] Create new company accounts
- [ ] Service activation/deactivation toggles
- [ ] Company list display
- [ ] Delete company functionality
- [ ] Arabic UI elements rendering

### 3. **Company Dashboard**
- [ ] Service visibility based on activation
- [ ] Navigation to enabled services only
- [ ] Disabled service access prevention
- [ ] User profile display

### 4. **Database Integration**
- [ ] Supabase authentication flow
- [ ] User profile creation/retrieval
- [ ] Service activation database updates
- [ ] RLS policy enforcement

### 5. **UI/UX Testing**
- [ ] Arabic RTL text rendering
- [ ] Responsive design on mobile/tablet/desktop
- [ ] Omani branding elements display
- [ ] Loading states and error messages
- [ ] Form validation and user feedback

### 6. **Cross-browser Compatibility**
- [ ] Chrome functionality
- [ ] Firefox functionality  
- [ ] Safari functionality
- [ ] Edge functionality

## 🤖 TestSprite AI Commands

Once TestSprite MCP is configured, you can use commands like:

```
/test authentication flow
/test mobile responsiveness  
/test arabic text rendering
/validate form submissions
/check database connections
/test user role permissions
```

## 📊 Expected Test Results

### Performance Metrics
- **Load Time**: < 3 seconds
- **First Contentful Paint**: < 1.5 seconds
- **Time to Interactive**: < 2 seconds

### Functionality Checks
- ✅ All forms submit correctly
- ✅ Authentication redirects work
- ✅ Service toggles update database
- ✅ Arabic text displays properly
- ✅ Mobile layout adapts correctly

### Security Validations
- ✅ Unauthorized access blocked
- ✅ Role-based permissions enforced
- ✅ Session timeouts handled
- ✅ Database queries secured with RLS

## 🔧 Manual Test Instructions

If TestSprite needs guidance, here are the manual steps:

### Admin Login Test:
1. Navigate to `/login.html`
2. Enter `admin@ofoq.com`
3. Enter admin password
4. Click تسجيل الدخول
5. Verify redirect to `admin-dashboard.html`
6. Check Arabic header displays correctly

### Company Creation Test:
1. Login as admin
2. Fill company form with test data
3. Click إنشاء الشركة
4. Verify success message in Arabic
5. Check company appears in list
6. Test service toggle switches

### Company Login Test:
1. Logout from admin
2. Login with company credentials
3. Verify redirect to `dashboard.html`
4. Check only activated services show
5. Try accessing disabled services (should block)

This configuration will help TestSprite AI thoroughly test your OFOQ system! 🚀
