export { default as Card } from './Card.svelte'
export { default as CodeBlock } from './CodeBlock.svelte'
export { default as Tags } from './Tags.svelte'

export type TikzFigure = {
  title: string
  slug: string
  width: number
  height: number
  downloads: string[]
  code: string
} & YamlMetadata

export type YamlMetadata = {
  tags: string[]
  description: string | null
  creator?: string
  creator_url?: string
  url?: string
  date?: Date
}
