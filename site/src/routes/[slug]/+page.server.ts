import { sorted_diagrams } from '$lib'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params

  const diagram = sorted_diagrams.find((itm) => itm.slug === slug)
  if (!diagram) error(404, `Page '${slug}' not found`)

  // diagrams passed as well for rendering links to next/previous diagrams
  return { diagram, diagrams: sorted_diagrams, slug }
}
