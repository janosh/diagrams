import { building } from '$app/environment'
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
// rolldown doesn't unwrap `import: 'default'` for query imports, so access .default at usage
const code_files = import.meta.glob<{ default: string }>(
  [`$assets/**/*.tex`, `$assets/**/*.typ`],
  { eager: true, query: `?raw` },
)
const asset_files = import.meta.glob<{ default: string }>(
  [`$assets/**/*.png`, `$assets/**/*.pdf`, `$assets/**/*.svg`],
  { eager: true, query: `?url` },
)
const image_files = import.meta.glob<{ default: string }>(`$assets/**/*.png`, {
  eager: true,
  query: { enhanced: true },
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
    const code = {
      tex: code_files[tex_path]?.default,
      typst: code_files[typ_path]?.default,
    }

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
      asset_files[`${figure_basename}-hd.png`]?.default,
      asset_files[`${figure_basename}.png`]?.default,
      asset_files[`${figure_basename}.pdf`]?.default,
      asset_files[`${figure_basename}.svg`]?.default,
    ].filter(Boolean)
    // build-time data-quality signal (building guard keeps it out of the client bundle)
    if (building && downloads.length < 2) {
      console.warn(`Diagram '${slug}' has only ${downloads.length} download asset(s)`)
    }

    const images = {
      hd: image_files[`${figure_basename}-hd.png`]?.default,
      sd: image_files[`${figure_basename}.png`]?.default,
    }
    return { ...metadata, slug, code, tags, description, downloads, images }
  })

// title-sorted view of diagrams; stable order for prev/next nav, the home grid and
// the prerendered server load (avoids coupling those to the client filter state). Fixed
// `en` collator so build (Node) and client agree, avoiding a hydration reorder
const diagram_collator = new Intl.Collator(`en`, { numeric: true })
export const sorted_diagrams = [...diagrams].sort(
  (d1, d2) =>
    diagram_collator.compare(d1.title, d2.title) ||
    diagram_collator.compare(d1.slug, d2.slug),
)

export const tags = Object.entries(
  diagrams
    .flatMap((diagram) => diagram.tags)
    .reduce<Record<string, number>>((acc, el) => {
      acc[el] = (acc[el] ?? 0) + 1
      return acc
    }, {}),
)
  .filter(([, count]) => count > 2)
  .toSorted(([t1], [t2]) => t1.localeCompare(t2))
