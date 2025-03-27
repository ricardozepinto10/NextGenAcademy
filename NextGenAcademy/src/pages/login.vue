<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { loginUser } from '@/services/auth.js' // Your login service

const router = useRouter()
const form = ref({
  email: '',
  password: '',
  remember: false,
})
const errorMessage = ref('')
const isLoading = ref(false)

const handleLogin = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const response = await loginUser(form.value.email, form.value.password)

    if (response.success) {
      const user = response.user // Now user contains the role
      if (user.role === 'superadmin') {
        router.push('/superadmin')  // Redirect SuperAdmin to the /superadmin page
      } else {
        router.push('/dashboard')  // Redirect other roles to the default dashboard
      }
    } else {
      errorMessage.value = response.message
    }
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="auth-wrapper d-flex align-center justify-center pa-4">
    <VCard class="auth-card pa-4 pt-7" max-width="448">
      <VCardItem class="justify-center">
        <h2 class="font-weight-medium text-2xl text-uppercase">
          NextGen Academy 👋🏻
        </h2>
      </VCardItem>

      <VCardText class="pt-2">
        <p class="mb-0">Please sign in to your account and start the adventure</p>
      </VCardText>

      <VCardText>
        <VForm @submit.prevent="handleLogin">
          <VRow>
            <VCol cols="12">
              <VTextField v-model="form.email" label="Email" type="email" required />
            </VCol>

            <VCol cols="12">
              <VTextField
                v-model="form.password"
                label="Password"
                placeholder="············"
                :type="isPasswordVisible ? 'text' : 'password'"
                autocomplete="password"
                :append-inner-icon="isPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                @click:append-inner="isPasswordVisible = !isPasswordVisible"
                required
              />
            </VCol>

            <VCol cols="12">
              <div class="d-flex align-center justify-space-between flex-wrap my-6">
                <VCheckbox v-model="form.remember" label="Remember me" />
                <RouterLink class="text-primary" to="/forgot-password">
                  Forgot Password?
                </RouterLink>
              </div>
            </VCol>

            <VCol cols="12">
              <VAlert v-if="errorMessage" type="error" class="mb-4">
                {{ errorMessage }}
              </VAlert>

              <VBtn block type="submit" :loading="isLoading"> Login </VBtn>
            </VCol>

            <VCol cols="12" class="text-center text-base">
              <span>New on our platform?</span>
              <RouterLink class="text-primary ms-2" to="/register">Create an account</RouterLink>
            </VCol>

            <VCol cols="12" class="d-flex align-center">
              <VDivider />
              <span class="mx-4">or</span>
              <VDivider />
            </VCol>

            <VCol cols="12" class="text-center">
              <AuthProvider />
            </VCol>
          </VRow>
        </VForm>
      </VCardText>
    </VCard>
  </div>
</template>

<style lang="scss">
@use "@core/scss/template/pages/page-auth";
</style>
