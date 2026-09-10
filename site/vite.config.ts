import adapter from '@sveltejs/adapter-static'
import { enhancedImages } from '@sveltejs/enhanced-img'
import { sveltekit } from '@sveltejs/kit/vite'
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'
import { assert_ok, create_markdown } from 'svelte-widgets/markdown'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { make_config } from 'svelte-widgets/vite-config'
import { yaml_plugin } from 'svelte-widgets/yaml'
import type { Plugin } from 'vite'
import type { YamlMetadata } from './src/lib/index.ts'

// passed inline to sveltekit() (Kit >= 2.62) so no separate svelte.config.ts is needed;
// kit options (adapter, alias) sit at the top level rather than under `kit`
const svelte_config = {
  preprocess: vitePreprocess(),
  adapter: adapter(),
  alias: { $root: `.`, $assets: `../assets` },
}

const engine = create_markdown({ math: { throwOnError: false }, frontmatter: false })
const layout_path = fileURLToPath(
  new URL(`../assets/_shared/layout.typ`, import.meta.url),
)

export default {
  resolve: { dedupe: [`svelte`] },
  ...make_config(), // shared lint/fmt/build/staged
  plugins: [
    {
      // serve .tex/.typ files as raw text so rolldown doesn't try to parse them as JS
      name: `raw-text-loader`,
      enforce: `pre`,
      load(id) {
        const clean_id = id.split(`?`)[0]
        if (clean_id.endsWith(`.tex`) || clean_id.endsWith(`.typ`)) {
          // Keep gallery source self-contained while the repository shares panel code.
          const source = readFileSync(clean_id, `utf-8`).replaceAll(
            /^#import "\.\.\/_shared\/layout\.typ": .+$/gmu,
            () => {
              this.addWatchFile(layout_path)
              return readFileSync(layout_path, `utf-8`).trimEnd()
            },
          )
          return `export default ${JSON.stringify(source)}`
        }
        return null
      },
    } satisfies Plugin,
    enhancedImages(),
    sveltekit(svelte_config),
    yaml_plugin({
      // Render within the YAML import so source Markdown and its parser stay out of
      // the client bundle. Vite watches the imported file for metadata and prose edits.
      async transform(data, filename) {
        const metadata = data as YamlMetadata
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
