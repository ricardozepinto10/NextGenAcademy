<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()
const staff = ref([])
const allStaff = ref([])
const selectedRole = ref(null)
const searchQuery = ref("")
const userClubId = ref(null)

const fetchUserClub = async () => {
  const user = (await supabase.auth.getUser()).data.user

  if (!user) {
    console.error('User not authenticated')
    return
  }

  const { data, error } = await supabase
    .from('profiles')
    .select('club_id')
    .eq('id', user.id)
    .limit(1)
    .maybeSingle()

  if (error) {
    console.error('Error fetching user club:', error.message)
  } else if (!data) {
    console.error('No profile found for user')
  } else {
    userClubId.value = data.club_id
    fetchStaff()
  }
}

// Fetch staff members based on club_id
const fetchStaff = async () => {
  const { data, error } = await supabase
    .from('staff')
    .select(`
      id,
      role,
      user_id,
      club_id
    `)
    .eq('club_id', userClubId.value)

  if (error) {
    console.error('Error fetching staff:', error.message)
  } else {
    staff.value = data
    allStaff.value = data // Keep a reference to all staff for filtering
  }
}

// Computed property for filtering staff
const filteredStaff = computed(() => {
  const searchLower = searchQuery.value.toLowerCase()

  return allStaff.value.filter(staffMember => {
    const matchesRole = !selectedRole.value || staffMember.role === selectedRole.value
    const matchesSearch =
      !searchQuery.value ||
      staffMember.role.toLowerCase().includes(searchLower) ||
      staffMember.user_id.toString().includes(searchLower)

    return matchesRole && matchesSearch
  })
})

const headers = [
  { title: 'Role', key: 'role' },
  { title: 'User ID', key: 'user_id' }
]

const goToStaffPage = (event, { item }) => {
  router.push(`/staff/${item.id}`)
}

onMounted(fetchUserClub)
</script>

<template>
  <VCard>
    <div class="filters pa-4 d-flex gap-4">
      <VSelect
        v-model="selectedRole"
        :items="['main coach', 'sub coach', 'team manager']"
        label="Filter by Role"
        clearable
      ></VSelect>

      <VTextField
        v-model="searchQuery"
        label="Search Staff or Role"
        clearable
      ></VTextField>
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredStaff"
      :items-per-page="-1"
      item-value="id"
      class="text-no-wrap"
      @click:row="goToStaffPage"
    >
      <template #item.role="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.role }}</h6>
      </template>
      <template #item.user_id="{ item }">
        <div>{{ item.user_id }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>
</template>
