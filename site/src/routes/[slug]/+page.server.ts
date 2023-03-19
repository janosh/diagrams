import { filtered_figs } from '$lib/stores'
import { error } from '@sveltejs/kit'
import { get } from 'svelte/store'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const figs = get(filtered_figs)

  const idx = figs.findIndex((itm) => itm.slug === slug)
  if (idx === -1) throw error(404, `Page '${slug}' not found`)
  const fig = figs[idx]

  return { fig, figs, slug }
}
