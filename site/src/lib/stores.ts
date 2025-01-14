import rehype_katex from 'rehype-katex'
import rehype_stringify from 'rehype-stringify'
import remark_math from 'remark-math'
import remark_parse from 'remark-parse'
import remark_rehype from 'remark-rehype'
import { session_store, url_param_store } from 'svelte-zoo/stores'
import { writable } from 'svelte/store'
import { unified } from 'unified'
import type { YamlMetadata } from '.'

export const search = url_param_store(`search`, ``)

export const tag_filter_mode = session_store<`and` | `or`>(
  `tag-filter-mode`,
  `or`,
)

export const filter_tags = session_store<{ label: string; count: number }[]>(
  `filter-tags`,
  [],
)

// Load all YAML files from assets directory
const yaml_data = import.meta.glob(`$assets/**/*.yml`, {
  eager: true,
  import: `default`,
}) as Record<string, YamlMetadata>
const code_files = import.meta.glob([`$assets/**/*.tex`, `$assets/**/*.typ`], {
  eager: true,
  query: `?raw`,
  import: `default`,
})
const asset_files = import.meta.glob(
  [`$assets/**/*.png`, `$assets/**/*.pdf`, `$assets/**/*.svg`],
  { eager: true, query: `?url`, import: `default` },
)
const image_files = import.meta.glob(`$assets/**/*.png`, {
  eager: true,
  query: { enhanced: true },
  import: `default`,
})

// Process YAML files to create figure data
export const diagrams = Object.entries(yaml_data).map(([path, metadata]) => {
  const slug = path.split(`/`)[2] // get directory name
  const figure_basename = `../assets/${slug}/${slug}`

  // Check if .tex or .typ file exists and get its content
  const tex_path = `${figure_basename}.tex`
  const typ_path = `${figure_basename}.typ`
  const code = code_files[tex_path] ?? code_files[typ_path] ?? ``

  // Add typst and cetz tags if applicable
  if (!metadata.tags) metadata.tags = []

  if (code_files[typ_path]) {
    if (!metadata.tags.includes(`typst`)) metadata.tags.push(`typst`)
  }

  // Process description with remark/rehype if needed
  if (metadata.description) {
    metadata.description = unified()
      .use(remark_parse)
      .use(remark_math)
      .use(remark_rehype)
      .use(rehype_katex)
      .use(rehype_stringify)
      .processSync(metadata.description)
      .toString()
  }

  const downloads = [
    asset_files[`${figure_basename}-hd.png`],
    asset_files[`${figure_basename}.png`],
    asset_files[`${figure_basename}.pdf`],
    asset_files[`${figure_basename}.svg`],
  ].filter(Boolean)

  const images = {
    hd: image_files[`${figure_basename}-hd.png`],
    sd: image_files[`${figure_basename}.png`],
  }

  return { ...metadata, slug, code, downloads, images }
})

export const filtered_diagrams = writable(diagrams)
