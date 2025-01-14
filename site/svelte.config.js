import adapter from '@sveltejs/adapter-static'
import preprocess from 'svelte-preprocess'

/** @type {import('@sveltejs/kit').Config} */
export default {
  preprocess: preprocess(),

  kit: {
    adapter: adapter(),

    files: {
      assets: `../assets`,
    },

    alias: {
      $root: `.`,
      $assets: `../assets`,
    },
  },
}
