export const routes = [
  { path: '/', redirect: '/dashboard' },
  {
    path: '/',
    component: () => import('@/layouts/default.vue'),
    children: [
      {
        path: 'dashboard',
        component: () => import('@/pages/dashboard.vue'),
        meta: { requiresAuth: true }, // 🔒 Protected Route
      },
      {
        path: 'account-settings',
        component: () => import('@/pages/account-settings.vue'),
        meta: { requiresAuth: true }, // 🔒 Protected Route
      },
      {
        path: 'players',
        component: () => import('@/pages/players.vue'),
        meta: { requiresAuth: true }, // 🔒 Protected Route
      },
      {
        path: 'calendar',
        component: () => import('@/pages/calendar.vue'),
        meta: { requiresAuth: true }, // 🔒 Protected Route
      },
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
