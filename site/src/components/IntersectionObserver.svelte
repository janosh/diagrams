<script lang="ts">
  // https://github.com/sveltejs/svelte/blob/master/site/src/components/IntersectionObserver.svelte
  import { createEventDispatcher, onMount } from 'svelte'

  export let intersecting = false
  export let once = false
  export let top = 0
  export let bottom = 0
  export let left = 0
  export let right = 0

  let div: HTMLDivElement

  const dispatch = createEventDispatcher()

  onMount(() => {
    const rootMargin = `${bottom}px ${left}px ${top}px ${right}px`

    const observer = new IntersectionObserver(
      (entries) => {
        intersecting = entries[0].isIntersecting

        if (intersecting) dispatch(`intersect`)

        if (intersecting && once) observer.unobserve(div)
      },
      { rootMargin }
    )

    observer.observe(div)
    return () => observer.disconnect()
  })
</script>

<div bind:this={div}>
  <slot {intersecting} />
</div>
