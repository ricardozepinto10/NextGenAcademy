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
  code: '', // Club code
  privacyPolicies: false,
})

const vuetifyTheme = useTheme()
const authThemeMask = computed(() => vuetifyTheme.global.name.value === 'light' ? authV1MaskLight : authV1MaskDark)

const isPasswordVisible = ref(false)

// Function to handle registration
const register = async () => {
  if (!form.value.privacyPolicies) return

  try {
    const response = await registerUser(form.value)
    
    if (response.success) {
      router.push('/') // Redirect to homepage after successful registration
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

      <VCardText class="pt-2">
        <h4 class="text-h4 mb-1">Adventure starts here 🚀</h4>
        <p class="mb-0">Make your app management easy and fun!</p>
      </VCardText>

      <VCardText>
        <VForm @submit.prevent="register">
          <VRow>
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

            <!-- Privacy Policy -->
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

            <!-- Login Instead -->
            <VCol cols="12" class="text-center text-base">
              <span>Already have an account?</span>
              <RouterLink class="text-primary ms-2" to="login">Sign in instead</RouterLink>
            </VCol>

            <VCol cols="12" class="d-flex align-center">
              <VDivider />
              <span class="mx-4">or</span>
              <VDivider />
            </VCol>

            <!-- Auth Providers -->
            <VCol cols="12" class="text-center">
              <AuthProvider />
            </VCol>
          </VRow>
        </VForm>
      </VCardText>
    </VCard>

    <VImg class="auth-footer-start-tree d-none d-md-block" :src="authV1Tree" :width="250" />
    <VImg :src="authV1Tree2" class="auth-footer-end-tree d-none d-md-block" :width="350" />
    <VImg class="auth-footer-mask d-none d-md-block" :src="authThemeMask" />
  </div>
</template>

<style lang="scss">
@use "@core/scss/template/pages/page-auth";
</style>
