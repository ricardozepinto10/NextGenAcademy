<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/supabase'
import avatar1 from '@images/avatars/avatar-1.png'

const router = useRouter()

const userName = ref('John Doe') // Default name
const userRole = ref('Admin') // Default name
const userEmail = ref('johndoe@email.com') // Default email

const handleLogout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    console.error('Logout failed:', error.message)
  } else {
    router.push('/login')
  }
}

// Fetch user profile data
onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (user) {
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('first_name, last_name, role')
      .eq('id', user.id)
      .single()
    if (profile) {
      userName.value = `${profile.first_name} ${profile.last_name}`.trim() || 'John Doe'
      // Capitalize the first letter of the userRole
      userRole.value = profile.role.charAt(0).toUpperCase() + profile.role.slice(1).toLowerCase()
    }
    userEmail.value = user.email || 'No Email' // Store the email value
  }
})
</script>

<template>
  <VBadge
    dot
    location="bottom right"
    offset-x="3"
    offset-y="3"
    color="success"
    bordered
  >
    <VAvatar
      class="cursor-pointer"
      color="primary"
      variant="tonal"
    >
      <VImg :src="avatar1" />

      <!-- SECTION Menu -->
      <VMenu
        activator="parent"
        width="230"
        location="bottom end"
        offset="14px"
      >
        <VList>
          <!-- 👉 User Avatar & Name -->
          <VListItem>
            <template #prepend>
              <VListItemAction start>
                <VBadge
                  dot
                  location="bottom right"
                  offset-x="3"
                  offset-y="3"
                  color="success"
                >
                  <VAvatar
                    color="primary"
                    variant="tonal"
                  >
                    <VImg :src="avatar1" />
                  </VAvatar>
                </VBadge>
              </VListItemAction>
            </template>

            <VListItemTitle class="font-weight-semibold">
              {{ userName }}
            </VListItemTitle>
            <VListItemSubtitle>
              {{ userRole }}
            </VListItemSubtitle>
            <VListItemSubtitle>
              {{ userEmail }} 
            </VListItemSubtitle>
          </VListItem>
          <VDivider class="my-2" />

          <!-- 👉 Profile -->
          <VListItem to="account-settings">
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-user-5-line"
                size="22"
              />
            </template>

            <VListItemTitle>User Settings</VListItemTitle>
          </VListItem>

          <!-- 👉 FAQ -->
          <VListItem link>
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-question-line"
                size="22"
              />
            </template>

            <VListItemTitle>FAQ</VListItemTitle>
          </VListItem>

          <!-- Divider -->
          <VDivider class="my-2" />

          <!-- 👉 Logout -->
          <VListItem @click="handleLogout">
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-logout-box-r-line"
                size="22"
              />
            </template>

            <VListItemTitle>Logout</VListItemTitle>
          </VListItem>
        </VList>
      </VMenu>
      <!-- !SECTION -->
    </VAvatar>
  </VBadge>
</template>
