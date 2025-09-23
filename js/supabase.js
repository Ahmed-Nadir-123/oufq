// Supabase Configuration and Authentication
// This file handles all Supabase connections and authentication

// Import Supabase client
import { createClient } from 'https://cdn.skypack.dev/@supabase/supabase-js'

// Supabase configuration - Replace with your actual project details
const SUPABASE_URL = 'https://your-project-id.supabase.co'
const SUPABASE_ANON_KEY = 'your-anon-key-here'

// Initialize Supabase client
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Authentication functions
class SupabaseAuth {
    // Login function
    static async login(email, password) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            })
            
            if (error) throw error
            
            // Get user profile with role information
            const { data: userProfile, error: profileError } = await supabase
                .from('users')
                .select('role, company_name, contact_person')
                .eq('id', data.user.id)
                .single()
            
            if (profileError) throw profileError
            
            return {
                success: true,
                user: data.user,
                profile: userProfile
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
    
    // Logout function
    static async logout() {
        try {
            const { error } = await supabase.auth.signOut()
            if (error) throw error
            
            return { success: true }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
    
    // Get current user session
    static async getCurrentUser() {
        try {
            const { data: { user } } = await supabase.auth.getUser()
            
            if (!user) return { user: null }
            
            // Get user profile
            const { data: userProfile } = await supabase
                .from('users')
                .select('role, company_name, contact_person')
                .eq('id', user.id)
                .single()
            
            return {
                user: user,
                profile: userProfile
            }
        } catch (error) {
            return {
                user: null,
                error: error.message
            }
        }
    }
    
    // Check user role
    static async checkRole(requiredRole) {
        const { user, profile } = await this.getCurrentUser()
        
        if (!user || !profile) return false
        
        return profile.role === requiredRole
    }
    
    // Get company services
    static async getCompanyServices(companyId) {
        try {
            const { data, error } = await supabase
                .from('company_services')
                .select(`
                    is_active,
                    expires_at,
                    services (
                        name,
                        description
                    )
                `)
                .eq('company_id', companyId)
                .eq('is_active', true)
            
            if (error) throw error
            
            return {
                success: true,
                services: data
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
}

// Company data management
class CompanyData {
    // Get labor records
    static async getLaborRecords(companyId) {
        try {
            const { data, error } = await supabase
                .from('labor_records')
                .select('*')
                .eq('company_id', companyId)
                .order('created_at', { ascending: false })
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
    
    // Add labor record
    static async addLaborRecord(companyId, laborData) {
        try {
            const { data, error } = await supabase
                .from('labor_records')
                .insert([{
                    company_id: companyId,
                    ...laborData
                }])
                .select()
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
    
    // Update labor record
    static async updateLaborRecord(id, laborData) {
        try {
            const { data, error } = await supabase
                .from('labor_records')
                .update(laborData)
                .eq('id', id)
                .select()
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
    
    // Delete labor record
    static async deleteLaborRecord(id) {
        try {
            const { data, error } = await supabase
                .from('labor_records')
                .delete()
                .eq('id', id)
            
            if (error) throw error
            
            return { success: true }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
}

// Admin functions
class AdminFunctions {
    // Get all companies
    static async getAllCompanies() {
        try {
            const { data, error } = await supabase
                .from('users')
                .select('*')
                .eq('role', 'company')
                .order('created_at', { ascending: false })
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
    
    // Create new company
    static async createCompany(companyData) {
        try {
            // First create the auth user
            const { data: authData, error: authError } = await supabase.auth.admin.createUser({
                email: companyData.email,
                password: companyData.password,
                email_confirm: true
            })
            
            if (authError) throw authError
            
            // Then create the user profile
            const { data, error } = await supabase
                .from('users')
                .insert([{
                    id: authData.user.id,
                    role: 'company',
                    company_name: companyData.company_name,
                    contact_person: companyData.contact_person,
                    phone: companyData.phone,
                    address: companyData.address
                }])
                .select()
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
    
    // Toggle service for company
    static async toggleCompanyService(companyId, serviceId, isActive, expiresAt = null) {
        try {
            const { data, error } = await supabase
                .from('company_services')
                .upsert({
                    company_id: companyId,
                    service_id: serviceId,
                    is_active: isActive,
                    activated_at: isActive ? new Date().toISOString() : null,
                    expires_at: expiresAt
                })
                .select()
            
            if (error) throw error
            
            return { success: true, data }
        } catch (error) {
            return { success: false, error: error.message }
        }
    }
}

// Export classes for use in other files
window.SupabaseAuth = SupabaseAuth
window.CompanyData = CompanyData
window.AdminFunctions = AdminFunctions
window.supabase = supabase
