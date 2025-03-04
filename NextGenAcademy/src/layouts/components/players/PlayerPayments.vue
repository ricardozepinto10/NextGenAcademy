<template>
    <VList>
      <VListItem v-for="payment in payments" :key="payment.id">
        <VListItemTitle>{{ payment.month }} - {{ payment.year }}</VListItemTitle>
        <VListItemSubtitle>Status: {{ payment.status }}</VListItemSubtitle>
      </VListItem>
    </VList>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import { supabase } from '@/supabase'
  
  const props = defineProps({ playerId: Number })
  const payments = ref([])
  
  const fetchPayments = async () => {
    const { data, error } = await supabase
      .from('player_payments')
      .select('*')
      .eq('player_id', props.playerId)
  
    if (!error) payments.value = data
  }
  
  onMounted(fetchPayments)
  </script>
  