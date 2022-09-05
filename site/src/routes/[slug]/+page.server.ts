import { error, PageServerLoad } from '@sveltejs/kit'
import tikz_figures from '../../tikz-figures'

export const load: PageServerLoad = ({ params }) => {
  const { slug } = params

  const tikz_figure = tikz_figures.find((fig) => fig.slug === slug)

  if (tikz_figure) return { tikz_figure }
  throw error(404)
}
