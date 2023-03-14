import { filtered_figs } from '$lib/stores'
import { error } from '@sveltejs/kit'
import { get } from 'svelte/store'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const items = get(filtered_figs)

  const idx = items.findIndex((itm) => itm.slug === slug)
  if (idx === -1) throw error(404, `Page '${slug}' not found`)
  const fig = items[idx]

  return { fig, items, slug }
}
