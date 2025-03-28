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

const isModalOpen = ref(false)
const selectedStaff = ref(null)
const availableTeams = ref([])  // Hold teams data
const staffWithNoTeam = ref([])  // Changed from teamsWithNoTeamOption to staffWithNoTeam

// Fetch the user's club ID
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
    fetchTeams()  // Fetch teams after the club ID is fetched
  }
}

// Fetch all staff members based on club_id
const fetchStaff = async () => {
  const { data, error } = await supabase
    .from('profiles')
    .select(`id, first_name, last_name, role, secondary_role, contact, team_id, teams(name)`)
    .eq('club_id', userClubId.value)  // Filter by the current club
    .eq('role', 'staff')  // Filter by the "staff" role

  if (error) {
    console.error('Error fetching staff:', error.message)
  } else {
    staff.value = data
    allStaff.value = data  // Keep a reference to all staff for filtering
  }
}

// Fetch available teams for the current club
const fetchTeams = async () => {
  const { data, error } = await supabase
    .from('teams')
    .select('id, name, club_id')
    .eq('club_id', userClubId.value)  // Filter by the current club

  if (error) {
    console.error('Error fetching teams:', error.message)
  } else {
    availableTeams.value = data  // Store available teams for selection
    // Add "No Team" option
    staffWithNoTeam.value = [{ id: null, name: 'No Team' }, ...data]
  }
}

// Computed property for filtering staff
const filteredStaff = computed(() => {
  const searchLower = searchQuery.value.toLowerCase()

  return allStaff.value.filter(staffMember => {
    const matchesRole = !selectedRole.value || staffMember.role === selectedRole.value
    const matchesSearch =
      !searchQuery.value ||
      staffMember.first_name.toLowerCase().includes(searchLower) ||
      staffMember.last_name.toLowerCase().includes(searchLower) ||
      staffMember.contact?.toLowerCase().includes(searchLower) ||
      staffMember.teams?.name.toLowerCase().includes(searchLower)
    return matchesRole && matchesSearch
  })
})

const headers = [
  { title: 'Name', key: 'full_name' },
  { title: 'Team', key: 'team_name' },
  { title: 'Role', key: 'secondary_role' },
  { title: 'Contact', key: 'contact' }
]

const openStaffModal = (event, { item }) => {
  selectedStaff.value = item
  isModalOpen.value = true
}

// Close the modal
const closeModal = () => {
  isModalOpen.value = false
}

// Save the updated team selection for the staff
const saveTeamSelection = async () => {
  if (!selectedStaff.value || !selectedStaff.value.id) {
    console.error('No staff member selected')
    return
  }

  try {
    const { error } = await supabase
      .from('profiles')
      .update({ 
        team_id: selectedStaff.value.team_id 
      })
      .eq('id', selectedStaff.value.id)

    if (error) throw error

    console.log('Team updated successfully')
    
    // Refresh the data
    await fetchStaff()
    closeModal()
  } catch (error) {
    console.error('Error updating team:', error.message)
    // You might want to show an error message to the user here
  }
}

// Trigger fetching of user club when component is mounted
onMounted(fetchUserClub)
</script>

<template>
  <VCard>
    <div class="filters pa-4 d-flex gap-4">
      <VSelect
        v-model="selectedRole"
        :items="[ 
          'main coach', 
          'assistant coach', 
          'fitness coach', 
          'analyst', 
          'physioterapist', 
          'medic', 
          'nurse', 
          'team manager', 
          'assistant team manager' 
        ]"
        label="Filter by Role"
        clearable
      ></VSelect>

      <VTextField
        v-model="searchQuery"
        label="Search Staff"
        clearable
      ></VTextField>

      <VBtn color="primary" @click="router.push('/staff/add')">
        Add Staff
      </VBtn>
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredStaff"
      :items-per-page="-1"
      item-value="id"
      class="text-no-wrap"
      @click:row="openStaffModal"
    >
      <template #item.full_name="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.first_name }} {{ item.last_name }}</h6>
      </template>
      <template #item.team_name="{ item }">
        <div>{{ item.teams?.name || 'N/A' }}</div>
      </template>
      <template #item.role="{ item }">
        <div>{{ item.role }}</div>
      </template>
      <template #item.contact="{ item }">
        <div>{{ item.contact || 'N/A' }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>

  <!-- Staff Details Modal -->
  <VDialog v-model="isModalOpen" max-width="500px">
    <VCard>
      <VCardTitle>{{ selectedStaff?.first_name }} {{ selectedStaff?.last_name }}</VCardTitle>
      <VCardText>
        <div><strong>Role:</strong> {{ selectedStaff?.role }}</div>
        <div><strong>Secondary Role:</strong> {{ selectedStaff?.secondary_role }}</div>
        <div><strong>Contact:</strong> {{ selectedStaff?.contact || 'N/A' }}</div>
        <div>
          <strong>Assign to Team:</strong>
          <VSelect
            v-model="selectedStaff.team_id"
            :items="staffWithNoTeam"
            item-title="name"
            item-value="id"
            label="Select Team"
          />
        </div>
      </VCardText>
      <VCardActions>
        <VBtn @click="closeModal">Close</VBtn>
        <VBtn color="primary" @click="saveTeamSelection">Save</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>