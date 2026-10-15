import { goto } from '$app/navigation'
import { resolve } from '$app/paths'
import { type Diagram, sorted_diagrams, tags as available_tags } from '#lib'
import type { QueryParams, UrlParamEntry } from 'svelte-widgets/url-params'
import {
  sync_url_params,
  url_with_params,
  valid_query_param,
} from 'svelte-widgets/url-params'

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

// Split on whitespace and drop empties so stray or pasted spaces don't break search.
const search_terms = (query: string) =>
  query.normalize(`NFKC`).toLowerCase().split(/\s+/).filter(Boolean)

// site-wide reactive filter store; a class instance keeps `filtered` a live derived across
// module imports (a bare module-level $derived can't be exported and stay reactive)
class DiagramFilters {
  search = $state(``)
  tag_mode = $state<`all` | `any`>(`all`)
  tags = $state<string[]>([])

  read_url(params: QueryParams) {
    this.search = params.get(`search`) ?? ``
    this.tag_mode = valid_query_param(params, `tag_mode`, `all`, { all: true, any: true })
    const labels = (params.get(`tag`) ?? ``).split(`,`).filter(Boolean)
    this.tags = [...new Set(labels)]
  }

  get url_entries(): UrlParamEntry[] {
    return [
      [`search`, this.search],
      [`tag`, this.tags.join(`,`)],
      [`tag_mode`, this.tag_mode, `all`],
    ]
  }

  url_for(pathname: string): string {
    return url_with_params(this.url_entries, { pathname, search: ``, hash: `` })
  }

  related_url(href: string, current_url: URL): string {
    if (href.startsWith(`#`)) return href
    const target = new URL(href, current_url)
    const is_diagram =
      target.origin === current_url.origin &&
      sorted_diagrams.some(({ slug }) => target.pathname === resolve(`/[slug]`, { slug }))
    return is_diagram ? url_with_params(this.url_entries, target) : href
  }

  search_matches = $derived.by(() => {
    const terms = search_terms(this.search)
    return sorted_diagrams.filter((diagram) => {
      const haystack = search_haystack(diagram)
      return terms.every((term) => haystack.includes(term))
    })
  })

  // Memoized matches retain the title order used by the gallery and detail navigation.
  filtered = $derived(
    this.search_matches.filter((file) => {
      const has_tag = (tag: string) => file.tags.includes(tag)
      return (
        this.tags.length === 0 ||
        (this.tag_mode === `all` ? this.tags.every(has_tag) : this.tags.some(has_tag))
      )
    }),
  )

  tag_counts = $derived(
    new Map(
      available_tags.map((tag) => {
        const has_tag = (file: Diagram) => file.tags.includes(tag)
        const count = this.filtered.filter(has_tag).length
        if (this.tag_mode !== `any` || !this.tags.length || this.tags.includes(tag))
          return [tag, count]
        // Adding an OR tag keeps current matches and adds its non-overlapping matches.
        return [
          tag,
          this.filtered.length + this.search_matches.filter(has_tag).length - count,
        ]
      }),
    ),
  )
}

export const filters = new DiagramFilters()

// Rewrite hrefs so copied links and new tabs retain the same gallery context as clicks.
export function preserve_filter_links(element: HTMLElement): void {
  const current_url = new URL(location.href)
  for (const link of element.querySelectorAll<HTMLAnchorElement>(
    `a[href]:not([download])`,
  )) {
    const href = link.getAttribute(`href`)
    if (href) link.setAttribute(`href`, filters.related_url(href, current_url))
  }
}

// Query controls replace the current entry without moving keyboard focus or the viewport.
export const replace_url = (url: string) => goto(url, { replace: true, reset: false })

// One query containing the other (typing on, deleting, adding or removing words) is the same
// search; switching between an empty and a non-empty query is not, so Back from a first search
// returns to the unfiltered gallery.
export const is_refinement = (before: string, after: string) => {
  const [old_query, new_query] = [before, after].map((query) =>
    search_terms(query).join(` `),
  )
  if (!old_query || !new_query) return old_query === new_query
  return old_query.includes(new_query) || new_query.includes(old_query)
}

// Filter changes update the current history entry at once, except search edits: those wait until
// the query rests, then add an entry for a different search or update the current one when the
// new query refines it. Back thus steps through distinct searches, never through keystrokes, and
// one write per settled query can't race SvelteKit's own navigation.
export const search_settle_ms = 500
let search_timer: ReturnType<typeof setTimeout> | undefined
export const cancel_search_write = () => clearTimeout(search_timer)
type FilterLocation = Pick<URL, `pathname` | `search` | `hash`> & {
  searchParams: QueryParams
}
export const write_filter_url = (page: { url: FilterLocation }) => {
  cancel_search_write()
  const committed_search = () => page.url.searchParams.get(`search`) ?? ``
  const write = (replace: boolean) => (url: string) =>
    void goto(url, { replace, reset: false })
  if (filters.search === committed_search())
    return sync_url_params(filters.url_entries, page.url, write(true))
  search_timer = setTimeout(() => {
    const replace = is_refinement(committed_search(), filters.search)
    sync_url_params(filters.url_entries, page.url, write(replace))
  }, search_settle_ms)
}
