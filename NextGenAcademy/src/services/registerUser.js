import { createClient } from '@supabase/supabase-js'

const supabase = createClient(import.meta.env.VITE_SUPABASE_URL, import.meta.env.VITE_SUPABASE_ANON_KEY)

// Function to register a new user
export async function registerUser({ email, password, code, first_name, last_name }) {
  try {
    const { data: club, error: clubError } = await supabase
      .from('clubs')
      .select('id')
      .eq('code', code)
      .single()

    if (clubError || !club) {
      throw new Error('Invalid club code. Please enter a valid code.')
    }

    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          first_name,
          last_name,
          club_id: club.id  // Ensure club_id is included here
        }
      }
    })
    
    if (authError) {
      throw new Error('Error creating user in Supabase Auth. ' + authError.message)
    }
    
    

    // UPDATE the profile instead of inserting
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        first_name,
        last_name,
        club_id: club.id,  // Assign the correct club_id
      })
      .eq('id', authData.user.id) // Match the profile by user ID

    if (profileError) {
      throw new Error('Error updating profile. ' + profileError.message)
    }

    return { success: true }
  } catch (error) {
    throw new Error(error.message)
  }
}
