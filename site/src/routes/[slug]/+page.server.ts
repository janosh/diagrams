import { sorted_diagrams } from '$lib'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

// Source text belongs only in the requested detail page, never the shared catalog.
const code_files = import.meta.glob<string>(`$assets/**/*.{tex,typ}`, {
  eager: true,
  import: 'default',
  query: '?raw',
})

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params

  const diagram = sorted_diagrams.find((itm) => itm.slug === slug)
  if (!diagram) error(404, `Page '${slug}' not found`)

  const base_path = `../assets/${slug}/${slug}`
  const sources = diagram.source_types
    .map((ext) => ({ ext, code: code_files[`${base_path}.${ext}`] }))
    .filter((source) => source.code)
  return { diagram: { ...diagram, sources } }
}
