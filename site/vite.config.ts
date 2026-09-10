import adapter from '@sveltejs/adapter-static'
import { enhancedImages } from '@sveltejs/enhanced-img'
import { sveltekit } from '@sveltejs/kit/vite'
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'
import { assert_ok, create_markdown } from 'svelte-widgets/markdown'
import { readFileSync } from 'node:fs'
import { make_config } from 'svelte-widgets/vite-config'
import { yaml_plugin } from 'svelte-widgets/yaml'
import type { YamlMetadata } from './src/lib/index.ts'

// passed inline to sveltekit() (Kit >= 2.62) so no separate svelte.config.ts is needed;
// kit options (adapter, alias) sit at the top level rather than under `kit`
const svelte_config = {
  preprocess: vitePreprocess(),
  adapter: adapter(),
  alias: { $root: `.`, $assets: `../assets` },
}

const engine = create_markdown({ math: { throwOnError: false }, frontmatter: false })

export default {
  resolve: { dedupe: [`svelte`] },
  ...make_config(), // shared lint/fmt/build/staged
  plugins: [
    enhancedImages(),
    sveltekit(svelte_config),
    yaml_plugin({
      // Render within the YAML import so source Markdown and its parser stay out of
      // the client bundle. Vite watches the imported file for metadata and prose edits.
      async transform(data, filename) {
        const metadata = data as YamlMetadata
        // PNG stores intrinsic dimensions in its IHDR header (before pixel data).
        // The AVIF is encoded at exactly the same dimensions as this lossless master.
        if (!metadata.hide) {
          const png_path = filename.replace(/\.yml$/u, `.png`)
          const png = readFileSync(png_path)
          if (
            png.toString(`hex`, 0, 8) !== `89504e470d0a1a0a` ||
            png.toString(`ascii`, 12, 16) !== `IHDR`
          )
            throw new Error(`Invalid PNG header: ${png_path}`)
          metadata.image_width = png.readUInt32BE(16)
          metadata.image_height = png.readUInt32BE(20)
        }
        const { description } = metadata
        if (!description?.trim()) return { ...metadata, description: null }
        return {
          ...metadata,
          description: assert_ok(await engine.render(description, { filename })),
        }
      },
    }),
  ],
  server: {
    fs: {
      allow: [`..`], // needed to import package.json
    },
    port: 3000,
  },
  preview: {
    port: 3000,
  },
}
