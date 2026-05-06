import { filtered_diagrams } from '$lib/state.svelte'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const diagrams = filtered_diagrams()

  const diagram = diagrams.find((itm) => itm.slug === slug)
  if (!diagram) error(404, `Page '${slug}' not found`)

  // diagrams passed as well for rendering links to next/previous diagrams
  return { diagram, diagrams, slug }
}
