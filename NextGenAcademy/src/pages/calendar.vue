<script setup>
import { ref } from 'vue'
import CalendarDashboard from '@/views/dashboard/CalendarDashboard.vue'
import AddEventModal from '@/views/modals/AddEventModal.vue'

const showAddEventModal = ref(false)

const handleAddEvent = () => {
  showAddEventModal.value = true
}
</script>

<template>
  <VRow class="match-height">
    <VCol cols="12">
      <div class="button-row">
        <VBtn @click="handleAddEvent" color="primary">Add Event</VBtn>
      </div>

      <CalendarDashboard />
    </VCol>
  </VRow>

  <!-- AddEventModal with v-model for controlling visibility -->
  <AddEventModal v-model="showAddEventModal" />
</template>

<style scoped>
.button-row {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}
</style>