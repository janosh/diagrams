import { writable } from 'svelte/store'
import type { TikzFigure } from './types'

function url_param_store(name: string, initialValue: string | null) {
  if (typeof location !== `undefined`) {
    const val = new URL(location.toString()).searchParams.get(name)
    if (val) initialValue = decodeURIComponent(val)
  }

  const { subscribe, set } = writable(initialValue)

  return {
    subscribe,
    set: (val: string | null) => {
      const url = new URL(location.toString())
      if (val) url.searchParams.set(name, encodeURIComponent(val))
      else url.searchParams.delete(name)
      history.replaceState({}, ``, url)
      set(val)
    },
  }
}

function session_store<T>(name: string, initialValue: T) {
  if (typeof sessionStorage !== `undefined` && sessionStorage[name]) {
    initialValue = JSON.parse(sessionStorage[name])
  }

  const { subscribe, set } = writable(initialValue)

  return {
    subscribe,
    set: (val: T) => {
      if (val !== undefined && typeof sessionStorage !== `undefined`) {
        sessionStorage[name] = JSON.stringify(val)
      }
      set(val)
    },
  }
}

export const search = url_param_store(`search`, ``)

export const tag_filter_mode = session_store<`and` | `or`>(
  `tag-filter-mode`,
  `or`
)

export const filter_tags = session_store<{ label: string; count: number }[]>(
  `filter-tags`,
  []
)

export const filtered_figs = writable<TikzFigure[]>([])
