import { building } from '$app/env'
import type { Picture } from '@sveltejs/enhanced-img'
import { LaTeX, Typst } from 'svelte-widgets/icons'

export { default as DiagramCard } from './DiagramCard.svelte'
export { default as Tags } from './Tags.svelte'

// Source languages, Typst first: the source viewer prefers it when a diagram has both.
// `lang` labels the source tabs; `name`, `tag` and `href` the drawing package, whose tag
// every diagram written in that language gets.
export const source_langs = {
  typ: {
    lang: `Typst`,
    name: `CeTZ`,
    tag: `cetz`,
    icon: Typst,
    href: `https://cetz-package.github.io/docs/`,
  },
  tex: { lang: `TikZ`, name: `TikZ`, tag: `tikz`, icon: LaTeX, href: `https://tikz.dev` },
} as const
export type SourceExt = keyof typeof source_langs

export type Diagram = {
  slug: string
  downloads: string[]
  source_types: SourceExt[]
  image: string
  thumbnail: Picture
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
  image_width: number
  image_height: number
}

// YAML imports already contain descriptions rendered to HTML by the Vite plugin.
// Vite's build-time glob parser requires literal strings for import/query options.
const yaml_data = import.meta.glob<YamlMetadata>(`#assets/**/*.yml`, {
  eager: true,
  import: 'default',
})
// Discover available downloads and source languages without importing their bytes.
const asset_paths = new Set(
  Object.keys(import.meta.glob(`#assets/**/*.{png,pdf,svg,tex,typ}`)),
)
const image_files = import.meta.glob<string>(
  [`#assets/**/*.avif`, `!#assets/**/*-dark.avif`],
  // Plain imports preserve the encoded file; queries activate imagetools transforms.
  { eager: true, import: 'default' },
)
const thumbnails = import.meta.glob<Picture>(
  [`#assets/*/*.png`, `!#assets/**/*-reference.png`],
  {
    eager: true,
    import: 'default',
    // Density descriptors are lost by imagetools' cache; use stable width descriptors.
    query: '?enhanced&format=avif&w=480;960&quality=85&basePixels=0',
  },
)

// Process YAML files to create figure data
export const diagrams: Diagram[] = Object.entries(yaml_data)
  .filter(([_path, metadata]) => !metadata.hide)
  .map(([path, metadata]): Diagram => {
    const slug = path.split(`/`)[2] ?? ``
    const figure_basename = `../assets/${slug}/${slug}`

    const source_types = (Object.keys(source_langs) as SourceExt[]).filter((ext) =>
      asset_paths.has(`${figure_basename}.${ext}`),
    )
    const tags = [
      ...new Set([
        ...(metadata.tags ?? []),
        ...source_types.map((ext) => source_langs[ext].tag),
      ]),
    ]

    // Downloads retain their original filenames on GitHub.
    const downloads = ([`.png`, `.pdf`, `.svg`] as const).filter((ext) =>
      asset_paths.has(`${figure_basename}${ext}`),
    )
    // build-time data-quality signal (building guard keeps it out of the client bundle)
    if (building && downloads.length < 2) {
      console.warn(`Diagram '${slug}' has only ${downloads.length} download asset(s)`)
    }

    const image = image_files[`${figure_basename}.avif`]
    const thumbnail = thumbnails[`${figure_basename}.png`]
    if (!image || !thumbnail)
      throw new Error(`Missing AVIF artwork or thumbnail for '${slug}'`)
    return { ...metadata, slug, source_types, tags, downloads, image, thumbnail }
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

export const tags = [...new Set(diagrams.flatMap((diagram) => diagram.tags))].toSorted(
  (tag_a, tag_b) => tag_a.localeCompare(tag_b),
)
