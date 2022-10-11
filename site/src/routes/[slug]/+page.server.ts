import tikz_figures from '$lib/tikz-figures.json'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params

  const fig_idx = tikz_figures.findIndex((fig) => fig.slug === slug)
  if (fig_idx === -1) {
    throw error(404, { message: `No figure found for slug ${slug}` })
  }
  // wrap around start/end of array
  const prev_idx = (fig_idx - 1 + tikz_figures.length) % tikz_figures.length
  const next_idx = (fig_idx + 1) % tikz_figures.length

  const prev_fig = tikz_figures[prev_idx]
  const next_fig = tikz_figures[next_idx]
  const tikz_figure = tikz_figures[fig_idx]

  return { prev_fig, tikz_figure, next_fig }
}
