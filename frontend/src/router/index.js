import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import LandingView from '../views/LandingView.vue'
import LocationView from '../views/LocationView.vue'
import axios from 'axios';

// Armazena todas as rotas (páginas) do sistema
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'login',
      component: LoginView
    },
    {
      path: '/landing',
      name: 'landing',
      component: LandingView
    },
    {
      path: '/location',
      name: 'location',
      component: LocationView
    }
  ],
})

router.beforeEach(async (to, from) => {
  if (to.name === 'login') {
    return true
  }

  const token = localStorage.getItem('token');
  if (!token) {
    return {
      name: 'login'
    }
  }

  // Check token validity before allowing navigation
  try {
    await checkTokenAuthenticity(token);
    return true; // Token is valid, proceed to the route
  } catch (error) {
    // Token is invalid, redirect to login
    return { name: 'login' };
  }
})

const checkTokenAuthenticity = async (token) => {
  try {
    await axios.get('/api/user', { // Using proxy, no need for full URL
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
  } catch (error) {
      localStorage.removeItem('token')
      throw error; // Re-throw to be caught in beforeEach
  }
}

export default router
