// إعدادات Supabase
const SUPABASE_URL = 'YOUR_SUPABASE_URL'; // استبدل بـ URL الخاص بمشروعك
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // استبدل بالمفتاح العام

// تهيئة عميل Supabase
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/**
 * خدمات المصادقة
 */
class AuthService {
    
    /**
     * تسجيل الدخول
     * @param {string} email 
     * @param {string} password 
     * @returns {Promise<Object>}
     */
    static async login(email, password) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (error) {
                throw new Error(error.message);
            }

            // الحصول على تفاصيل المستخدم
            const userProfile = await this.getUserProfile(data.user.id);
            
            return {
                success: true,
                user: data.user,
                profile: userProfile
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * تسجيل مستخدم جديد (للمدير فقط)
     * @param {Object} userData 
     * @returns {Promise<Object>}
     */
    static async signUp(userData) {
        try {
            const { data, error } = await supabase.auth.signUp({
                email: userData.email,
                password: userData.password
            });

            if (error) {
                throw new Error(error.message);
            }

            // إنشاء ملف تعريف المستخدم
            const profileData = {
                id: data.user.id,
                role: userData.role,
                company_name: userData.companyName || null,
                contact_person: userData.contactPerson || null,
                phone: userData.phone || null,
                address: userData.address || null
            };

            const { error: profileError } = await supabase
                .from('users')
                .insert([profileData]);

            if (profileError) {
                throw new Error(profileError.message);
            }

            return {
                success: true,
                user: data.user,
                profile: profileData
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * تسجيل الخروج
     * @returns {Promise<Object>}
     */
    static async logout() {
        try {
            const { error } = await supabase.auth.signOut();
            
            if (error) {
                throw new Error(error.message);
            }

            return { success: true };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * الحصول على المستخدم الحالي
     * @returns {Promise<Object>}
     */
    static async getCurrentUser() {
        try {
            const { data: { user } } = await supabase.auth.getUser();
            
            if (!user) {
                return { success: false, error: 'المستخدم غير مسجل دخول' };
            }

            const profile = await this.getUserProfile(user.id);
            
            return {
                success: true,
                user: user,
                profile: profile
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * الحصول على ملف تعريف المستخدم
     * @param {string} userId 
     * @returns {Promise<Object>}
     */
    static async getUserProfile(userId) {
        try {
            const { data, error } = await supabase
                .from('users')
                .select('*')
                .eq('id', userId)
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            console.error('خطأ في الحصول على ملف المستخدم:', error);
            return null;
        }
    }

    /**
     * التحقق من صلاحية الوصول للخدمة
     * @param {string} serviceName 
     * @returns {Promise<boolean>}
     */
    static async hasServiceAccess(serviceName) {
        try {
            const currentUser = await this.getCurrentUser();
            
            if (!currentUser.success) {
                return false;
            }

            // المدير يمكنه الوصول لكل شيء
            if (currentUser.profile.role === 'admin') {
                return true;
            }

            // فحص تفعيل الخدمة للشركة
            const { data, error } = await supabase
                .from('company_services')
                .select('is_active, expires_at')
                .eq('company_id', currentUser.user.id)
                .eq('service_id', await this.getServiceId(serviceName))
                .single();

            if (error || !data) {
                return false;
            }

            // فحص التفعيل وانتهاء الصلاحية
            if (!data.is_active) {
                return false;
            }

            if (data.expires_at && new Date(data.expires_at) < new Date()) {
                return false;
            }

            return true;
        } catch (error) {
            console.error('خطأ في فحص صلاحية الخدمة:', error);
            return false;
        }
    }

    /**
     * الحصول على معرف الخدمة
     * @param {string} serviceName 
     * @returns {Promise<string>}
     */
    static async getServiceId(serviceName) {
        try {
            const { data, error } = await supabase
                .from('services')
                .select('id')
                .eq('name', serviceName)
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data.id;
        } catch (error) {
            console.error('خطأ في الحصول على معرف الخدمة:', error);
            return null;
        }
    }
}

/**
 * خدمات إدارة الشركات (للمدير فقط)
 */
class CompanyService {
    
    /**
     * الحصول على جميع الشركات
     * @returns {Promise<Object>}
     */
    static async getAllCompanies() {
        try {
            const { data, error } = await supabase
                .from('users')
                .select('*')
                .eq('role', 'company')
                .order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return {
                success: true,
                companies: data
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * تفعيل/إلغاء تفعيل خدمة لشركة
     * @param {string} companyId 
     * @param {string} serviceName 
     * @param {boolean} isActive 
     * @param {string} expiresAt - تاريخ انتهاء الصلاحية (اختياري)
     * @returns {Promise<Object>}
     */
    static async toggleCompanyService(companyId, serviceName, isActive, expiresAt = null) {
        try {
            const serviceId = await AuthService.getServiceId(serviceName);
            
            if (!serviceId) {
                throw new Error('الخدمة غير موجودة');
            }

            const { data, error } = await supabase
                .from('company_services')
                .upsert([{
                    company_id: companyId,
                    service_id: serviceId,
                    is_active: isActive,
                    expires_at: expiresAt,
                    activated_at: isActive ? new Date().toISOString() : null
                }])
                .select();

            if (error) {
                throw new Error(error.message);
            }

            return {
                success: true,
                data: data[0]
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * الحصول على خدمات الشركة
     * @param {string} companyId 
     * @returns {Promise<Object>}
     */
    static async getCompanyServices(companyId) {
        try {
            const { data, error } = await supabase
                .from('company_services')
                .select(`
                    *,
                    services (
                        name,
                        description
                    )
                `)
                .eq('company_id', companyId);

            if (error) {
                throw new Error(error.message);
            }

            return {
                success: true,
                services: data
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }
}

/**
 * دوال مساعدة عامة
 */
class Utils {
    
    /**
     * عرض رسالة تحميل
     * @param {string} message 
     */
    static showLoading(message = 'جاري التحميل...') {
        // يمكن تخصيص هذه الدالة حسب التصميم
        console.log(message);
    }

    /**
     * إخفاء رسالة التحميل
     */
    static hideLoading() {
        // يمكن تخصيص هذه الدالة حسب التصميم
        console.log('تم إنهاء التحميل');
    }

    /**
     * عرض رسالة خطأ
     * @param {string} message 
     */
    static showError(message) {
        alert('خطأ: ' + message);
    }

    /**
     * عرض رسالة نجاح
     * @param {string} message 
     */
    static showSuccess(message) {
        alert('نجح: ' + message);
    }

    /**
     * التحقق من أن المستخدم مسجل دخول
     * @returns {Promise<boolean>}
     */
    static async requireAuth() {
        const currentUser = await AuthService.getCurrentUser();
        
        if (!currentUser.success) {
            window.location.href = 'login.html';
            return false;
        }

        return true;
    }

    /**
     * التحقق من صلاحيات المدير
     * @returns {Promise<boolean>}
     */
    static async requireAdmin() {
        const currentUser = await AuthService.getCurrentUser();
        
        if (!currentUser.success || currentUser.profile.role !== 'admin') {
            this.showError('هذه الصفحة مخصصة للمدير فقط');
            window.location.href = 'dashboard.html';
            return false;
        }

        return true;
    }

    /**
     * التحقق من صلاحية الوصول للخدمة
     * @param {string} serviceName 
     * @returns {Promise<boolean>}
     */
    static async requireService(serviceName) {
        const hasAccess = await AuthService.hasServiceAccess(serviceName);
        
        if (!hasAccess) {
            this.showError('ليس لديك صلاحية للوصول لهذه الخدمة');
            window.location.href = 'dashboard.html';
            return false;
        }

        return true;
    }

    /**
     * تنسيق التاريخ
     * @param {string|Date} date 
     * @returns {string}
     */
    static formatDate(date) {
        return new Date(date).toLocaleDateString('ar-SA', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }

    /**
     * تنسيق المبلغ النقدي
     * @param {number} amount 
     * @returns {string}
     */
    static formatCurrency(amount) {
        return new Intl.NumberFormat('ar-OM', {
            style: 'currency',
            currency: 'OMR'
        }).format(amount);
    }
}

// التأكد من أن Supabase محمل
document.addEventListener('DOMContentLoaded', function() {
    if (typeof supabase === 'undefined') {
        console.error('مكتبة Supabase غير محملة! تأكد من إضافة السكريبت في HTML');
    }
});
