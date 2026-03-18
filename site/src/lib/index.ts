import rehype_katex from 'rehype-katex'
import rehype_stringify from 'rehype-stringify'
import remark_math from 'remark-math'
import remark_parse from 'remark-parse'
import remark_rehype from 'remark-rehype'
import { unified } from 'unified'

export { default as CodeBlock } from './CodeBlock.svelte'
export { default as DiagramCard } from './DiagramCard.svelte'
export { default as Tags } from './Tags.svelte'

const md_processor = unified()
  .use(remark_parse)
  .use(remark_math)
  .use(remark_rehype)
  .use(rehype_katex)
  .use(rehype_stringify)

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
const yaml_data = import.meta.glob<YamlMetadata>(`$assets/**/*.yml`, {
  eager: true,
  import: `default`,
})
const code_files = import.meta.glob<string>([`$assets/**/*.tex`, `$assets/**/*.typ`], {
  eager: true,
  query: `?raw`,
  import: `default`,
})
const asset_files = import.meta.glob<string>(
  [`$assets/**/*.png`, `$assets/**/*.pdf`, `$assets/**/*.svg`],
  { eager: true, query: `?url`, import: `default` },
)
// enhanced images return complex objects, typed as string per Diagram type TODO
const image_files = import.meta.glob<string>(`$assets/**/*.png`, {
  eager: true,
  query: { enhanced: true },
  import: `default`,
})

// Process YAML files to create figure data
export const diagrams = Object.entries(yaml_data)
  .filter(([_path, metadata]) => !metadata.hide)
  .map(([path, metadata]): Diagram => {
    const slug = path.split(`/`)[2] ?? ``
    const figure_basename = `../assets/${slug}/${slug}`

    // Check if .tex or .typ file exists and get its content
    const tex_path = `${figure_basename}.tex`
    const typ_path = `${figure_basename}.typ`
    const code = { tex: code_files[tex_path], typst: code_files[typ_path] }

    const tags = [
      ...new Set([
        ...(metadata.tags ?? []),
        ...(typ_path in code_files ? [`cetz`] : []),
        ...(tex_path in code_files ? [`tikz`] : []),
      ]),
    ]

    const description = metadata.description
      ? md_processor.processSync(metadata.description).toString()
      : metadata.description

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

    return Object.assign({}, metadata, {
      slug,
      code,
      tags,
      description,
      downloads,
      images,
    })
  })

export const tags = Object.entries(
  diagrams
    .flatMap((diagram) => diagram.tags)
    .reduce(
      (acc, el) => {
        acc[el] = (acc[el] ?? 0) + 1
        return acc
      },
      {} as Record<string, number>,
    ),
)
  .filter(([, count]) => count > 2)
  .toSorted(([t1], [t2]) => t1.localeCompare(t2))
