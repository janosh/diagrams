import { RequestHandler } from '@sveltejs/kit'
import texFiles from '../texFiles'

export const get: RequestHandler = ({ params }) => {
  const { slug } = params

  const texFile = texFiles.find((itm) => itm.slug === slug)

  if (texFile) return { body: texFile }

  // Not returning is equivalent to an explicit 404 response.
  // https://kit.svelte.dev/docs#routing-endpoints
}
