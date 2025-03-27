import { ref } from 'vue'
import { supabase } from '@/supabase'

export function useSupabase() {
  const user = ref(null)

  // Function to fetch and return the authenticated user
  const getUser = async () => {
    const { data: { session }, error: sessionError } = await supabase.auth.getSession()

    if (sessionError) {
      console.error('Error checking session:', sessionError)
      return null
    }

    if (!session || !session.user) {
      console.error('No active session or authenticated user found')
      return null
    }

    const { user: currentUser } = session

    // Query the profiles table to get the user role
    const { data, error: dbError } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', currentUser.id)
      .single()

    if (dbError) {
      console.error('Error fetching user role:', dbError)
      return null
    }

    // Set the user data including the role
    user.value = {
      ...currentUser,
      role: data ? data.role : 'guest' // Default to 'guest' if no role is found
    }

    return user.value
  }

  // Fetch the user during setup
  const setupUser = async () => {
    const fetchedUser = await getUser()
    return fetchedUser
  }

  return { user, setupUser, getUser }
}
