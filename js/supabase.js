// Supabase Configuration and Authentication
// This file handles all Supabase connections and authentication

// Import Supabase client
import { createClient } from 'https://cdn.skypack.dev/@supabase/supabase-js'

// Supabase configuration - Your actual project details
const SUPABASE_URL = 'https://wlnukwaecpkhxomfgxni.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsbnVrd2FlY3BraHhvbWZneG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NDc4MjEsImV4cCI6MjA3NDIyMzgyMX0.PW3GVs3l15oBIa8rS86offziTFkSVefj5OFUc6XRmoA'

// Initialize Supabase client
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Authentication functions
class SupabaseAuth {
    // Sign in function
    async signIn(email, password) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            })
            
            if (error) throw error
            
            return {
                user: data.user,
                session: data.session,
                error: null
            }
        } catch (error) {
            return {
                user: null,
                session: null,
                error: error
            }
        }
    }
    
    // Sign out function
    async signOut() {
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
    async getCurrentUser() {
        try {
            const { data: { user } } = await supabase.auth.getUser()
            return user
        } catch (error) {
            console.error('Get current user error:', error)
            return null
        }
    }
    
    // Get user role from database
    async getUserRole() {
        try {
            const user = await this.getCurrentUser()
            if (!user) return null
            
            const { data, error } = await supabase
                .from('user_profiles')
                .select('role')
                .eq('id', user.id)
                .single()
            
            if (error) throw error
            
            return data?.role || null
        } catch (error) {
            console.error('Get user role error:', error)
            return null
        }
    }
}

// Company data management
class CompanyData {
    // Get company information
    async getCompanyInfo() {
        try {
            const user = await new SupabaseAuth().getCurrentUser()
            if (!user) throw new Error('User not authenticated')
            
            const { data, error } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('id', user.id)
                .single()
            
            if (error) throw error
            
            // Get active services for the company
            const { data: services, error: servicesError } = await supabase
                .from('company_services')
                .select(`
                    services (name)
                `)
                .eq('company_id', user.id)
                .eq('is_active', true)
            
            if (servicesError) console.warn('Could not load services:', servicesError)
            
            // Extract service names
            const activeServices = services ? services.map(s => s.services.name) : []
            
            return {
                ...data,
                active_services: activeServices
            }
        } catch (error) {
            console.error('Get company info error:', error)
            return null
        }
    }
}

// Admin functions
class AdminFunctions {
    // Get all companies
    async getCompanies() {
        try {
            const { data, error } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('role', 'company')
                .order('created_at', { ascending: false })
            
            if (error) throw error
            
            // Get active services for each company
            const companiesWithServices = await Promise.all(
                data.map(async (company) => {
                    const { data: services } = await supabase
                        .from('company_services')
                        .select(`
                            services (name)
                        `)
                        .eq('company_id', company.id)
                        .eq('is_active', true)
                    
                    const activeServices = services ? services.map(s => s.services.name) : []
                    
                    return {
                        ...company,
                        active_services: activeServices
                    }
                })
            )
            
            return companiesWithServices
        } catch (error) {
            console.error('Get companies error:', error)
            throw error
        }
    }
    
    // Create new company
    async createCompany(companyData) {
        try {
            // Sign up the user
            const { data: authData, error: authError } = await supabase.auth.signUp({
                email: companyData.email,
                password: companyData.password
            })
            
            if (authError) throw authError
            
            // Create user profile
            const { data: profileData, error: profileError } = await supabase
                .from('user_profiles')
                .insert([{
                    id: authData.user.id,
                    role: 'company',
                    company_name: companyData.name,
                    contact_person: companyData.name,
                    phone: companyData.phone,
                    address: companyData.address
                }])
                .select()
                .single()
            
            if (profileError) throw profileError
            
            return {
                success: true,
                data: profileData
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
    
    // Toggle service for company
    async toggleService(companyId, serviceName, isActive) {
        try {
            // Get service ID
            const { data: service, error: serviceError } = await supabase
                .from('services')
                .select('id')
                .eq('name', serviceName)
                .single()
            
            if (serviceError) throw serviceError
            
            // Upsert company service
            const { data, error } = await supabase
                .from('company_services')
                .upsert({
                    company_id: companyId,
                    service_id: service.id,
                    is_active: isActive,
                    activated_at: isActive ? new Date().toISOString() : null
                })
                .select()
            
            if (error) throw error
            
            return {
                success: true,
                data: data[0]
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
    
    // Delete company
    async deleteCompany(companyId) {
        try {
            // Delete user profile (this will cascade to auth.users via RLS)
            const { error } = await supabase
                .from('user_profiles')
                .delete()
                .eq('id', companyId)
            
            if (error) throw error
            
            return {
                success: true
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            }
        }
    }
}

// Export classes for use in other files
window.SupabaseAuth = SupabaseAuth
window.CompanyData = CompanyData
window.AdminFunctions = AdminFunctions
window.supabase = supabase
