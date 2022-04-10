import { RequestHandler } from '@sveltejs/kit'
import tikz_figures from '../tikz-figures'

export const get: RequestHandler = ({ params }) => {
  const { slug } = params

  const texFile = tikz_figures.find((fig) => fig.slug === slug)

  if (texFile) return { body: { texFile } }
  else return { status: 404 }
}
