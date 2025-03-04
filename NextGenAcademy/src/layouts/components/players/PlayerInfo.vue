<template>
  <div>
    <VList>
      <VListItem>
        <VListItemTitle>Full Name:</VListItemTitle>
        <VListItemSubtitle>{{ player?.first_name }} {{ player?.last_name }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Birthdate:</VListItemTitle>
        <VListItemSubtitle>{{ player?.birth_date || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Age:</VListItemTitle>
        <VListItemSubtitle>{{ calculateAge(player?.birth_date) || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Position:</VListItemTitle>
        <VListItemSubtitle>{{ player?.position || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Contact:</VListItemTitle>
        <VListItemSubtitle>{{ player?.contact || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Address:</VListItemTitle>
        <VListItemSubtitle>{{ player?.address || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>City:</VListItemTitle>
        <VListItemSubtitle>{{ player?.city || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Nationality:</VListItemTitle>
        <VListItemSubtitle>{{ player?.nationality || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Guardian Name:</VListItemTitle>
        <VListItemSubtitle>{{ player?.guardian_name || 'N/A' }}</VListItemSubtitle>
      </VListItem>

      <VListItem>
        <VListItemTitle>Guardian Contact:</VListItemTitle>
        <VListItemSubtitle>{{ player?.guardian_contact || 'N/A' }}</VListItemSubtitle>
      </VListItem>
    </VList>
  </div>
</template>

<script setup>
defineProps({
  player: Object,
})

const calculateAge = (birthdate) => {
  if (!birthdate) return 'N/A'
  const birthDate = new Date(birthdate)
  const today = new Date()
  let age = today.getFullYear() - birthDate.getFullYear()
  const monthDiff = today.getMonth() - birthDate.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--
  }
  return age
}
</script>
