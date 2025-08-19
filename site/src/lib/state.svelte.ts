import { diagrams } from '$lib'

export const filters = $state<{
  search: string
  tag_mode: boolean // True = ALL, False = ANY
  tags: { label: string; count: number }[]
}>({
  search: ``,
  tag_mode: false,
  tags: [],
})

export const filtered_diagrams = () =>
  diagrams
    .filter((file) => {
      const searchTerms = filters.search?.toLowerCase().split(` `)
      const matches_search = searchTerms?.every((term) =>
        JSON.stringify(file).toLowerCase().includes(term)
      )

      let matches_tags = true
      if (filters.tags.length > 0) {
        if (filters.tag_mode) {
          matches_tags = filters.tags.every((tag) => file.tags.includes(tag.label))
        } else {
          matches_tags = filters.tags.some((tag) => file.tags.includes(tag.label))
        }
      }
      return matches_search && matches_tags
    })
    .sort((d1, d2) => {
      return d1.title.localeCompare(d2.title)
    })
