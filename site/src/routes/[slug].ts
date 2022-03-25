import { RequestHandler } from '@sveltejs/kit'
import texFiles from '../texFiles'

export const get: RequestHandler = ({ params }) => {
  const { slug } = params

  const texFile = texFiles.find((itm) => itm.slug === slug)

  if (texFile) return { body: { texFile } }
  else return { status: 404 }
}
