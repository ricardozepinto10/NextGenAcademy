<script setup>
import VerticalNavSectionTitle from '@/@layouts/components/VerticalNavSectionTitle.vue'
import VerticalNavLink from '@layouts/components/VerticalNavLink.vue'
</script>

<template>
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
      title: 'Chat',
      icon: 'ri-wechat-line',
      target: '_blank',
       
       
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
