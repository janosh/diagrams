import { session_store, url_param_store } from 'svelte-zoo/stores'
import { writable } from 'svelte/store'
import type { TikzFigure } from '.'

export const search = url_param_store(`search`, ``)

export const tag_filter_mode = session_store<`and` | `or`>(
  `tag-filter-mode`,
  `or`,
)

export const filter_tags = session_store<{ label: string; count: number }[]>(
  `filter-tags`,
  [],
)

export const filtered_figs = writable<TikzFigure[]>([])
