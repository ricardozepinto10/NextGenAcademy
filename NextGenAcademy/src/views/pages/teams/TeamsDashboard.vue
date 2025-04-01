<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()
const teams = ref([])
const allTeams = ref([])
const selectedTeam = ref(null)
const searchQuery = ref("")
const userClubId = ref(null)

// Modal controls
const showTeamModal = ref(false)
const showAddTeamModal = ref(false)
const selectedTeamDetails = ref(null)
const teamStaff = ref([])

// New team form
const newTeamName = ref("")

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
    fetchTeams()
  }
}

// Fetch teams with staff
const fetchTeams = async () => {
  const { data, error } = await supabase
    .from('teams')
    .select('id, name, club_id')
    .eq('club_id', userClubId.value)

  if (error) {
    console.error('Error fetching teams:', error.message)
  } else {
    // Fetch staff for each team
    const teamsWithStaff = await Promise.all(
      data.map(async (team) => {
        const { data: staffData, error: staffError } = await supabase
          .from('profiles')
          .select('id, first_name, last_name, secondary_role')
          .eq('team_id', team.id)
          .eq('role', 'staff')

        if (staffError) {
          console.error('Error fetching staff:', staffError.message)
          return team
        }

        // Assign staff names based on secondary_role
        const mainCoach = staffData.find(staff => staff.secondary_role === 'main coach')
        const subCoach = staffData.find(staff => staff.secondary_role === 'sub coach')
        const teamManager = staffData.find(staff => staff.secondary_role === 'team manager')

        return {
          ...team,
          main_coach: mainCoach ? `${mainCoach.first_name} ${mainCoach.last_name}` : 'N/A',
          sub_coach: subCoach ? `${subCoach.first_name} ${subCoach.last_name}` : 'N/A',
          team_manager: teamManager ? `${teamManager.first_name} ${teamManager.last_name}` : 'N/A'
        }
      })
    )

    teams.value = teamsWithStaff
    allTeams.value = teamsWithStaff
  }
}

// Fetch staff for a selected team
const fetchTeamStaff = async (teamId) => {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, first_name, last_name, secondary_role')
    .eq('team_id', teamId)
    .eq('role', 'staff')

  if (error) {
    console.error('Error fetching team staff:', error.message)
    teamStaff.value = []
  } else {
    teamStaff.value = data
  }
}

const filteredTeams = computed(() => {
  const searchLower = searchQuery.value ? searchQuery.value.toLowerCase() : ""

  return allTeams.value.filter(team => {
    const matchesTeam = !selectedTeam.value || team.id === selectedTeam.value
    const matchesSearch =
      !searchQuery.value ||
      team.name.toLowerCase().includes(searchLower) ||
      (team.main_coach && team.main_coach.toLowerCase().includes(searchLower)) ||
      (team.sub_coach && team.sub_coach.toLowerCase().includes(searchLower)) ||
      (team.team_manager && team.team_manager.toLowerCase().includes(searchLower))

    return matchesTeam && matchesSearch
  })
})


const headers = [
  { title: 'Team', key: 'name' },
  { title: 'Main Coach', key: 'main_coach' },
  { title: 'Sub Coach', key: 'sub_coach' },
  { title: 'Team Manager', key: 'team_manager' }
]

// Open team details modal
const openTeamModal = async (event, { item }) => {
  selectedTeamDetails.value = item
  await fetchTeamStaff(item.id)
  showTeamModal.value = true
}

// Add new team
const addTeam = async () => {
  if (!newTeamName.value.trim()) return

  const { error } = await supabase
    .from('teams')
    .insert([{ name: newTeamName.value, club_id: userClubId.value }])

  if (error) {
    console.error('Error adding team:', error.message)
  } else {
    newTeamName.value = ""
    showAddTeamModal.value = false
    fetchTeams()
  }
}

onMounted(fetchUserClub)
</script>

<template>
  <VCard>
    <div class="filters pa-4 d-flex gap-4">
      <VSelect
        v-model="selectedTeam"
        :items="allTeams.map(team => ({ name: team.name, value: team.id }))"
        item-title="name"
        item-value="value"
        label="Filter by Team"
        clearable
      ></VSelect>

      <VTextField
        v-model="searchQuery"
        label="Search Teams or Staff"
        clearable
      ></VTextField>

      <VBtn color="primary" @click="showAddTeamModal = true">Add Team</VBtn>
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredTeams"
      :items-per-page="-1"
      item-value="id"
      class="text-no-wrap"
      @click:row="openTeamModal"
    >
      <template #item.name="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.name }}</h6>
      </template>
      <template #item.main_coach="{ item }">
        <div>{{ item.main_coach }}</div>
      </template>
      <template #item.sub_coach="{ item }">
        <div>{{ item.sub_coach }}</div>
      </template>
      <template #item.team_manager="{ item }">
        <div>{{ item.team_manager }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>

  <!-- Add Team Modal -->
  <VDialog v-model="showAddTeamModal" max-width="400px">
    <VCard>
      <VCardTitle>Add Team</VCardTitle>
      <VCardText>
        <VTextField v-model="newTeamName" label="Team Name" required />
      </VCardText>
      <VCardActions>
        <VBtn @click="showAddTeamModal = false">Cancel</VBtn>
        <VBtn color="primary" @click="addTeam">Save</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>

  <!-- Team Details Modal -->
  <VDialog v-model="showTeamModal" max-width="600px">
    <VCard>
      <VCardTitle>{{ selectedTeamDetails?.name }} Details</VCardTitle>
      <VCardText>
        <VList v-if="teamStaff.length">
          <VListItem v-for="staff in teamStaff" :key="staff.id">
            <VListItemTitle>
              {{ staff.first_name }} {{ staff.last_name }} - {{ staff.secondary_role }}
            </VListItemTitle>
          </VListItem>
        </VList>
        <p v-else>No staff assigned to this team.</p>
      </VCardText>
      <VCardActions>
        <VBtn @click="showTeamModal = false">Close</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>
