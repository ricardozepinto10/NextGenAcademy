<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()
const staff = ref([])
const allStaff = ref([])
const selectedRole = ref(null)
const selectedTeam = ref(null) // Added filter by team
const searchQuery = ref("")
const userClubId = ref(null)

const isModalOpen = ref(false)
const selectedStaff = ref(null)
const availableTeams = ref([])
const staffWithNoTeam = ref([])

const secondaryRoles = ref([])

onMounted(async () => {
  const { data, error } = await supabase.from('secondary_roles').select('name')
  if (!error) secondaryRoles.value = data.map(r => r.name)
})

// Add Staff Modal
const isAddStaffModalOpen = ref(false)
const newStaffEmail = ref("")

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
    fetchTeams()
  }
}

const fetchStaff = async () => {
  const { data, error } = await supabase
    .from('profiles')
    .select(`id, first_name, last_name, role, secondary_role, contact, team_id, teams(name)`)
    .eq('club_id', userClubId.value)
    .eq('role', 'staff')

  if (error) {
    console.error('Error fetching staff:', error.message)
  } else {
    staff.value = data
    allStaff.value = data
  }
}

const fetchTeams = async () => {
  const { data, error } = await supabase
    .from('teams')
    .select('id, name, club_id')
    .eq('club_id', userClubId.value)

  if (error) {
    console.error('Error fetching teams:', error.message)
  } else {
    availableTeams.value = data
    staffWithNoTeam.value = [{ id: null, name: 'No Team' }, ...data]
  }
}

// **Updated Filter Logic**
const filteredStaff = computed(() => {
  const searchLower = searchQuery.value?.toLowerCase() || ""

  return allStaff.value.filter(staffMember => {
    const matchesRole = !selectedRole.value || staffMember.secondary_role === selectedRole.value
    const matchesTeam = !selectedTeam.value || staffMember.team_id === selectedTeam.value
    const matchesSearch =
      !searchQuery.value ||
      staffMember.first_name.toLowerCase().includes(searchLower) ||
      staffMember.last_name.toLowerCase().includes(searchLower) ||
      staffMember.contact?.toLowerCase().includes(searchLower) ||
      staffMember.teams?.name?.toLowerCase().includes(searchLower)

    return matchesRole && matchesTeam && matchesSearch
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

const closeModal = () => {
  isModalOpen.value = false
}

const saveTeamSelection = async () => {
  if (!selectedStaff.value || !selectedStaff.value.id) {
    console.error('No staff member selected')
    return
  }

  try {
    const { error } = await supabase
      .from('profiles')
      .update({
        team_id: selectedStaff.value.team_id,
        secondary_role: selectedStaff.value.secondary_role || null,
      })
      .eq('id', selectedStaff.value.id)

    if (error) throw error

    console.log('Team and secondary role updated successfully')
    await fetchStaff()
    closeModal()
  } catch (error) {
    console.error('Error updating staff:', error.message)
  }
}


// **Open Add Staff Modal**
const openAddStaffModal = () => {
  isAddStaffModalOpen.value = true
}

// **Send Invite Function**
const sendInvite = async () => {
  if (!newStaffEmail.value) {
    console.error('Email is required')
    return
  }

  try {
    const { error } = await supabase
      .from('invitations')
      .insert([{ email: newStaffEmail.value, club_id: userClubId.value, role: 'staff' }])

    if (error) throw error

    console.log('Invitation sent successfully')
    isAddStaffModalOpen.value = false
    newStaffEmail.value = ""
  } catch (error) {
    console.error('Error sending invite:', error.message)
  }
}

onMounted(fetchUserClub)
</script>

<template>
  <VCard>
    <div class="filters pa-4 d-flex gap-4">
      <!-- Search Staff -->
      <VTextField v-model="searchQuery" label="Search Staff" clearable />
      
      <!-- Filter by Role -->
      <VSelect
        v-model="selectedRole"
        :items="secondaryRoles"
        item-title="name"
        item-value="name"
        label="Filter by Role"
        clearable
      />

      <!-- Filter by Team -->
      <VSelect
        v-model="selectedTeam"
        :items="availableTeams"
        item-title="name"
        item-value="id"
        label="Filter by Team"
        clearable
      />

      <!-- Add Staff Button -->
      <VBtn color="primary" @click="openAddStaffModal">
        Add Staff
      </VBtn>
    </div>

    <!-- Staff Table -->
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
      <div><strong>Secondary Role:</strong> {{ selectedStaff?.secondary_role || 'N/A' }}</div>
      <div><strong>Contact:</strong> {{ selectedStaff?.contact || 'N/A' }}</div>
    </VCardText>

    <VCardText>
      <div class="mb-4">
        <strong>Assign to Team:</strong>
        <VSelect
          v-model="selectedStaff.team_id"
          :items="staffWithNoTeam"
          item-title="name"
          item-value="id"
          label="Select Team"
        />
      </div>
      <div>
        <strong>Assign Secondary Role:</strong>
        <VSelect
          v-model="selectedStaff.secondary_role"
          :items="secondaryRoles"
          label="Select Role"
          clearable
        />
      </div>
    </VCardText>

    <VCardActions>
      <VBtn @click="closeModal">Close</VBtn>
      <VBtn color="primary" @click="saveTeamSelection">Save</VBtn>
    </VCardActions>
  </VCard>
</VDialog>


  <!-- **Add Staff Modal** -->
  <VDialog v-model="isAddStaffModalOpen" max-width="400px">
    <VCard>
      <VCardTitle>Add Staff</VCardTitle>
      <VCardText>
        <VTextField v-model="newStaffEmail" label="Staff Email" type="email" clearable />
      </VCardText>
      <VCardActions>
        <VBtn @click="isAddStaffModalOpen = false">Cancel</VBtn>
        <VBtn color="primary" @click="sendInvite">Send Invite</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>
