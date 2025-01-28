import yaml from '@rollup/plugin-yaml'
import { enhancedImages } from '@sveltejs/enhanced-img'
import { sveltekit } from '@sveltejs/kit/vite'
import type { UserConfig } from 'vite'

export default {
  plugins: [sveltekit(), yaml(), enhancedImages()],

  server: {
    fs: {
      allow: [`..`], // needed to import package.json
    },
    port: 3000,
  },

  preview: {
    port: 3000,
  },
} satisfies UserConfig
