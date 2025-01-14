import { filtered_diagrams } from '$lib/stores'
import { error } from '@sveltejs/kit'
import { get } from 'svelte/store'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const diagrams = get(filtered_diagrams)

  const idx = diagrams?.findIndex((itm) => itm.slug === slug)
  if (idx === -1) throw error(404, `Page '${slug}' not found`)
  const diagram = diagrams[idx] // figure to display on the rendered page

  // diagrams passed as well for rendering links to next/previous diagrams
  return { diagram, diagrams, slug }
}
