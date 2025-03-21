<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'

const newEvent = ref({
  title: '',
  description: '',
  team: null,  // this will hold the team ID
  startDateTime: '',
  endDateTime: ''
})

const teams = ref([])
const userClubId = ref(null)
const showAddEventModal = ref(false)  // controls modal visibility
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

// Fetch teams once modal is mounted
onMounted(fetchUserClub);

const submitEvent = async () => {
  // Insert into the trainings table
  const { title, description, team, startDateTime, endDateTime } = newEvent.value;
  
  const { error } = await supabase
    .from('trainings')
    .insert([{
      title,
      description,
      team_id: team,  // Insert the team ID (team object contains the full data)
      start_datetime: startDateTime,
      end_datetime: endDateTime,
    }]);

  if (error) {
    console.error("Error inserting event:", error.message);
  } else {
    console.log("Event inserted successfully");
    showAddEventModal.value = false;  // Close modal after submit
  }
}




const resetForm = () => {
  newEvent.value = { title: '', description: '', team: null, startDateTime: '', endDateTime: '' }
}
</script>

<template>
  <VDialog v-model="showAddEventModal" max-width="500px">
    <VCard>
      <VCardTitle>Add New Event</VCardTitle>
      <VCardText>
        <VForm @submit.prevent="submitEvent">
          <VRow>
            <VCol cols="12">
              <VTextField
                v-model="newEvent.title"
                label="Title"
                placeholder="Enter event title"
                required
              />
            </VCol>

            <VCol cols="12">
              <VTextarea
                v-model="newEvent.description"
                label="Description"
                placeholder="Enter event details"
              />
            </VCol>

            <!-- Team Dropdown or display team name if only one team exists -->
            <VCol cols="12">
              <template v-if="teams.length > 1">
                <VSelect
                  v-model="newEvent.team"
                  :items="teams"
                  item-title="name"
                  item-value="value"
                  label="Select Team"
                  required
                />
              </template>
              <template v-else>
                <VTextField
                  v-model="newEvent.team"
                  label="Team"
                  :value="teams[0]?.name || ''"
                  disabled
                />
              </template>
            </VCol>

            <VCol cols="12">
              <VTextField
                v-model="newEvent.startDateTime"
                label="Start Date & Time"
                type="datetime-local"
                required
              />
            </VCol>

            <VCol cols="12">
              <VTextField
                v-model="newEvent.endDateTime"
                label="End Date & Time"
                type="datetime-local"
                required
              />
            </VCol>

            <VCol cols="12" class="d-flex gap-4">
              <VBtn type="submit" color="primary">Save</VBtn>

              <VBtn
                type="reset"
                color="secondary"
                variant="outlined"
                @click="resetForm"
              >
                Reset
              </VBtn>

              <VBtn
                color="secondary"
                variant="outlined"
                @click="showAddEventModal = false"
              >
                Cancel
              </VBtn>
            </VCol>
          </VRow>
        </VForm>
      </VCardText>
    </VCard>
  </VDialog>
</template>