import { filtered_figs } from '$lib/stores'
import { error } from '@sveltejs/kit'
import { get } from 'svelte/store'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params
  const items = get(filtered_figs)

  const idx = items.findIndex((itm) => itm.slug === slug)
  if (idx === -1) {
    throw error(404, `Page '${slug}' not found`)
  }
  // wrap around start/end of array
  const prev_idx = (idx - 1 + items.length) % items.length
  const next_idx = (idx + 1) % items.length

  const prev = items[prev_idx]
  const next = items[next_idx]
  const current = items[idx]

  return { prev, current, next }
}
