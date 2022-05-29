export type TexFile = {
  title: string
  slug: string
  width: number
  height: number
  downloads: string[]
  tags: string[]
  description: string | null
  code: string
  creator?: string
  creator_url?: string
  url?: string
  date?: Date
}
