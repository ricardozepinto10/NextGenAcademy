<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase'

const clubs = ref([])
const selectedClub = ref(null)
const showAddModal = ref(false)
const showDetailsModal = ref(false)
const showDeleteConfirm = ref(false)
const searchQuery = ref("")

const name = ref("")
const city = ref("")
const country = ref("")

const headers = [
  { text: 'Club ID', value: 'id' },
  { text: 'Name', value: 'name' },
  { text: 'Country', value: 'country' },
  { text: 'City', value: 'city' },
  { text: 'Code', value: 'code' }
]

// Fetch clubs data
const fetchClubs = async () => {
  const { data, error } = await supabase.from('clubs').select('*')
  if (error) {
    console.error('Error fetching clubs:', error)
  } else {
    clubs.value = data
  }
}

// Filter logic
const filteredClubs = computed(() => {
  const query = searchQuery.value.toLowerCase()
  return clubs.value.filter(club =>
    club.name.toLowerCase().includes(query) ||
    club.country.toLowerCase().includes(query) ||
    club.city.toLowerCase().includes(query) ||
    club.code.toLowerCase().includes(query)
  )
})

// Open details modal
const openDetailsModal = (club) => {
  selectedClub.value = { ...club }
  showDetailsModal.value = true
}

// Handle club creation
const addClub = async () => {
  const { data, error } = await supabase.from('clubs').insert([
    { name: name.value, city: city.value, country: country.value }
  ]).select()

  if (error) {
    console.error('Error adding club:', error)
  } else {
    clubs.value.push(data[0])
    showAddModal.value = false
    name.value = ""
    city.value = ""
    country.value = ""
  }
}

// Handle club deletion
const deleteClub = async () => {
  const { error } = await supabase.from('clubs').delete().eq('id', selectedClub.value.id)
  if (error) {
    console.error('Error deleting club:', error)
  } else {
    clubs.value = clubs.value.filter(club => club.id !== selectedClub.value.id)
    showDetailsModal.value = false
    showDeleteConfirm.value = false
  }
}

onMounted(fetchClubs)
</script>

<template>
  <div class="p-6">
    <div class="d-flex gap-4 mb-4">
      <VTextField
        v-model="searchQuery"
        label="Search Clubs"
        placeholder="Search by name, country, city, or code"
        clearable
      />
      <VBtn color="primary" @click="showAddModal = true">Add Club</VBtn>
    </div>

    <VDataTable
      :headers="headers"
      :items="filteredClubs"
      class="text-no-wrap"
      @click:row="(event, { item }) => openDetailsModal(item)"
    />

    <!-- Add Club Modal -->
    <VDialog v-model="showAddModal" max-width="500px">
      <VCard>
        <VCardTitle>Add New Club</VCardTitle>
        <VCardText>
          <VForm @submit.prevent="addClub">
            <VRow>
              <VCol cols="12">
                <VTextField v-model="name" label="Club Name" placeholder="Enter club name" required />
              </VCol>

              <VCol cols="12">
                <VTextField v-model="city" label="City" placeholder="Enter city name" required />
              </VCol>

              <VCol cols="12">
                <VTextField v-model="country" label="Country" placeholder="Enter country name" required />
              </VCol>

              <VCol cols="12" class="d-flex gap-4">
                <VBtn type="submit" color="primary">Save</VBtn>
                <VBtn color="secondary" variant="outlined" @click="showAddModal = false">Cancel</VBtn>
              </VCol>
            </VRow>
          </VForm>
        </VCardText>
      </VCard>
    </VDialog>

    <!-- Club Details Modal -->
    <VDialog v-model="showDetailsModal" max-width="500px">
    <VCard>
        <VCardTitle>Club Details</VCardTitle>
        <VCardText>
        <p><strong>Name:</strong> {{ selectedClub?.name }}</p>
        <p><strong>Country:</strong> {{ selectedClub?.country }}</p>
        <p><strong>City:</strong> {{ selectedClub?.city }}</p>
        <p><strong>Code:</strong> {{ selectedClub?.code }}</p>
        
        <VRow class="mt-4">
            <VCol class="d-flex justify-start">
            <v-btn color="primary" variant="flat" @click="showDetailsModal = false">Close</v-btn>
            </VCol>
            <VCol class="d-flex justify-end">
            <VBtn color="#F44336" @click="showDeleteConfirm = true">Delete</VBtn>
            </VCol>
        </VRow>
        </VCardText>
    </VCard>
    </VDialog>



    <!-- Delete Confirmation Modal -->
    <VDialog v-model="showDeleteConfirm" max-width="400px">
      <VCard>
        <VCardTitle>Confirm Deletion</VCardTitle>
        <VCardText>Are you sure you want to delete this club?</VCardText>
        <VCardActions class="d-flex justify-end">
          <VBtn color="secondary" @click="showDeleteConfirm = false">No</VBtn>
          <VBtn color="red" @click="deleteClub">Yes</VBtn>
        </VCardActions>
      </VCard>
    </VDialog>
  </div>
</template>
