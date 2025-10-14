import { createApp } from 'vue'
import { createPinia } from 'pinia'
// import the Vue binding for maska from the package's vue entry
import { vMaska } from 'maska/vue'

// Import Tailwind CSS
import './assets/main.css'

import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(createPinia())
app.use(router)

// Register maska directive globally so templates can use v-maska
app.directive('maska', vMaska)

app.mount('#app')
