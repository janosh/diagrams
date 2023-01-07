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
