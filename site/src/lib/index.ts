import rehype_katex from 'rehype-katex'
import rehype_stringify from 'rehype-stringify'
import remark_math from 'remark-math'
import remark_parse from 'remark-parse'
import remark_rehype from 'remark-rehype'
import { unified } from 'unified'

export { default as Card } from './Card.svelte'
export { default as CodeBlock } from './CodeBlock.svelte'
export { default as Tags } from './Tags.svelte'

export type Diagram = {
  slug: string
  downloads: string[]
  code: { tex?: string; typst?: string }
  images: {
    hd: string // TODO fix type, actual is {sources: png: string, avif, string, ...}
    sd: string
  }
} & YamlMetadata

export type YamlMetadata = {
  title: string
  tags: string[]
  description: string | null
  creator?: string
  creator_url?: string
  url?: string
  date?: string
  hide?: boolean
}

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
export const diagrams = Object.entries(yaml_data)
  .filter(([_path, metadata]) => !metadata.hide)
  .map(([path, metadata]) => {
    const slug = path.split(`/`)[2] // get directory name
    const figure_basename = `../assets/${slug}/${slug}`

    // Check if .tex or .typ file exists and get its content
    const tex_path = `${figure_basename}.tex`
    const typ_path = `${figure_basename}.typ`
    const code = { tex: code_files[tex_path], typst: code_files[typ_path] }

    let { tags = [] } = metadata
    // Add typst and cetz tags if applicable
    if (typ_path in code_files) {
      tags = [...new Set([...tags, `cetz`])]
    }
    if (tex_path in code_files) {
      tags = [...new Set([...tags, `tikz`])]
    }

    // Create new metadata object with updated tags
    metadata.tags = tags

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
  }) as Diagram[]
