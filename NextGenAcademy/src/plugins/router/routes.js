import { createRouter, createWebHistory } from 'vue-router'
import SuperAdminPage from '@/pages/superadmin.vue'  // SuperAdmin specific page
import DashboardPage from '@/pages/dashboard.vue'  // Default dashboard page
import { useSupabase } from '@/composables/useSupabase'

const { user, getUser } = useSupabase()

export const routes = [
  { path: '/', redirect: '/dashboard' },
  {
    path: '/',
    component: () => import('@/layouts/default.vue'),
    children: [
      {
        path: 'dashboard',
        component: DashboardPage,
        meta: { requiresAuth: true },
      },
      {
        path: 'account-settings',
        component: () => import('@/pages/account-settings.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'players',
        component: () => import('@/pages/players.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'staff',
        component: () => import('@/pages/staff.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'teams',
        component: () => import('@/pages/teams.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'calendar',
        component: () => import('@/pages/calendar.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'superadmin',
        component: SuperAdminPage,  // SuperAdmin only page
        meta: { requiresSuperAdmin: true },
        beforeEnter: async (to, from, next) => {
          const currentUser = await getUser()  // Fetch user data
          if (currentUser && currentUser.role === 'superadmin') {
            return next()  // Allow access to superadmin page
          } else {
            return next('/dashboard')  // Redirect to dashboard for non-superadmins
          }
        }
      }
    ],
  },
  {
    path: '/',
    component: () => import('@/layouts/blank.vue'),
    children: [
      {
        path: 'login',
        component: () => import('@/pages/login.vue'),
      },
      {
        path: 'register',
        component: () => import('@/pages/register.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Global route guard to check user role and authentication
router.beforeEach(async (to, from, next) => {
  const currentUser = await getUser()  // Get current user data

  // If the route requires authentication
  if (to.meta.requiresAuth) {
    if (!currentUser) {
      return next('/login')  // Redirect to login if not authenticated
    }
    // If the route requires SuperAdmin role
    if (to.meta.requiresSuperAdmin && currentUser.role !== 'superadmin') {
      return next('/dashboard')  // Redirect non-SuperAdmin users to the dashboard
    }
    return next()
  }

  next()
})

export default router
