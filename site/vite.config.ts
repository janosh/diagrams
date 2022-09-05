import { sveltekit } from '@sveltejs/kit/vite'
import Icons from 'unplugin-icons/vite'

export default {
  plugins: [sveltekit(), Icons({ compiler: `svelte`, autoInstall: true })],

  server: {
    port: 3000,
  },

  preview: {
    port: 3000,
  },
}
