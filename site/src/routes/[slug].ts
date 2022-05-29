import { RequestHandler } from '@sveltejs/kit'
import tikz_figures from '../tikz-figures'

export const get: RequestHandler = ({ params }) => {
  const { slug } = params

  const tikz_figure = tikz_figures.find((fig) => fig.slug === slug)

  if (tikz_figure) return { body: { tikz_figure } }
  else return { status: 404 }
}
