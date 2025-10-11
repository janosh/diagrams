import { type Diagram, diagrams } from '$lib'

export const filters = $state<{
  search: string
  tag_mode: `all` | `any`
  tags: { label: string; count: number }[]
}>({ search: ``, tag_mode: `all`, tags: [] })

export const filtered_diagrams = () =>
  diagrams
    .filter((file: Diagram) => {
      const searchTerms = filters.search?.toLowerCase().split(` `)
      const matches_search = searchTerms?.every((term) =>
        JSON.stringify(file).toLowerCase().includes(term)
      )

      let matches_tags = true
      if (filters.tags.length > 0) {
        if (filters.tag_mode === `all`) {
          matches_tags = filters.tags.every((tag) => file.tags.includes(tag.label))
        } else if (filters.tag_mode === `any`) {
          matches_tags = filters.tags.some((tag) => file.tags.includes(tag.label))
        } else throw new Error(`Invalid tag mode: ${filters.tag_mode}`)
      }
      return matches_search && matches_tags
    })
    .sort((d1: Diagram, d2: Diagram) => {
      return d1.title.localeCompare(d2.title)
    })
