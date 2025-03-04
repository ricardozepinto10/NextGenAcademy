<template>
  <VList>
    <VListItem>
      <VListItemTitle>1st Equipment</VListItemTitle>
      <VListItemSubtitle>{{ equipment?.first_equipment }}</VListItemSubtitle>
    </VListItem>
    <VListItem>
      <VListItemTitle>2nd Equipment</VListItemTitle>
      <VListItemSubtitle>{{ equipment?.second_equipment }}</VListItemSubtitle>
    </VListItem>
    <VListItem>
      <VListItemTitle>Tracksuit</VListItemTitle>
      <VListItemSubtitle>{{ equipment?.tracksuit }}</VListItemSubtitle>
    </VListItem>
    <VListItem>
      <VListItemTitle>Bag</VListItemTitle>
      <VListItemSubtitle>{{ equipment?.bag }}</VListItemSubtitle>
    </VListItem>
    <VListItem>
      <VListItemTitle>Training Equipment</VListItemTitle>
      <VListItemSubtitle>{{ equipment?.training_equipment }}</VListItemSubtitle>
    </VListItem>
  </VList>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'

const props = defineProps({ playerId: Number })
const equipment = ref({})

const fetchEquipment = async () => {
  const { data, error } = await supabase
    .from('player_equipment')
    .select('*')
    .eq('player_id', props.playerId)
    .single()

  if (!error) equipment.value = data
}

onMounted(fetchEquipment)
</script>
