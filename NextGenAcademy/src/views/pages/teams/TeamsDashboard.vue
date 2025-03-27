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

// Fetch teams with staff (main coach, sub coach, team manager) based on club_id
const fetchTeams = async () => {
  const { data, error } = await supabase
    .from('teams')
    .select(`
      id,
      name,
      club_id
    `)
    .eq('club_id', userClubId.value)

  if (error) {
    console.error('Error fetching teams:', error.message)
  } else {
    const teamsWithStaff = await Promise.all(
      data.map(async team => {
        // Fetch staff members (main coach, sub coach, team manager) for each team
        const { data: staffData, error: staffError } = await supabase
          .from('staff')
          .select('id, role, user_id')
          .eq('club_id', userClubId.value)
          .or(`role.eq.main coach,role.eq.sub coach,role.eq.team manager`) // Fetching all staff roles

        if (staffError) {
          console.error('Error fetching staff:', staffError.message)
        } else {
          // Find and assign staff to team roles
          const mainCoach = staffData.find(staff => staff.role === 'main coach')
          const subCoach = staffData.find(staff => staff.role === 'sub coach')
          const teamManager = staffData.find(staff => staff.role === 'team manager')

          // Assign staff names to the team object
          team.main_coach = mainCoach ? mainCoach.user_id : null
          team.sub_coach = subCoach ? subCoach.user_id : null
          team.team_manager = teamManager ? teamManager.user_id : null
        }
        return team
      })
    )
    teams.value = teamsWithStaff
    allTeams.value = teamsWithStaff // Keep a reference to all teams for filtering
  }
}

// Computed property for filtering teams
const filteredTeams = computed(() => {
  const searchLower = searchQuery.value.toLowerCase()

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

const goToTeamPage = (event, { item }) => {
  router.push(`/teams/${item.id}`)
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
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredTeams"
      :items-per-page="-1"
      item-value="id"
      class="text-no-wrap"
      @click:row="goToTeamPage"
    >
      <template #item.name="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.name }}</h6>
      </template>
      <template #item.main_coach="{ item }">
        <div>{{ item.main_coach || 'N/A' }}</div>
      </template>
      <template #item.sub_coach="{ item }">
        <div>{{ item.sub_coach || 'N/A' }}</div>
      </template>
      <template #item.team_manager="{ item }">
        <div>{{ item.team_manager || 'N/A' }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>
</template>
