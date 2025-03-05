import { filtered_diagrams } from '$lib/state.svelte'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const diagrams = filtered_diagrams()

  const idx = diagrams?.findIndex((itm) => itm.slug === slug)
  if (idx === -1) throw error(404, `Page '${slug}' not found`)
  const diagram = diagrams[idx] // figure to display on the rendered page

  // diagrams passed as well for rendering links to next/previous diagrams
  return { diagram, diagrams, slug }
}
