import { writable } from 'svelte/store'

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

export const search = url_param_store(`search`, ``)
