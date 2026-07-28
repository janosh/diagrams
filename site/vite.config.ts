import yaml from '@rollup/plugin-yaml'
import { enhancedImages } from '@sveltejs/enhanced-img'
import { sveltekit } from '@sveltejs/kit/vite'
import { load as load_yaml } from 'js-yaml'
import { compile } from 'mdsvex'
import { globSync, readFileSync } from 'node:fs'
import { basename, dirname, resolve } from 'node:path'
import { katex_preprocess } from 'svelte-widgets/katex'
import { make_config } from 'svelte-widgets/vite-config'
import { defineConfig } from 'vite-plus'

const DESCRIPTIONS_ID = `virtual:descriptions`
const RESOLVED_ID = `\0${DESCRIPTIONS_ID}`
const MD_FILE = `description.md`
const assets_dir = resolve(import.meta.dirname, `../assets`)

// katex before/after around mdsvex so KaTeX HTML (with `{` / `}`) never hits the Svelte
// parser — before stashes rendered math in private-use slots; after emits `{@html …}`,
// which we unwrap again since we inject HTML, not a Svelte component.
const katex = katex_preprocess({ throwOnError: false })
const svelte_html_expr = /\{@html (?<json>"(?:\\.|[^"\\])*")\}/gu

const render_description = async (source: string): Promise<string> => {
  const { code } = katex.before.markup({ content: source, filename: MD_FILE })
  const opts = { filename: MD_FILE, extensions: [`.md`], smartypants: false }
  const compiled = await compile(code, opts)
  if (!compiled) throw new Error(`mdsvex failed on description: ${source.slice(0, 120)}`)
  return katex.after
    .markup({ content: compiled.code })
    .code.replace(svelte_html_expr, (_match, json: string) => JSON.parse(json) as string)
    .trim()
}

export default defineConfig({
  ...make_config(), // shared lint/fmt/build/staged
  plugins: [
    {
      // Render diagram descriptions to HTML up front and serve the slug -> HTML map as a
      // virtual module. Has to happen here, not in $lib: mdsvex needs `util.inherits` and
      // the katex preprocessor needs `node:crypto`, both of which Vite stubs out in the
      // browser, so importing them from app code throws on page load.
      name: `diagram-descriptions`,
      resolveId: (id) => (id === DESCRIPTIONS_ID ? RESOLVED_ID : null),
      async load(id) {
        if (id !== RESOLVED_ID) return null
        const rendered: Record<string, string> = {}
        for (const path of globSync(`${assets_dir}/*/*.yml`).toSorted()) {
          this.addWatchFile(path) // re-render when a description is edited
          const { description } = load_yaml(readFileSync(path, `utf-8`)) as {
            description?: string | null
          }
          if (description?.trim()) {
            rendered[basename(dirname(path))] = await render_description(description)
          }
        }
        return `export default ${JSON.stringify(rendered)}`
      },
    },
    {
      // serve .tex/.typ files as raw text so rolldown doesn't try to parse them as JS
      name: `raw-text-loader`,
      enforce: `pre`,
      load(id) {
        const clean_id = id.split(`?`)[0]
        if (clean_id.endsWith(`.tex`) || clean_id.endsWith(`.typ`))
          return `export default ${JSON.stringify(readFileSync(clean_id, `utf-8`))}`
        return null
      },
    },
    enhancedImages(),
    sveltekit(),
    yaml(),
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
})
