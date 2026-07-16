import { type Diagram, sorted_diagrams } from '$lib'

// searchable text from human-readable fields only, not JSON.stringify(file) which also
// matched image paths/source code and re-serialized the whole object on every keystroke
const search_haystack = (file: Diagram): string =>
  [
    file.title,
    file.slug,
    file.creator ?? ``,
    ...file.tags,
    (file.description ?? ``).replaceAll(/<[^>]*>/g, ` `),
  ]
    .join(` `)
    .normalize(`NFKC`)
    .toLowerCase()

// site-wide reactive filter store; a class instance keeps `filtered` a live derived across
// module imports (a bare module-level $derived can't be exported and stay reactive)
class DiagramFilters {
  search = $state(``)
  tag_mode = $state<`all` | `any`>(`all`)
  tags = $state<{ label: string; count: number }[]>([])

  // memoized matches, stays title-sorted (sorted_diagrams pre-sorted; filter keeps order)
  filtered = $derived.by(() => {
    // split on whitespace, drop empties so stray/pasted spaces don't break search
    const search_terms = this.search
      .normalize(`NFKC`)
      .toLowerCase()
      .split(/\s+/)
      .filter(Boolean)
    return sorted_diagrams.filter((file) => {
      const haystack = search_haystack(file)
      const matches_search = search_terms.every((term) => haystack.includes(term))

      const has_tag = (tag: { label: string }) => file.tags.includes(tag.label)
      const matches_tags =
        this.tags.length === 0 ||
        (this.tag_mode === `all` ? this.tags.every(has_tag) : this.tags.some(has_tag))
      return matches_search && matches_tags
    })
  })
}

export const filters = new DiagramFilters()
