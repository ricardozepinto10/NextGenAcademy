<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'
import PlayerInfo from '@/layouts/components/players/PlayerInfo.vue'
import PlayerPayments from '@/layouts/components/players/PlayerPayments.vue'
import PlayerEquipment from '@/layouts/components/players/PlayerEquipment.vue'

const players = ref([])
const activeTab = ref('playerInfo') // Default tab
const selectedPlayer = ref(null)
const isModalOpen = ref(false)

const fetchPlayers = async () => {
  const { data, error } = await supabase
    .from('players')
    .select(`
      id, 
      first_name, 
      last_name, 
      birth_date, 
      position, 
      contact, 
      team_id,
      teams(name),
      address, 
      city, 
      nationality, 
      player_payments(status),
      player_equipment(equipment_type, received)
    `);

  if (error) {
    console.error("Error fetching players:", error.message);
  } else {
    players.value = data.map(player => ({
      ...player,
      payment_status: player.player_payments?.length ? player.player_payments[0].status : 'N/A',
      team_name: player.teams ? player.teams.name : 'No Team'
    }));
  }
};


// Open Modal and Set Player
const openPlayerModal = (event, { item }) => {
  selectedPlayer.value = item
  isModalOpen.value = true
}

// Fetch players when component mounts
onMounted(fetchPlayers)

// Table Headers
const headers = [
  { title: 'Team', key: 'team' },
  { title: 'Player', key: 'fullName' },
  { title: 'Birthdate', key: 'birth' },
  { title: 'Position', key: 'position' },
  { title: 'Contact', key: 'contact' },
  { title: 'Payment Status', key: 'payment' },
  { title: 'Equipment Status', key: 'equipment' },
]
</script>

<template>
  <VCard>
    <VDataTable
      :headers="headers"
      :items="players"
      item-value="id"
      class="text-no-wrap"
      @click:row="openPlayerModal"
    >
      <template #item.fullName="{ item }">
        <h6 class="text-h6 font-weight-medium">{{ item.first_name }} {{ item.last_name }}</h6>
      </template>
      <template #item.birth="{ item }">
        {{ item.birth_date }}
      </template>
      <template #item.position="{ item }">
        <div class="text-capitalize">{{ item.position }}</div>
      </template>
      <template #item.contact="{ item }">
        <div>{{ item.contact }}</div>
      </template>
      <template #bottom />
    </VDataTable>
  </VCard>

  <!-- Player Modal -->
  <VDialog v-model="isModalOpen" width="600">
    <VCard>
      <VCardTitle>
        {{ selectedPlayer?.first_name }} {{ selectedPlayer?.last_name }} - {{ selectedPlayer?.team_name || 'No team' }}
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
