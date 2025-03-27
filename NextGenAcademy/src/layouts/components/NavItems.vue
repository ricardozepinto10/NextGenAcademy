<script setup>
import { ref, onMounted } from 'vue'
import { useSupabase } from '@/composables/useSupabase'  // Correct import path for your useSupabase.js

import VerticalNavSectionTitle from '@/@layouts/components/VerticalNavSectionTitle.vue'
import VerticalNavLink from '@layouts/components/VerticalNavLink.vue'

const { user, setupUser } = useSupabase()  // Access user and setupUser from useSupabase

onMounted(async () => {
  await setupUser()  // Fetch the user data when the component is mounted
})
</script>

<template>
  <!-- Only show the links if the user is NOT a SuperAdmin -->
  <template v-if="user && user.role !== 'superadmin'">
    <!--  Dashboard -->
    <VerticalNavLink
      :item="{
        title: 'Dashboard',
        icon: 'ri-home-smile-line',
        to: '/dashboard',
      }"
    />
    <VerticalNavLink
      :item="{
        title: 'User Settings',
        icon: 'ri-user-5-line',
        to: '/account-settings',
      }"
    />

    <!-- The Club -->
    <VerticalNavSectionTitle
      :item="{
        heading: 'The Club',
      }"
    />
    <VerticalNavLink
      :item="{
        title: 'Players',
        icon: 'ri-user-line',
        to: '/players',     
      }"
    />
    <VerticalNavLink
      :item="{
        title: 'Staff',
        icon: 'ri-user-line',
        to: '/staff',     
      }"
    />
    <VerticalNavLink
      :item="{
        title: 'Teams',
        icon: 'ri-wechat-line',
        to: '/teams',
      }"
    />
    <VerticalNavLink
      :item="{
        title: 'Calendar',
        icon: 'ri-calendar-line',
        to: '/calendar',   
      }"
    />
  </template>

  <!-- If the user is a SuperAdmin, show only the SuperAdmin page link -->
  <template v-else>
    <VerticalNavLink
      :item="{
        title: 'SuperAdmin',
        icon: 'ri-shield-star-line',
        to: '/superadmin',
      }"
    />
  </template>
</template>
