<script lang="ts">
  import { goto } from '$app/navigation'
  import Icon from '@iconify/svelte'
  import type { TikzFigure } from '.'
  import { Card } from '.'

  export let prev: TikzFigure
  export let next: TikzFigure
  let style = `max-width: 250px; align-content: space-around; height: 100%;`

  const goto_options = { replaceState: true, noScroll: true }

  function handle_keyup(event: KeyboardEvent) {
    const to = {
      ArrowLeft: prev?.slug,
      ArrowRight: next?.slug,
      Escape: `/`,
    }[event.key]
    if (to) goto(to, goto_options)
  }
</script>

<svelte:window on:keyup={handle_keyup} />

<ul>
  <li>
    <h3>
      <a href={prev.slug}>
        <Icon icon="carbon:previous-filled" inline />
        Previous
      </a>
    </h3>
    <Card item={prev} {style} />
  </li>
  <li>
    <h3>
      <a href={next.slug}>
        Next
        <Icon icon="carbon:next-filled" inline />
      </a>
    </h3>
    <Card item={next} {style} />
  </li>
</ul>

<style>
  ul {
    display: flex;
    list-style: none;
    padding: 0;
    place-content: space-between;
    gap: 2em;
    max-width: 55em;
    margin: auto;
  }
  ul li {
    display: flex;
    flex-direction: column;
  }
</style>
