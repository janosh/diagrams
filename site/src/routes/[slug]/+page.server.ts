import tikz_figures from '$lib/tikz-figures'
import { error, PageServerLoad } from '@sveltejs/kit'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params

  const tikz_figure = tikz_figures.find((fig) => fig.slug === slug)

  if (tikz_figure) return { tikz_figure }
  throw error(404)
}
