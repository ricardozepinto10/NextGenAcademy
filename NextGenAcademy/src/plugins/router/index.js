import { createRouter, createWebHistory } from 'vue-router'
import { routes } from './routes'
import { supabase } from '@/supabase'



const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

// Navigation Guard for Authentication
router.beforeEach(async (to, from, next) => {
  const { data: { session } } = await supabase.auth.getSession()

  if (to.meta.requiresAuth && !session) {
    next('/login')
  } else if (to.path === '/login' && session) {
    next('/dashboard')
  } else {
    next()
  }
})

export default function (app) {
  app.use(router)
}

export { router }
