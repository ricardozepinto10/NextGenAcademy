import { createClient } from '@supabase/supabase-js'

// Supabase project credentials
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Initialize Supabase client
export const supabase = createClient(supabaseUrl, supabaseKey)
