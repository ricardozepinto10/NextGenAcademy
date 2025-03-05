import { createClient } from '@supabase/supabase-js'

const supabase = createClient(import.meta.env.VITE_SUPABASE_URL, import.meta.env.VITE_SUPABASE_ANON_KEY)

// Function to register a new user
export async function registerUser({ email, password, code }) {
  try {
    // Check if the provided club code exists
    const { data: club, error: clubError } = await supabase
      .from('clubs')
      .select('id')
      .eq('code', code)
      .single()

    if (clubError || !club) {
      throw new Error('Invalid club code. Please enter a valid code.')
    }

    // Create the user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
    })

    if (authError) {
      throw new Error('Error creating user in Supabase Auth. ' + authError.message)
    }

    return { success: true }
  } catch (error) {
    throw new Error(error.message)
  }
}
