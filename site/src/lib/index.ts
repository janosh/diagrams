import { building } from '$app/environment'

export { default as CodeBlock } from './CodeBlock.svelte'
export { default as DiagramCard } from './DiagramCard.svelte'
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
  preserve_colors?: boolean
}

// YAML imports already contain descriptions rendered to HTML by the Vite plugin.
// Rolldown leaves eager glob imports wrapped as modules; unwrap .default below.
const yaml_data = import.meta.glob<{ default: YamlMetadata }>(`$assets/**/*.yml`, {
  eager: true,
})
const code_files = import.meta.glob<{ default: string }>(
  [`$assets/**/*.tex`, `$assets/**/*.typ`],
  { eager: true, query: `?raw` },
)
const asset_files = import.meta.glob<{ default: string }>(
  [`$assets/**/*.png`, `$assets/**/*.pdf`, `$assets/**/*.svg`, `!$assets/**/*-dark.png`],
  { eager: true, query: `?url` },
)
const image_files = import.meta.glob<{ default: string }>(
  [`$assets/**/*.png`, `!$assets/**/*-dark.png`],
  {
    eager: true,
    // Density descriptors are lost by imagetools' cache; use stable width descriptors.
    query: { enhanced: true, basePixels: 0 },
  },
)

// Process YAML files to create figure data
export const diagrams: Diagram[] = Object.entries(yaml_data)
  .filter(([_path, { default: metadata }]) => !metadata.hide)
  .map(([path, { default: metadata }]): Diagram => {
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

    // store extensions, not ?url paths — content hashes would break `.includes('-hd.png')`
    const downloads = ([`.png`, `-hd.png`, `.pdf`, `.svg`] as const).filter(
      (ext) => `${figure_basename}${ext}` in asset_files,
    )
    // build-time data-quality signal (building guard keeps it out of the client bundle)
    if (building && downloads.length < 2) {
      console.warn(`Diagram '${slug}' has only ${downloads.length} download asset(s)`)
    }

    const images = {
      hd: image_files[`${figure_basename}-hd.png`]?.default,
      sd: image_files[`${figure_basename}.png`]?.default,
    }
    return { ...metadata, slug, code, tags, downloads, images }
  })

// title-sorted view of diagrams; stable order for prev/next nav, the home grid and
// the prerendered server load (avoids coupling those to the client filter state). Fixed
// `en` collator so build (Node) and client agree, avoiding a hydration reorder
const diagram_collator = new Intl.Collator(`en`, { numeric: true })
export const sorted_diagrams = diagrams.toSorted(
  (d1, d2) =>
    diagram_collator.compare(d1.title, d2.title) ||
    diagram_collator.compare(d1.slug, d2.slug),
)

const tag_counts = new Map<string, number>()
for (const tag of diagrams.flatMap((diagram) => diagram.tags)) {
  tag_counts.set(tag, (tag_counts.get(tag) ?? 0) + 1)
}
export const tags = [...tag_counts]
  .filter(([, count]) => count > 2)
  .toSorted(([t1], [t2]) => t1.localeCompare(t2))
