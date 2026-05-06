import type { Config } from '@sveltejs/kit'
import adapter from '@sveltejs/adapter-static'
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'

export default {
  preprocess: vitePreprocess(),

  kit: {
    adapter: adapter(),

    alias: {
      $root: `.`,
      $assets: `../assets`,
    },
  },
} satisfies Config
