<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useTheme } from 'vuetify'
import { registerUser } from '@/services/registerUser.js'
import AuthProvider from '@/views/pages/authentication/AuthProvider.vue'
import authV1MaskDark from '@images/pages/auth-v1-mask-dark.png'
import authV1MaskLight from '@images/pages/auth-v1-mask-light.png'
import authV1Tree2 from '@images/pages/auth-v1-tree-2.png'
import authV1Tree from '@images/pages/auth-v1-tree.png'

const router = useRouter()
const form = ref({
  email: '',
  password: '',
  first_name: '',
  last_name: '',
  code: '',
  role: '', // Added role field
  privacyPolicies: false,
})

const vuetifyTheme = useTheme()
const authThemeMask = computed(() => vuetifyTheme.global.name.value === 'light' ? authV1MaskLight : authV1MaskDark)

const isPasswordVisible = ref(false)

const register = async () => {
  if (!form.value.privacyPolicies) return

  try {
    const response = await registerUser(form.value)

    if (response.success) {
      router.push('/')
    }
  } catch (error) {
    console.error('Registration Error:', error.message)
  }
}
</script>

<template>
  <div class="auth-wrapper d-flex align-center justify-center pa-4">
    <VCard class="auth-card pa-4 pt-7" max-width="448">
      <VCardItem class="justify-center">
        <RouterLink to="/" class="d-flex align-center gap-3">
          <h2 class="font-weight-medium text-2xl text-uppercase">
            NextGen
          </h2>
        </RouterLink>
      </VCardItem>

      <VCardText>
        <VForm @submit.prevent="register">
          <VRow>
            <!-- First Name -->
            <VCol cols="12">
              <VTextField v-model="form.first_name" label="First Name" placeholder="John" />
            </VCol>

            <!-- Last Name -->
            <VCol cols="12">
              <VTextField v-model="form.last_name" label="Last Name" placeholder="Doe" />
            </VCol>

            <!-- Email -->
            <VCol cols="12">
              <VTextField v-model="form.email" label="Email" placeholder="johndoe@email.com" type="email" />
            </VCol>

            <!-- Password -->
            <VCol cols="12">
              <VTextField
                v-model="form.password"
                label="Password"
                placeholder="············"
                :type="isPasswordVisible ? 'text' : 'password'"
                autocomplete="password"
                :append-inner-icon="isPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                @click:append-inner="isPasswordVisible = !isPasswordVisible"
              />
            </VCol>

            <!-- Club Code -->
            <VCol cols="12">
              <VTextField v-model="form.code" label="Club Code" placeholder="Enter Club Code" />
            </VCol>

            <!-- Role Selection -->
            <VCol cols="12">
              <VSelect
                v-model="form.role"
                label="Role"
                :items="['player', 'staff', 'associate']"
                placeholder="Select Role"
                clearable
              />
            </VCol>

            <VCol cols="12">
              <div class="d-flex align-center my-6">
                <VCheckbox id="privacy-policy" v-model="form.privacyPolicies" inline />
                <VLabel for="privacy-policy">
                  <span class="me-1">I agree to</span>
                  <a href="javascript:void(0)" class="text-primary">privacy policy & terms</a>
                </VLabel>
              </div>

              <VBtn block type="submit">Sign up</VBtn>
            </VCol>
          </VRow>
        </VForm>
      </VCardText>
    </VCard>
  </div>
</template>
