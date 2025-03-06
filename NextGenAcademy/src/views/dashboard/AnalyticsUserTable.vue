<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/supabase'
import PlayerInfo from '@/layouts/components/players/PlayerInfo.vue'
import PlayerPayments from '@/layouts/components/players/PlayerPayments.vue'
import PlayerEquipment from '@/layouts/components/players/PlayerEquipment.vue'

const players = ref([])
const teams = ref([])
const selectedTeam = ref(null)
const searchQuery = ref("")
const activeTab = ref('playerInfo')
const selectedPlayer = ref(null)
const isModalOpen = ref(false)
const userClubId = ref(null)

const fetchUserClub = async () => {
  const user = (await supabase.auth.getUser()).data.user;

  if (!user) {
    console.error("User not authenticated");
    return;
  }

  const { data, error } = await supabase
    .from('profiles')
    .select('club_id')
    .eq('id', user.id)
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error("Error fetching user club:", error.message);
  } else if (!data) {
    console.error("No profile found for user");
  } else {
    userClubId.value = data.club_id; // Correctly set the club_id
    fetchTeams(); // Fetch teams for the user's club
    fetchPlayers(); // Fetch players for the user's club
  }
};

const fetchPlayers = async () => {
  const { data, error } = await supabase
    .from('players')
    .select(`id, first_name, last_name, birth_date, position, contact, team_id, teams(name), address, city, nationality, guardian_name, guardian_contact`)
    .eq('club_id', userClubId.value); // Filter players by the club_id

  if (error) {
    console.error("Error fetching players:", error.message);
  } else {
    players.value = data.map(player => ({
      ...player,
      full_name: `${player.first_name} ${player.last_name}`,
      team_name: player.teams ? player.teams.name : 'No Team',
      payment_status: player.player_payments?.length ? player.player_payments[0].status : 'N/A',
    }));
  }
};

const fetchTeams = async () => {
  const { data, error } = await supabase
    .from('teams')
    .select('id, name')
    .eq('club_id', userClubId.value); // Filter by club_id

  if (error) {
    console.error("Error fetching teams:", error.message);
  } else {
    teams.value = data
      .map(team => ({ name: team.name, value: team.id }))  // Ensure value is the team id and text is the team name
      .sort((a, b) => a.name.localeCompare(b.name));
  }
};

const sortedPlayers = computed(() => {
  return [...players.value].sort((a, b) => {
    const numA = parseInt(a.team_name.replace(/\D/g, ""), 10)
    const numB = parseInt(b.team_name.replace(/\D/g, ""), 10)
    return numA - numB
  })
});

const filteredPlayers = computed(() => {
  const searchLower = (searchQuery.value || "").toLowerCase(); // Handle null or empty string

  return sortedPlayers.value.filter(player => {
    const matchesTeam = !selectedTeam.value || player.team_id === selectedTeam.value
    const matchesSearch =
      !searchQuery.value ||
      player.full_name.toLowerCase().includes(searchLower) ||
      player.team_name.toLowerCase().includes(searchLower) ||
      player.position.toLowerCase().includes(searchLower) ||
      player.contact.includes(searchLower) ||
      (player.guardian_name && player.guardian_name.toLowerCase().includes(searchLower))

    return matchesTeam && matchesSearch
  })
});

const openPlayerModal = (event, { item }) => {
  selectedPlayer.value = item
  isModalOpen.value = true
}

onMounted(fetchUserClub);

const headers = [
  { title: 'Team', key: 'team_name' },
  { title: 'Player', key: 'full_name' },
  { title: 'Birthdate', key: 'birth_date' },
  { title: 'Position', key: 'position' },
  { title: 'Contact', key: 'contact' },
  { title: 'Guardian', key: 'guardian_name' },
  { title: 'Guardian Contact', key: 'guardian_contact' }
];
</script>

<template>
  <VCard>
    <div class="filters pa-4 d-flex gap-4">
      <VSelect
        v-model="selectedTeam"
        :items="teams"
        item-title="name"
        item-value="value"
        label="Filter by Team"
        clearable
      ></VSelect>

      <VTextField
        v-model="searchQuery"
        label="Search Players"
        clearable
      ></VTextField>
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredPlayers"
      :items-per-page="-1"
      item-value="id"
      class="text-no-wrap"
      @click:row="openPlayerModal"
    >
      <template #item.team_name="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.team_name }}</h6>
      </template>
      <template #item.full_name="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.first_name }} {{ item.last_name }}</h6>
      </template>
      <template #item.birth_date="{ item }">
        {{ item.birth_date }}
      </template>
      <template #item.position="{ item }">
        <div class="text-capitalize">{{ item.position }}</div>
      </template>
      <template #item.contact="{ item }">
        <div>{{ item.contact }}</div>
      </template>
      <template #item.guardian_name="{ item }">
        <div>{{ item.guardian_name || "N/A" }}</div>
      </template>
      <template #item.guardian_contact="{ item }">
        <div>{{ item.guardian_contact || "N/A" }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>

  <VDialog v-model="isModalOpen" width="600">
    <VCard>
      <VCardTitle>
        {{ selectedPlayer?.full_name }} - {{ selectedPlayer?.team_name || 'No team' }}
      </VCardTitle>
      <VCardText>
        <VTabs v-model="activeTab">
          <VTab value="playerInfo">Information</VTab>
          <VTab value="playerPayments">Payments</VTab>
          <VTab value="playerEquipment">Equipment</VTab>
        </VTabs>

        <VWindow v-model="activeTab">
          <VWindowItem value="playerInfo">
            <PlayerInfo :player="selectedPlayer" />
          </VWindowItem>
          <VWindowItem value="playerPayments">
            <PlayerPayments :player="selectedPlayer" />
          </VWindowItem>
          <VWindowItem value="playerEquipment">
            <PlayerEquipment :player="selectedPlayer" />
          </VWindowItem>
        </VWindow>
      </VCardText>

      <VCardActions>
        <VBtn @click="isModalOpen = false">Close</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>
