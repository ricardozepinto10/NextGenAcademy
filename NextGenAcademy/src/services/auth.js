import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

export async function loginUser(email, password) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })

    if (error) {
      throw new Error(error.message || 'Invalid credentials. Please check your email and password.')
    }

    // Ensure data.session exists (successful login)
    if (!data.session) {
      throw new Error('Authentication failed. No session created.')
    }

    return { success: true, message: 'Login successful' }
  } catch (error) {
    return { success: false, message: error.message }
  }
}
