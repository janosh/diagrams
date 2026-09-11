import { goto } from '$app/navigation'
import { resolve } from '$app/paths'
import { type Diagram, sorted_diagrams, tags as available_tags } from '$lib'
import {
  type UrlParamEntry,
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

// site-wide reactive filter store; a class instance keeps `filtered` a live derived across
// module imports (a bare module-level $derived can't be exported and stay reactive)
class DiagramFilters {
  search = $state(``)
  tag_mode = $state<`all` | `any`>(`all`)
  tags = $state<string[]>([])

  read_url(params: URLSearchParams) {
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
    // split on whitespace, drop empties so stray/pasted spaces don't break search
    const search_terms = this.search
      .normalize(`NFKC`)
      .toLowerCase()
      .split(/\s+/)
      .filter(Boolean)
    return sorted_diagrams.filter((diagram) => {
      const haystack = search_haystack(diagram)
      return search_terms.every((term) => haystack.includes(term))
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
export const replace_url = (url: string) =>
  goto(url, { keepFocus: true, noScroll: true, replaceState: true })
