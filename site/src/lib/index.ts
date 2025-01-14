export { default as Card } from './Card.svelte'
export { default as CodeBlock } from './CodeBlock.svelte'
export { default as Tags } from './Tags.svelte'

export type Diagram = {
  slug: string
  downloads: string[]
  code: string
  images: {
    hd: string // TODO fix type, actual is {sources: png: string, avif, string, ...}
    sd: string
  }
} & YamlMetadata

export type YamlMetadata = {
  title: string
  tags: string[]
  description: string | null
  creator?: string
  creator_url?: string
  url?: string
  date?: string
}
