import { supabase } from '@/supabase'

export const loginUser = async (email, password) => {
  const { data: session, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    return { success: false, message: error.message }
  }

  // Fetch user profile data after login
  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', session.user.id)
    .single()

  if (profileError) {
    return { success: false, message: profileError.message }
  }

  return {
    success: true,
    user: { ...session.user, role: profile ? profile.role : 'guest' }, // Ensure the role is returned
  }
}
